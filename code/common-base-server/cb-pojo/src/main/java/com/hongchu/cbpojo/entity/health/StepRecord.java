package com.hongchu.cbpojo.entity.health;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 步数记录表
 */
@Data
@TableName("step_record")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StepRecord {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;
    
    private Integer steps;
    
    private BigDecimal distance;
    
    private Integer calories;
    
    private LocalDate recordDate;
    
    private String source;
    
    private String deviceId;
    
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
