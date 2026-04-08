package com.hongchu.cbcommon.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.Map;

/**
 * WebSocket通用消息格式
 * 用于前后端WebSocket通信的统一消息格式
 * 
 * @author hongchu
 * @since 2026-03-29
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WebSocketMessage implements Serializable {
    
    /**
     * 消息类型
     * 常见类型：
     * - connected: 连接成功
     * - pong: 心跳响应
     * - system_notification: 系统通知
     * - chat_message: 聊天消息
     * - health_reminder: 健康提醒
     * - medication_reminder: 用药提醒
     * - error: 错误消息
     */
    private String type;
    
    /**
     * 消息数据
     * 根据不同的消息类型，data 的结构不同
     */
    private Map<String, Object> data;
    
    /**
     * 时间戳
     */
    private Long timestamp;
    
    /**
     * 发送者ID（可选）
     * 用于聊天消息等需要知道发送者的场景
     */
    private String fromUserId;
    
    /**
     * 接收者ID（可选）
     * 用于指定接收者的场景
     */
    private String toUserId;
    
    /**
     * 消息ID（可选）
     * 用于消息去重和确认
     */
    private String messageId;
    
    // ==================== 常用静态工厂方法 ====================
    
    /**
     * 创建连接成功消息
     */
    public static WebSocketMessage connected(String userId, String username) {
        return WebSocketMessage.builder()
                .type("connected")
                .data(Map.of(
                    "message", "连接成功",
                    "userId", userId,
                    "username", username
                ))
                .timestamp(System.currentTimeMillis())
                .build();
    }
    
    /**
     * 创建心跳响应消息
     */
    public static WebSocketMessage pong() {
        return WebSocketMessage.builder()
                .type("pong")
                .timestamp(System.currentTimeMillis())
                .build();
    }
    
    /**
     * 创建系统通知消息
     */
    public static WebSocketMessage systemNotification(String title, String content, String level) {
        return WebSocketMessage.builder()
                .type("system_notification")
                .data(Map.of(
                    "title", title,
                    "content", content,
                    "level", level != null ? "info" : level
                ))
                .timestamp(System.currentTimeMillis())
                .build();
    }
    
    /**
     * 创建聊天消息
     */
    public static WebSocketMessage chatMessage(String fromUserId, String toUserId, String content) {
        return WebSocketMessage.builder()
                .type("chat_message")
                .fromUserId(fromUserId)
                .toUserId(toUserId)
                .data(Map.of("content", content))
                .timestamp(System.currentTimeMillis())
                .build();
    }
    
    /**
     * 创建健康提醒消息
     */
    public static WebSocketMessage healthReminder(String reminderType, String message, String level) {
        return WebSocketMessage.builder()
                .type("health_reminder")
                .data(Map.of(
                    "reminderType", reminderType,
                    "message", message,
                    "level", level != null ? "info" : level
                ))
                .timestamp(System.currentTimeMillis())
                .build();
    }
    
    /**
     * 创建用药提醒消息
     */
    public static WebSocketMessage medicationReminder(String medicineName, String dosage, String time) {
        return WebSocketMessage.builder()
                .type("medication_reminder")
                .data(Map.of(
                    "medicineName", medicineName,
                    "dosage", dosage,
                    "time", time,
                    "level", "important"
                ))
                .timestamp(System.currentTimeMillis())
                .build();
    }
    
    /**
     * 创建错误消息
     */
    public static WebSocketMessage error(String errorMessage) {
        return WebSocketMessage.builder()
                .type("error")
                .data(Map.of("error_message", errorMessage))
                .timestamp(System.currentTimeMillis())
                .build();
    }
    
    /**
     * 创建通用消息
     */
    public static WebSocketMessage create(String type, Map<String, Object> data) {
        return WebSocketMessage.builder()
                .type(type)
                .data(data)
                .timestamp(System.currentTimeMillis())
                .build();
    }
    
    /**
     * 创建带发送者的通用消息
     */
    public static WebSocketMessage create(String type, String fromUserId, Map<String, Object> data) {
        return WebSocketMessage.builder()
                .type(type)
                .fromUserId(fromUserId)
                .data(data)
                .timestamp(System.currentTimeMillis())
                .build();
    }
    
    public static WebSocketMessage create(String type, String fromUserId, String toUserId, Map<String, Object> data) {
        return WebSocketMessage.builder()
                .type(type)
                .fromUserId(fromUserId)
                .toUserId(toUserId)
                .data(data)
                .timestamp(System.currentTimeMillis())
                .build();
    }

    public static WebSocketMessage familyBindingRequest(String fromUserId, String toUserId, String fromUserName, String relationType) {
        return WebSocketMessage.builder()
                .type("family_binding_request")
                .fromUserId(fromUserId)
                .toUserId(toUserId)
                .data(Map.of(
                    "title", "家人绑定请求",
                    "content", fromUserName + " 想要添加您为家人关系",
                    "fromUserName", fromUserName,
                    "relationType", relationType
                ))
                .timestamp(System.currentTimeMillis())
                .build();
    }

    public static WebSocketMessage familyBindingConfirmed(String fromUserId, String toUserId, String fromUserName, String relationType) {
        return WebSocketMessage.builder()
                .type("family_binding_confirmed")
                .fromUserId(fromUserId)
                .toUserId(toUserId)
                .data(Map.of(
                    "title", "家人绑定已确认",
                    "content", fromUserName + " 已确认您的家人绑定请求",
                    "fromUserName", fromUserName,
                    "relationType", relationType
                ))
                .timestamp(System.currentTimeMillis())
                .build();
    }

    public static WebSocketMessage familyBindingRejected(String fromUserId, String toUserId, String fromUserName) {
        return WebSocketMessage.builder()
                .type("family_binding_rejected")
                .fromUserId(fromUserId)
                .toUserId(toUserId)
                .data(Map.of(
                    "title", "家人绑定已拒绝",
                    "content", fromUserName + " 拒绝了您的家人绑定请求",
                    "fromUserName", fromUserName
                ))
                .timestamp(System.currentTimeMillis())
                .build();
    }

    public static WebSocketMessage familyBindingDeleted(String fromUserId, String toUserId, String fromUserName) {
        return WebSocketMessage.builder()
                .type("family_binding_deleted")
                .fromUserId(fromUserId)
                .toUserId(toUserId)
                .data(Map.of(
                    "title", "家人关系已解除",
                    "content", fromUserName + " 解除了与您的家人关系",
                    "fromUserName", fromUserName
                ))
                .timestamp(System.currentTimeMillis())
                .build();
    }
}