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
 * 睡眠记录表
 */
@Data
@TableName("sleep_record")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SleepRecord {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;
    
    private BigDecimal sleepDuration;
    
    private BigDecimal deepSleep;
    
    private BigDecimal lightSleep;
    
    private Integer awakeCount;
    
    private Integer sleepQuality;
    
    private LocalDate recordDate;
    
    private String source;
    
    private String deviceId;
    
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
