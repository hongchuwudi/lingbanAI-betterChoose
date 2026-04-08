package com.hongchu.cbservice.service.impl.ai;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hongchu.cbpojo.dto.HealthAnalysisResponse;
import com.hongchu.cbpojo.entity.health.HealthAnalysisRecord;
import com.hongchu.cbpojo.entity.health.HealthDocumentParseRecord;
import com.hongchu.cbservice.mapper.health.HealthAnalysisRecordMapper;
import com.hongchu.cbservice.mapper.health.HealthDocumentParseRecordMapper;
import com.hongchu.cbservice.service.ai.HealthAnalysisAsyncExecutor;
import com.hongchu.cbservice.service.interfaces.ai.IHealthAnalysisService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class HealthAnalysisServiceImpl implements IHealthAnalysisService {

    private final HealthAnalysisAsyncExecutor asyncExecutor;
    private final HealthAnalysisRecordMapper analysisRecordMapper;
    private final HealthDocumentParseRecordMapper parseRecordMapper;

    @Override
    public HealthAnalysisRecord createAnalysisRecord(Long parseRecordId, Long userId) {
        HealthDocumentParseRecord parseRecord = parseRecordMapper.selectById(parseRecordId);
        if (parseRecord == null) {
            throw new IllegalArgumentException("解析记录不存在");
        }

        if (!"completed".equals(parseRecord.getStatus())) {
            throw new IllegalArgumentException("文档解析尚未完成，无法进行分析");
        }

        LambdaQueryWrapper<HealthAnalysisRecord> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(HealthAnalysisRecord::getParseRecordId, parseRecordId);
        HealthAnalysisRecord existingRecord = analysisRecordMapper.selectOne(queryWrapper);
        if (existingRecord != null) {
            log.info("分析记录已存在: id={}, parseRecordId={}", existingRecord.getId(), parseRecordId);
            return existingRecord;
        }

        HealthAnalysisRecord record = HealthAnalysisRecord.builder()
                .userId(userId)
                .parseRecordId(parseRecordId)
                .status("pending")
                .analysisStartTime(LocalDateTime.now())
                .build();

        analysisRecordMapper.insert(record);
        log.info("创建分析记录: id={}, parseRecordId={}, userId={}", record.getId(), parseRecordId, userId);

        return record;
    }

    @Override
    public void analyzeAsync(Long analysisId, Long userId, Long parseRecordId) {
        asyncExecutor.executeAnalysis(analysisId, userId, parseRecordId);
    }

    @Override
    public HealthAnalysisRecord getAnalysisRecord(Long analysisId) {
        return analysisRecordMapper.selectById(analysisId);
    }

    @Override
    public HealthAnalysisResponse analyzeHealthData(Long parseRecordId, Long userId) {
        HealthAnalysisRecord record = createAnalysisRecord(parseRecordId, userId);
        analyzeAsync(record.getId(), userId, parseRecordId);

        return HealthAnalysisResponse.builder()
                .analysisId(record.getId())
                .parseRecordId(parseRecordId)
                .status(record.getStatus())
                .createdAt(record.getCreatedAt())
                .build();
    }

    @Override
    public Page<HealthAnalysisRecord> getAnalysisRecordList(Long userId, int page, int size) {
        Page<HealthAnalysisRecord> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<HealthAnalysisRecord> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(HealthAnalysisRecord::getUserId, userId)
                    .orderByDesc(HealthAnalysisRecord::getCreatedAt);
        return analysisRecordMapper.selectPage(pageParam, queryWrapper);
    }

    @Override
    public HealthAnalysisRecord getAnalysisByParseRecordId(Long parseRecordId) {
        LambdaQueryWrapper<HealthAnalysisRecord> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(HealthAnalysisRecord::getParseRecordId, parseRecordId);
        return analysisRecordMapper.selectOne(queryWrapper);
    }
}
