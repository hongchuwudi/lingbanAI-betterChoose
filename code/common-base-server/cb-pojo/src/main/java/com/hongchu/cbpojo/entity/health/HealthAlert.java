package com.hongchu.cbpojo.entity.health;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 健康预警记录表
 */
@Data
@TableName("health_alert")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HealthAlert {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;
    
    private String indicatorCode;
    
    private Long recordId;
    
    private LocalDateTime alertTime;
    
    private String alertType;
    
    private BigDecimal actualValue;
    
    private String normalRange;
    
    private Integer severity;
    
    private Integer status;
    
    private LocalDateTime handledTime;
    
    private Long handledBy;
    
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
