package com.hongchu.cbpojo.entity.health;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 健康分析记录表
 * 关联文档解析记录，存储AI分析结果
 */
@Data
@TableName("health_analysis_record")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HealthAnalysisRecord {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private Long parseRecordId;

    private String status;

    private String healthConclusion;

    private String medicationRecommendation;

    private String currentStatus;

    private String improvementPoints;

    private String recheckReminders;

    private String suggestedIndicators;

    private String rawAnalysis;

    private String errorMessage;

    private LocalDateTime analysisStartTime;

    private LocalDateTime analysisEndTime;

    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
