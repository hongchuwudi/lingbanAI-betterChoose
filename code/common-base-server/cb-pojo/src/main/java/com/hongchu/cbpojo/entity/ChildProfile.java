package com.hongchu.cbpojo.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 子女档案表实体类
 */
@Data
@TableName("child_profile")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChildProfile {
    
    @TableId(type = IdType.ASSIGN_ID)
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;
    
    /** 用户ID，关联users表 */
    @TableField("user_id")
    @JsonSerialize(using = ToStringSerializer.class)
    private Long userId;
    
    /** 通知偏好设置，格式：{"receive_sos":true,"receive_alert":true,"receive_weekly_report":true} */
    @TableField("guardian_settings")
    private String guardianSettings = "{\"receive_sos\":true,\"receive_alert\":true,\"receive_weekly_report\":true,\"receive_checkin_reminder\":true,\"receive_medication_reminder\":true}";
    
    /** 平安签到设置，格式：{"elderly_id":{"time":"09:00","enabled":true}} */
    @TableField("checkin_settings")
    private String checkinSettings = "{}";
    
    /** 创建时间 */
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    /** 更新时间 */
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}