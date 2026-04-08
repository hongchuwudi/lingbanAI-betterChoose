package com.hongchu.cbpojo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 健康分析响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HealthAnalysisResponse {

    private Long analysisId;

    private Long parseRecordId;

    private String status;

    private String healthConclusion;

    private String medicationRecommendation;

    private String currentStatus;

    private String improvementPoints;

    private String recheckReminders;

    private String suggestedIndicators;

    private LocalDateTime createdAt;
}
