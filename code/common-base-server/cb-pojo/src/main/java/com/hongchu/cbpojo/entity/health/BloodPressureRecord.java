package com.hongchu.cbpojo.entity.health;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 血压记录表
 */
@Data
@TableName("blood_pressure_record")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BloodPressureRecord {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;
    
    private Integer systolic;
    
    private Integer diastolic;
    
    private Integer pulse;
    
    private LocalDateTime recordTime;
    
    private String source;
    
    private String deviceId;
    
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
