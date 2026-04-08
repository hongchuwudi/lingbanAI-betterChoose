package com.hongchu.cbpojo.entity.health;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 健康指标定义表
 */
@Data
@TableName("health_indicator_def")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HealthIndicatorDef {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String code;
    
    private String name;
    
    private String category;
    
    private String unit;
    
    private String dataType;
    
    private BigDecimal valueRangeMin;
    
    private BigDecimal valueRangeMax;
    
    private BigDecimal warningLow;
    
    private BigDecimal warningHigh;
    
    private Boolean isActive;
    
    private Integer sortOrder;
    
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
