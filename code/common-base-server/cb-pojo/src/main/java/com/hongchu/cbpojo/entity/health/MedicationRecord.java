package com.hongchu.cbpojo.entity.health;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 用药执行记录表
 */
@Data
@TableName("medication_record")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MedicationRecord {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;
    
    private Long planId;
    
    private LocalDateTime scheduledTime;
    
    private LocalDateTime actualTime;
    
    private Integer status;
    
    private String remark;
    
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
