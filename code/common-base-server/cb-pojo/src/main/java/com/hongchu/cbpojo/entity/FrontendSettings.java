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
 * 前端设置表实体类
 */
@Data
@TableName("frontend_settings")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FrontendSettings {
    
    @TableId(type = IdType.ASSIGN_ID)
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;
    
    /** 用户ID，关联users表 */
    @TableField("user_id")
    private Long userId;
    
    /** 前端设置JSON内容 */
    private String settings = "{}";
    
    /** 平台类型：flutter/web/ios/android/harmony */
    private String platform;
    
    /** 创建时间 */
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    /** 更新时间 */
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}