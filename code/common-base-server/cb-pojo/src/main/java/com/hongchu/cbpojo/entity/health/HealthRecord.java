package com.hongchu.cbpojo.entity.health;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 通用健康指标记录表
 */
@Data
@TableName("health_record")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HealthRecord {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;
    
    private String indicatorCode;
    
    private LocalDateTime recordTime;
    
    private BigDecimal valueDecimal;
    
    private String valueText;
    
    private String valueJson;
    
    private String source;
    
    private String deviceId;
    
    private String remark;
    
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
