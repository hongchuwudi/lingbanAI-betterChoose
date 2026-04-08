package com.hongchu.cbservice.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hongchu.cbcommon.vo.WebSocketMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * WebSocket通用工具类
 * 封装常用的WebSocket操作方法
 */
@Component
@Slf4j
public class WebSocketUtil {
    private static ObjectMapper objectMapper = new ObjectMapper();

    /**
     * 通知单个用户
     */
    public static void notifyUser(String userId, String message) {
        SimpleNotifyWS.notifyUser(userId, message);
    }

    /**
     * 通知单个用户（使用通用消息格式）
     */
    public static void notifyUser(String userId, WebSocketMessage message) {
        try {
            String jsonMessage = objectMapper.writeValueAsString(message);
            SimpleNotifyWS.notifyUser(userId, jsonMessage);
        } catch (Exception e) {
            log.error("构造通知消息失败", e);
        }
    }

    /**
     * 通知多个用户
     */
    public static void notifyUsers(List<String> userIds, String message) {
        for (String userId : userIds) {
            SimpleNotifyWS.notifyUser(userId, message);
        }
    }

    /**
     * 通知多个用户（使用通用消息格式）
     */
    public static void notifyUsers(List<String> userIds, WebSocketMessage message) {
        try {
            String jsonMessage = objectMapper.writeValueAsString(message);
            for (String userId : userIds) {
                SimpleNotifyWS.notifyUser(userId, jsonMessage);
            }
        } catch (Exception e) {
            log.error("构造通知消息失败", e);
        }
    }

    /**
     * 广播通知给所有在线用户
     */
    public static void broadcast(String message) {
        SimpleNotifyWS.broadcast(message);
    }

    /**
     * 广播通知给所有在线用户（使用通用消息格式）
     */
    public static void broadcast(WebSocketMessage message) {
        try {
            String jsonMessage = objectMapper.writeValueAsString(message);
            SimpleNotifyWS.broadcast(jsonMessage);
        } catch (Exception e) {
            log.error("构造广播消息失败", e);
        }
    }

    /**
     * 检查用户是否在线
     */
    public static boolean isUserOnline(String userId) {
        return SimpleNotifyWS.isUserOnline(userId);
    }

    /**
     * 获取在线用户数
     */
    public static int getOnlineCount() {
        return SimpleNotifyWS.getOnlineCount();
    }

    /**
     * 获取所有在线用户ID
     */
    public static List<String> getOnlineUsers() {
        return SimpleNotifyWS.getOnlineUsers();
    }

    /**
     * 发送系统通知
     */
    public static void sendSystemNotification(String userId, String title, String content) {
        WebSocketMessage message = WebSocketMessage.systemNotification(title, content, "info");
        notifyUser(userId, message);
    }

    /**
     * 发送系统通知给多个用户
     */
    public static void sendSystemNotification(List<String> userIds, String title, String content) {
        WebSocketMessage message = WebSocketMessage.systemNotification(title, content, "info");
        notifyUsers(userIds, message);
    }

    /**
     * 发送聊天消息
     */
    public static void sendChatMessage(String fromUserId, String toUserId, String content) {
        WebSocketMessage message = WebSocketMessage.chatMessage(fromUserId, toUserId, content);
        notifyUser(toUserId, message);
    }

    /**
     * 发送健康提醒
     */
    public static void sendHealthReminder(String userId, String reminderType, String message) {
        WebSocketMessage wsMessage = WebSocketMessage.healthReminder(reminderType, message, "warning");
        notifyUser(userId, wsMessage);
    }

    /**
     * 发送用药提醒
     */
    public static void sendMedicationReminder(String userId, String medicineName, String dosage, String time) {
        WebSocketMessage message = WebSocketMessage.medicationReminder(medicineName, dosage, time);
        notifyUser(userId, message);
    }

    /**
     * 发送连接成功消息
     */
    public static void sendConnectedMessage(String userId, String username) {
        WebSocketMessage message = WebSocketMessage.connected(userId, username);
        notifyUser(userId, message);
    }

    /**
     * 发送心跳响应
     */
    public static void sendPongMessage(String userId) {
        WebSocketMessage message = WebSocketMessage.pong();
        notifyUser(userId, message);
    }

    /**
     * 发送错误消息
     */
    public static void sendErrorMessage(String userId, String errorMessage) {
        WebSocketMessage message = WebSocketMessage.error(errorMessage);
        notifyUser(userId, message);
    }
}