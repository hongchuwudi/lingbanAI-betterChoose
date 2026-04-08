package com.hongchu.cbservice.service.interfaces.ai;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hongchu.cbpojo.dto.HealthAnalysisResponse;
import com.hongchu.cbpojo.entity.health.HealthAnalysisRecord;

public interface IHealthAnalysisService {

    HealthAnalysisRecord createAnalysisRecord(Long parseRecordId, Long userId);

    void analyzeAsync(Long analysisId, Long userId, Long parseRecordId);

    HealthAnalysisRecord getAnalysisRecord(Long analysisId);

    HealthAnalysisResponse analyzeHealthData(Long parseRecordId, Long userId);

    Page<HealthAnalysisRecord> getAnalysisRecordList(Long userId, int page, int size);

    HealthAnalysisRecord getAnalysisByParseRecordId(Long parseRecordId);
}
