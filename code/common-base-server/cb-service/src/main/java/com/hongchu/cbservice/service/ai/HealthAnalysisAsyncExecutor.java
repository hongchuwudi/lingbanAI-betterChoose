package com.hongchu.cbservice.service.ai;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hongchu.cbpojo.entity.health.HealthAnalysisRecord;
import com.hongchu.cbservice.mapper.health.HealthAnalysisRecordMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class HealthAnalysisAsyncExecutor {

    @Qualifier("healthAnalysisChatClient")
    private final ChatClient healthAnalysisChatClient;
    private final HealthAnalysisFunction healthAnalysisFunction;
    private final HealthAnalysisRecordMapper analysisRecordMapper;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Async
    @Transactional
    public void executeAnalysis(Long analysisId, Long userId, Long parseRecordId) {
        log.info("开始异步健康分析: analysisId={}, userId={}", analysisId, userId);

        HealthAnalysisRecord record = analysisRecordMapper.selectById(analysisId);
        if (record == null) {
            log.error("分析记录不存在: {}", analysisId);
            return;
        }

        try {
            updateStatus(record, "processing", null);

            String healthData = healthAnalysisFunction.getUserHealthData(userId, parseRecordId);
            String analysisResult = callAI(healthData);
            parseAndSaveResult(record, analysisResult);

            updateStatus(record, "completed", null);
            log.info("健康分析完成: analysisId={}", analysisId);

        } catch (Exception e) {
            log.error("健康分析失败: analysisId={}", analysisId, e);
            updateStatus(record, "failed", e.getMessage());
        }
    }

    private String callAI(String healthData) {
        log.info("开始AI健康分析");

        String userPrompt = """
            请分析以下用户的健康数据，生成详细的健康分析报告。
            
            用户健康数据：
            """ + healthData + """
            
            请根据以上数据，按照系统提示的要求，生成JSON格式的分析报告。
            """;

        String response = healthAnalysisChatClient.prompt()
                .user(userPrompt)
                .call()
                .content();

        log.info("AI分析响应长度: {}", response != null ? response.length() : 0);
        return response;
    }

    private void parseAndSaveResult(HealthAnalysisRecord record, String analysisResult) {
        try {
            String jsonContent = extractJson(analysisResult);
            Map<String, String> result = objectMapper.readValue(jsonContent, new TypeReference<Map<String, String>>() {});

            record.setHealthConclusion(result.get("healthConclusion"));
            record.setMedicationRecommendation(result.get("medicationRecommendation"));
            record.setCurrentStatus(result.get("currentStatus"));
            record.setImprovementPoints(result.get("improvementPoints"));
            record.setRecheckReminders(result.get("recheckReminders"));
            record.setSuggestedIndicators(result.get("suggestedIndicators"));
            record.setRawAnalysis(analysisResult);
            record.setAnalysisEndTime(LocalDateTime.now());

            analysisRecordMapper.updateById(record);
            log.info("分析结果保存成功: analysisId={}", record.getId());

        } catch (JsonProcessingException e) {
            log.warn("解析AI响应失败，保存原始内容: {}", e.getMessage());
            record.setRawAnalysis(analysisResult);
            record.setHealthConclusion(analysisResult);
            record.setAnalysisEndTime(LocalDateTime.now());
            analysisRecordMapper.updateById(record);
        }
    }

    private String extractJson(String content) {
        if (content == null || content.isEmpty()) {
            return "{}";
        }

        int start = content.indexOf('{');
        int end = content.lastIndexOf('}');

        if (start != -1 && end != -1 && end > start) {
            return content.substring(start, end + 1);
        }

        return content;
    }

    private void updateStatus(HealthAnalysisRecord record, String status, String error) {
        record.setStatus(status);
        record.setErrorMessage(error);
        record.setAnalysisEndTime(LocalDateTime.now());
        analysisRecordMapper.updateById(record);
    }
}
