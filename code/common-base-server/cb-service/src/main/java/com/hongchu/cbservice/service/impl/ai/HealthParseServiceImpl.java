package com.hongchu.cbservice.service.impl.ai;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hongchu.cbcommon.util.AliyunOSSOperator;
import com.hongchu.cbpojo.dto.ExtractedHealthIndicator;
import com.hongchu.cbpojo.entity.health.*;
import com.hongchu.cbservice.mapper.health.*;
import com.hongchu.cbservice.service.interfaces.ai.IHealthParseService;
import com.hongchu.cbservice.util.PdfUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.content.Media;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.MimeTypeUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class HealthParseServiceImpl implements IHealthParseService {

    @Qualifier("healthParseChatClient")
    private final ChatClient healthParseChatClient;
    private final BloodPressureRecordMapper bpMapper;
    private final GlucoseRecordMapper glucoseMapper;
    private final HeartRateRecordMapper heartRateMapper;
    private final WeightRecordMapper weightMapper;
    private final Spo2RecordMapper spo2Mapper;
    private final HealthRecordMapper healthRecordMapper;
    private final HealthDocumentParseRecordMapper parseRecordMapper;
    private final AliyunOSSOperator ossOperator;

    private final ObjectMapper objectMapper = new ObjectMapper();

    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024;
    private static final Set<String> ALLOWED_TYPES = Set.of(
            "application/pdf",
            "image/jpeg",
            "image/jpg",
            "image/png"
    );
    private static final String USER_PROMPT = "请分析这份文档，提取健康指标。";

    @Override
    public HealthDocumentParseRecord createParseRecord(MultipartFile file, Long userId) throws IOException {
        validateFile(file);

        byte[] fileBytes = file.getBytes();
        String fileName = file.getOriginalFilename();
        String contentType = file.getContentType();

        String ossUrl = ossOperator.upload(fileBytes, fileName, "health-doc");

        HealthDocumentParseRecord record = HealthDocumentParseRecord.builder()
                .userId(userId)
                .fileName(fileName)
                .fileUrl(ossUrl)
                .fileSize(file.getSize())
                .contentType(contentType)
                .status("pending")
                .parseStartTime(LocalDateTime.now())
                .build();

        parseRecordMapper.insert(record);
        log.info("创建解析记录: id={}, fileName={}, userId={}", record.getId(), fileName, userId);

        return record;
    }

    @Override
    @Async
    @Transactional
    public void parseDocumentAsync(Long recordId, byte[] fileBytes, String fileName, String contentType) {
        HealthDocumentParseRecord record = parseRecordMapper.selectById(recordId);
        if (record == null) {
            log.error("解析记录不存在: {}", recordId);
            return;
        }

        try {
            updateStatus(record, "processing", null, null);

            MultipartFile mockFile = createMockMultipartFile(fileBytes, fileName, contentType);

            List<ExtractedHealthIndicator> indicators = parseDocument(mockFile);

            if (indicators.isEmpty()) {
                updateStatus(record, "failed", 0, "未能识别出健康指标");
                return;
            }

            saveIndicators(indicators, record.getUserId());

            updateStatus(record, "completed", indicators.size(), null);
            log.info("异步解析完成: recordId={}, indicatorCount={}", recordId, indicators.size());

        } catch (Exception e) {
            log.error("异步解析失败: recordId={}", recordId, e);
            updateStatus(record, "failed", 0, e.getMessage());
        }
    }

    private void updateStatus(HealthDocumentParseRecord record, String status, Integer count, String error) {
        record.setStatus(status);
        record.setIndicatorCount(count);
        record.setErrorMessage(error);
        record.setParseEndTime(LocalDateTime.now());
        parseRecordMapper.updateById(record);
    }

    private byte[] downloadFromOss(String fileUrl) {
        return new byte[0];
    }

    private MultipartFile createMockMultipartFile(byte[] bytes, String fileName, String contentType) {
        return new MultipartFile() {
            @Override
            public String getName() {
                return "file";
            }

            @Override
            public String getOriginalFilename() {
                return fileName;
            }

            @Override
            public String getContentType() {
                return contentType;
            }

            @Override
            public boolean isEmpty() {
                return bytes == null || bytes.length == 0;
            }

            @Override
            public long getSize() {
                return bytes.length;
            }

            @Override
            public byte[] getBytes() {
                return bytes;
            }

            @Override
            public java.io.InputStream getInputStream() {
                return new java.io.ByteArrayInputStream(bytes);
            }

            @Override
            public void transferTo(java.io.File dest) throws IOException {
                try (java.io.FileOutputStream fos = new java.io.FileOutputStream(dest)) {
                    fos.write(bytes);
                }
            }
        };
    }

    @Override
    public List<ExtractedHealthIndicator> parseDocument(MultipartFile file) throws IOException {
        validateFile(file);

        List<byte[]> images = prepareImages(file);
        List<Media> medias = createMedias(images, file.getContentType());

        String aiResponse = callAI(medias);
        return parseAIResponse(aiResponse);
    }

    private void validateFile(MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("文件不能为空");
        }

        if (file.getSize() > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("文件大小不能超过10MB");
        }

        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_TYPES.contains(contentType)) {
            throw new IllegalArgumentException("仅支持PDF和图片（jpg/png）格式");
        }
    }

    private List<byte[]> prepareImages(MultipartFile file) throws IOException {
        String contentType = file.getContentType();
        byte[] bytes = file.getBytes();

        if ("application/pdf".equals(contentType)) {
            log.info("开始处理PDF文件，大小: {} bytes", bytes.length);
            List<byte[]> images = PdfUtil.convertPdfToImages(bytes);
            log.info("PDF转换完成，共{}页图片", images.size());
            return images;
        } else {
            log.info("处理图片文件，大小: {} bytes", bytes.length);
            return List.of(bytes);
        }
    }

    private List<Media> createMedias(List<byte[]> images, String originalContentType) {
        List<Media> medias = new ArrayList<>();
        for (int i = 0; i < images.size(); i++) {
            byte[] img = images.get(i);
            ByteArrayResource resource = new ByteArrayResource(img);
            Media media;
            if ("application/pdf".equals(originalContentType)) {
                media = new Media(MimeTypeUtils.IMAGE_PNG, resource);
            } else if ("image/png".equals(originalContentType)) {
                media = new Media(MimeTypeUtils.IMAGE_PNG, resource);
            } else {
                media = new Media(MimeTypeUtils.IMAGE_JPEG, resource);
            }
            medias.add(media);
        }
        return medias;
    }

    private String callAI(List<Media> medias) {
        log.info("准备调用AI，图片数量: {}", medias.size());

        String response = healthParseChatClient.prompt()
                .user(p -> {
                    p.text(USER_PROMPT);
                    for (Media media : medias) {
                        p.media(media);
                    }
                })
                .call()
                .content();

        log.info("AI响应内容: {}", response);
        return response;
    }

    private List<ExtractedHealthIndicator> parseAIResponse(String response) {
        if (response == null || response.isBlank()) {
            log.warn("AI返回空响应");
            return List.of();
        }

        String jsonContent = extractJsonArray(response);

        try {
            List<Map<String, Object>> items = objectMapper.readValue(
                    jsonContent,
                    new TypeReference<List<Map<String, Object>>>() {}
            );

            return items.stream()
                    .map(this::mapToIndicator)
                    .filter(Objects::nonNull)
                    .toList();
        } catch (JsonProcessingException e) {
            log.error("解析AI响应失败，原始响应: {}", response, e);
            throw new RuntimeException("AI返回的数据格式不正确，请重试");
        }
    }

    private String extractJsonArray(String response) {
        int start = response.indexOf('[');
        int end = response.lastIndexOf(']');

        if (start == -1 || end == -1 || start > end) {
            log.error("AI未返回JSON数组，原始响应: {}", response);
            if (response.contains("无法识别") || response.contains("没有") || response.contains("未找到")) {
                throw new RuntimeException("无法从文档中识别出健康指标，请确保上传的是健康报告");
            }
            throw new RuntimeException("AI未返回有效的JSON数组，请重试");
        }

        return response.substring(start, end + 1);
    }

    private ExtractedHealthIndicator mapToIndicator(Map<String, Object> item) {
        try {
            String code = (String) item.get("indicatorCode");
            Object valueObj = item.get("value");
            String unit = (String) item.get("unit");
            String timeStr = (String) item.get("recordTime");
            String type = (String) item.get("type");

            BigDecimal value = null;
            if (valueObj instanceof Number) {
                value = BigDecimal.valueOf(((Number) valueObj).doubleValue());
            } else if (valueObj instanceof String) {
                value = new BigDecimal((String) valueObj);
            }

            LocalDateTime recordTime = parseTime(timeStr);

            return ExtractedHealthIndicator.builder()
                    .indicatorCode(code)
                    .value(value)
                    .unit(unit)
                    .recordTime(recordTime)
                    .type(type)
                    .build();
        } catch (Exception e) {
            log.warn("解析指标失败: {}", item, e);
            return null;
        }
    }

    private LocalDateTime parseTime(String timeStr) {
        if (timeStr == null || timeStr.isBlank()) {
            return LocalDateTime.now();
        }

        try {
            if (timeStr.endsWith("Z")) {
                return LocalDateTime.ofInstant(
                        Instant.parse(timeStr),
                        ZoneId.systemDefault()
                );
            }
        } catch (DateTimeParseException ignored) {
        }

        List<DateTimeFormatter> formatters = List.of(
                DateTimeFormatter.ISO_LOCAL_DATE_TIME,
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"),
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"),
                DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm"),
                DateTimeFormatter.ofPattern("yyyy年MM月dd日 HH:mm")
        );

        for (DateTimeFormatter formatter : formatters) {
            try {
                return LocalDateTime.parse(timeStr, formatter);
            } catch (DateTimeParseException ignored) {
            }
        }

        return LocalDateTime.now();
    }

    @Override
    @Transactional
    public void saveIndicators(List<ExtractedHealthIndicator> indicators, Long userId) {
        if (indicators == null || indicators.isEmpty()) {
            return;
        }

        Map<String, List<ExtractedHealthIndicator>> grouped = indicators.stream()
                .collect(Collectors.groupingBy(ExtractedHealthIndicator::getIndicatorCode));

        saveBloodPressure(grouped, userId);
        saveGlucose(grouped, userId);
        saveHeartRate(grouped, userId);
        saveWeight(grouped, userId);
        saveSpo2(grouped, userId);
        saveOthers(grouped, userId);

        log.info("已保存{}条健康指标记录，用户ID: {}", indicators.size(), userId);
    }

    private void saveBloodPressure(Map<String, List<ExtractedHealthIndicator>> grouped, Long userId) {
        List<ExtractedHealthIndicator> systolics = grouped.getOrDefault(
                ExtractedHealthIndicator.CODE_BP_SYSTOLIC, List.of());
        List<ExtractedHealthIndicator> diastolics = grouped.getOrDefault(
                ExtractedHealthIndicator.CODE_BP_DIASTOLIC, List.of());
        List<ExtractedHealthIndicator> pulses = grouped.getOrDefault(
                ExtractedHealthIndicator.CODE_PULSE, List.of());

        if (systolics.isEmpty() && diastolics.isEmpty()) {
            return;
        }

        LocalDateTime referenceTime = LocalDateTime.now();
        ExtractedHealthIndicator systolic = systolics.isEmpty() ? null : systolics.get(0);
        ExtractedHealthIndicator diastolic = diastolics.isEmpty() ? null : diastolics.get(0);
        ExtractedHealthIndicator pulse = pulses.isEmpty() ? null : pulses.get(0);

        if (systolic == null) {
            log.warn("血压记录缺少收缩压，跳过保存");
            return;
        }

        BloodPressureRecord record = BloodPressureRecord.builder()
                .userId(userId)
                .systolic(systolic.getValue().intValue())
                .diastolic(diastolic != null ? diastolic.getValue().intValue() : null)
                .pulse(pulse != null ? pulse.getValue().intValue() : null)
                .recordTime(referenceTime)
                .source("文档解析")
                .build();
        bpMapper.insert(record);
    }

    private void saveGlucose(Map<String, List<ExtractedHealthIndicator>> grouped, Long userId) {
        List<ExtractedHealthIndicator> allGlucose = new ArrayList<>();
        allGlucose.addAll(grouped.getOrDefault(ExtractedHealthIndicator.CODE_GLUCOSE_FASTING, List.of()));
        allGlucose.addAll(grouped.getOrDefault(ExtractedHealthIndicator.CODE_GLUCOSE_POSTPRANDIAL, List.of()));

        for (ExtractedHealthIndicator indicator : allGlucose) {
            String type = indicator.getType();
            if (type == null) {
                type = indicator.getIndicatorCode().contains("fasting") ? "fasting" : "postprandial";
            }

            GlucoseRecord record = GlucoseRecord.builder()
                    .userId(userId)
                    .value(indicator.getValue())
                    .type(type)
                    .recordTime(indicator.getRecordTime())
                    .source("文档解析")
                    .build();
            glucoseMapper.insert(record);
        }
    }

    private void saveHeartRate(Map<String, List<ExtractedHealthIndicator>> grouped, Long userId) {
        List<ExtractedHealthIndicator> heartRates = grouped.getOrDefault(
                ExtractedHealthIndicator.CODE_HEART_RATE, List.of());

        for (ExtractedHealthIndicator indicator : heartRates) {
            HeartRateRecord record = HeartRateRecord.builder()
                    .userId(userId)
                    .value(indicator.getValue().intValue())
                    .recordTime(indicator.getRecordTime())
                    .source("文档解析")
                    .build();
            heartRateMapper.insert(record);
        }
    }

    private void saveWeight(Map<String, List<ExtractedHealthIndicator>> grouped, Long userId) {
        List<ExtractedHealthIndicator> weights = grouped.getOrDefault(
                ExtractedHealthIndicator.CODE_WEIGHT, List.of());

        for (ExtractedHealthIndicator indicator : weights) {
            WeightRecord record = WeightRecord.builder()
                    .userId(userId)
                    .weight(indicator.getValue())
                    .recordTime(indicator.getRecordTime())
                    .source("文档解析")
                    .build();
            weightMapper.insert(record);
        }
    }

    private void saveSpo2(Map<String, List<ExtractedHealthIndicator>> grouped, Long userId) {
        List<ExtractedHealthIndicator> spo2s = grouped.getOrDefault(
                ExtractedHealthIndicator.CODE_SPO2, List.of());

        for (ExtractedHealthIndicator indicator : spo2s) {
            Spo2Record record = Spo2Record.builder()
                    .userId(userId)
                    .value(indicator.getValue().intValue())
                    .recordTime(indicator.getRecordTime())
                    .source("文档解析")
                    .build();
            spo2Mapper.insert(record);
        }
    }

    private void saveOthers(Map<String, List<ExtractedHealthIndicator>> grouped, Long userId) {
        Set<String> savedCodes = Set.of(
                ExtractedHealthIndicator.CODE_BP_SYSTOLIC,
                ExtractedHealthIndicator.CODE_BP_DIASTOLIC,
                ExtractedHealthIndicator.CODE_PULSE,
                ExtractedHealthIndicator.CODE_GLUCOSE_FASTING,
                ExtractedHealthIndicator.CODE_GLUCOSE_POSTPRANDIAL,
                ExtractedHealthIndicator.CODE_HEART_RATE,
                ExtractedHealthIndicator.CODE_WEIGHT,
                ExtractedHealthIndicator.CODE_SPO2
        );

        for (Map.Entry<String, List<ExtractedHealthIndicator>> entry : grouped.entrySet()) {
            if (savedCodes.contains(entry.getKey())) {
                continue;
            }

            for (ExtractedHealthIndicator indicator : entry.getValue()) {
                saveToHealthRecord(indicator, userId);
            }
        }
    }

    private void saveToHealthRecord(ExtractedHealthIndicator indicator, Long userId) {
        HealthRecord record = HealthRecord.builder()
                .userId(userId)
                .indicatorCode(indicator.getIndicatorCode())
                .recordTime(indicator.getRecordTime())
                .valueDecimal(indicator.getValue())
                .source("文档解析")
                .remark(indicator.getUnit())
                .build();
        healthRecordMapper.insert(record);
    }

    @Override
    public HealthDocumentParseRecord getParseRecord(Long recordId) {
        return parseRecordMapper.selectById(recordId);
    }

    @Override
    public Page<HealthDocumentParseRecord> getParseRecordList(Long userId, int page, int size) {
        Page<HealthDocumentParseRecord> pageParam = new Page<>(page, size);
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<HealthDocumentParseRecord> queryWrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<>();
        queryWrapper.eq(HealthDocumentParseRecord::getUserId, userId)
                    .orderByDesc(HealthDocumentParseRecord::getCreatedAt);
        return parseRecordMapper.selectPage(pageParam, queryWrapper);
    }
}
