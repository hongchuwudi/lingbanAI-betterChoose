package com.hongchu.cbpojo.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@TableName("common_log")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CommonLog {
    
    @TableId(type = IdType.AUTO)
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;
    
    // 基础信息
    private String logType;        // 日志类型
    private String logLevel;       // 日志级别
    private String module;         // 模块名称
    
    // 业务信息
    private String businessType;   // 业务类型
    private String operation;      // 操作描述
    
    // 用户信息
    private Long userId;           // 用户ID
    private String username;       // 用户名
    private String userRole;       // 用户角色
    
    // 请求信息
    private String requestMethod;  // 请求方法
    private String requestUrl;     // 请求URL
    private String requestParams;  // 请求参数
    private String requestBody;    // 请求体
    
    // 响应信息
    private Integer responseStatus; // 响应状态码
    private String responseBody;   // 响应体
    private Long executeTime;      // 执行耗时(毫秒)
    
    // 设备信息
    private String clientIp;       // 客户端IP
    private String userAgent;      // 用户代理
    private String deviceType;     // 设备类型
    
    // 系统信息
    private String serverIp;       // 服务器IP
    
    // 时间信息
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
