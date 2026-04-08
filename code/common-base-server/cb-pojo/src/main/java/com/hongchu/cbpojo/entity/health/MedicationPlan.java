package com.hongchu.cbpojo.entity.health;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 用药计划表
 */
@Data
@TableName("medication_plan")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MedicationPlan {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;
    
    private String drugName;
    
    private String dosage;
    
    private String frequency;
    
    private String timePoints;
    
    private LocalDate startDate;
    
    private LocalDate endDate;
    
    private String instruction;
    
    private Boolean isActive;
    
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
