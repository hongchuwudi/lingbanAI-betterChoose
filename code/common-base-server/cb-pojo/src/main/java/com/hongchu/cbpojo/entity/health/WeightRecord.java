package com.hongchu.cbpojo.entity.health;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 体重记录表
 */
@Data
@TableName("weight_record")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WeightRecord {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;
    
    private BigDecimal weight;
    
    private BigDecimal bmi;
    
    private LocalDateTime recordTime;
    
    private String source;
    
    private String deviceId;
    
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
