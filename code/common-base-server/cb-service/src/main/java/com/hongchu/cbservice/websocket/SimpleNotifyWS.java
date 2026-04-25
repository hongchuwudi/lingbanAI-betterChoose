package com.hongchu.cbservice.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hongchu.cbcommon.util.JwtUtil;
import com.hongchu.cbcommon.properties.JwtProperties;
import com.hongchu.cbcommon.vo.WebSocketMessage;
import io.jsonwebtoken.Claims;
import jakarta.websocket.*;
import jakarta.websocket.server.ServerEndpoint;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 通用WebSocket端点
 * 连接地址：ws://localhost:15555/ws?token=xxx
 * 支持多种消息类型：通知、聊天、心跳等
 */
@ServerEndpoint("/ws")
@Component
@Slf4j
public class SimpleNotifyWS {

    // 存储连接：userId -> session
    private static final ConcurrentHashMap<String, Session> userSessions = new ConcurrentHashMap<>();

    // 存储session -> userId（用于关闭时清理）
    private static final ConcurrentHashMap<Session, String> sessionUsers = new ConcurrentHashMap<>();

    // 注入JWT配置和ObjectMapper
    private static JwtProperties jwtProperties;
    private static ObjectMapper objectMapper;

    @Autowired
    public void setJwtProperties(JwtProperties jwtProperties) {
        SimpleNotifyWS.jwtProperties = jwtProperties;
    }

    @Autowired
    public void setObjectMapper(ObjectMapper objectMapper) {
        SimpleNotifyWS.objectMapper = objectMapper;
    }

    @OnOpen
    public void onOpen(Session session) {
        try {
            // 1. 从URL参数获取token
            Map<String, List<String>> params = session.getRequestParameterMap();
            List<String> tokens = params.get("token");

            if (tokens == null || tokens.isEmpty()) {
                log.warn("WebSocket连接缺少token参数");
                session.close();
                return;
            }

            String token = tokens.get(0);

            // 2. 验证并解析token（这里不能用BaseContext，要手动解析）
            if (!validateToken(token)) {
                log.warn("WebSocket token验证失败");
                session.close();
                return;
            }

            Claims claims = JwtUtil.parseJWT(jwtProperties.getSecret(), token);
            String userId = String.valueOf(claims.get("userId"));
            String username = claims.get("username", String.class);
            String roleCategory = claims.get("role_category", String.class);

            if (userId == null) {
                log.warn("WebSocket token中缺少userId");
                session.close();
                return;
            }

            // 3. 保存连接
            userSessions.put(userId, session);
            sessionUsers.put(session, userId);

            log.info("用户 {} ({}) 连接成功，角色分类：{}，在线用户数：{}",
                    userId, username, roleCategory, userSessions.size());

            // 4. 发送连接成功消息
            WebSocketMessage connectedMessage = WebSocketMessage.connected(userId, username);
            String jsonMessage = objectMapper.writeValueAsString(connectedMessage);
            session.getBasicRemote().sendText(jsonMessage);

        } catch (Exception e) {
            log.error("WebSocket连接异常", e);
            try {
                session.close();
            } catch (Exception ex) {
                // 忽略关闭异常
            }
        }
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        String userId = sessionUsers.get(session);

        try {
            // 解析 JSON 消息
            com.fasterxml.jackson.databind.JsonNode jsonNode = objectMapper.readTree(message);
            String type = jsonNode.has("type") ? jsonNode.get("type").asText() : "";

            // 心跳检测
            if ("heartbeat".equals(type)) {
                WebSocketMessage pongMessage = WebSocketMessage.pong();
                String jsonMessage = objectMapper.writeValueAsString(pongMessage);
                session.getBasicRemote().sendText(jsonMessage);
                log.debug("用户 {} 心跳检测", userId);
            } else {
                log.info("收到用户 {} 的消息: {}", userId, message);
                // 这里可以处理其他业务消息
            }
        } catch (Exception e) {
            log.error("处理消息失败", e);
        }
    }

    @OnClose
    public void onClose(Session session) {
        String userId = sessionUsers.remove(session);
        if (userId != null) {
            userSessions.remove(userId);
            log.info("用户 {} 连接关闭，剩余在线：{}", userId, userSessions.size());
        }
    }

    @OnError
    public void onError(Session session, Throwable error) {
        String userId = sessionUsers.get(session);
        log.error("用户 {} 的WebSocket错误", userId, error);

        // 发生错误时关闭连接
        try {
            session.close();
        } catch (IOException e) {
            log.error("关闭异常连接失败", e);
        }
    }

    /**
     * 验证token有效性
     */
    private boolean validateToken(String token) {
        try {
            Claims claims = JwtUtil.parseJWT(jwtProperties.getSecret(), token);
            return claims != null;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 发送通知给单个用户
     */
    public static void notifyUser(String userId, String message) {
        Session session = userSessions.get(userId);
        log.info("WebSocket notifyUser: userId={}, sessionExists={}, isOpen={}", 
                userId, session != null, session != null && session.isOpen());
        
        if (session != null && session.isOpen()) {
            try {
                session.getBasicRemote().sendText(message);
                log.info("发送通知给用户 {} 成功", userId);
            } catch (IOException e) {
                log.error("发送通知给用户 {} 失败", userId, e);
                // 发送失败，清理连接
                userSessions.remove(userId);
                sessionUsers.remove(session);
            }
        } else {
            log.warn("用户 {} 不在线，无法发送通知，当前在线用户: {}", userId, userSessions.keySet());
        }
    }

    /**
     * 发送通知给多个用户
     */
    public static void notifyUsers(List<String> userIds, String message) {
        for (String userId : userIds) {
            notifyUser(userId, message);
        }
    }

    /**
     * 广播通知给所有在线用户
     */
    public static void broadcast(String message) {
        for (Map.Entry<String, Session> entry : userSessions.entrySet()) {
            String userId = entry.getKey();
            Session session = entry.getValue();

            if (session != null && session.isOpen()) {
                try {
                    session.getBasicRemote().sendText(message);
                } catch (IOException e) {
                    log.error("广播通知给用户 {} 失败", userId, e);
                }
            }
        }
        log.debug("广播通知: {}", message);
    }

    /**
     * 检查用户是否在线
     */
    public static boolean isUserOnline(String userId) {
        Session session = userSessions.get(userId);
        return session != null && session.isOpen();
    }

    /**
     * 获取在线用户数
     */
    public static int getOnlineCount() {
        return userSessions.size();
    }

    /**
     * 获取所有在线用户ID
     */
    public static List<String> getOnlineUsers() {
        return List.copyOf(userSessions.keySet());
    }
}