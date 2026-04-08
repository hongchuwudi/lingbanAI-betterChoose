package com.hongchu.cbpojo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 从文档中提取的健康指标DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExtractedHealthIndicator {
    
    private String indicatorCode;
    
    private BigDecimal value;
    
    private String unit;
    
    private LocalDateTime recordTime;
    
    private String type;
    
    private String originalText;
    
    private String status;
    
    private String remark;
    
    public static final String CODE_BP_SYSTOLIC = "bp_systolic";
    public static final String CODE_BP_DIASTOLIC = "bp_diastolic";
    public static final String CODE_PULSE = "pulse";
    public static final String CODE_GLUCOSE_FASTING = "glucose_fasting";
    public static final String CODE_GLUCOSE_POSTPRANDIAL = "glucose_postprandial";
    public static final String CODE_HEART_RATE = "heart_rate";
    public static final String CODE_WEIGHT = "weight";
    public static final String CODE_SPO2 = "spo2";
    public static final String CODE_STEPS = "steps";
    public static final String CODE_SLEEP_DURATION = "sleep_duration";
    public static final String CODE_TOTAL_CHOLESTEROL = "total_cholesterol";
    public static final String CODE_TRIGLYCERIDE = "triglyceride";
    public static final String CODE_HDL_CHOLESTEROL = "hdl_cholesterol";
    public static final String CODE_LDL_CHOLESTEROL = "ldl_cholesterol";
    public static final String CODE_CREATININE = "creatinine";
    public static final String CODE_URIC_ACID = "uric_acid";
    public static final String CODE_ALT = "alt";
    public static final String CODE_AST = "ast";
}
