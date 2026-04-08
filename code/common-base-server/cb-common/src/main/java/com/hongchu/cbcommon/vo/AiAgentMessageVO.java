package com.hongchu.cbcommon.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

/**
 * AI智能体WebSocket消息协议
 * 
 * @author hongchu
 * @since 2026-03-25
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AiAgentMessageVO {
    
    // 消息类型
    private String type;
    
    // 消息数据
    private Map<String, Object> data;
    
    // 时间戳
    private Long timestamp;
    
    // 消息ID（用于请求-响应匹配）
    private String messageId;
    
    // 用户ID
    private Long userId;
    
    // ==================== 消息类型常量 ====================
    
    public static class MessageType {
        // 客户端发送的消息类型
        public static final String USER_QUERY = "user_query";           // 用户查询
        public static final String HEARTBEAT = "heartbeat";             // 心跳检测
        public static final String CONNECT = "connect";                 // 连接建立
        public static final String DISCONNECT = "disconnect";           // 断开连接
        
        // 服务端发送的消息类型
        public static final String AI_RESPONSE = "ai_response";         // AI响应
        public static final String STATUS_UPDATE = "status_update";     // 状态更新
        public static final String ERROR = "error";                     // 错误信息
        public static final String CONNECTED = "connected";             // 连接成功
        public static final String PROCESSING = "processing";           // 处理中
        public static final String COMPLETED = "completed";             // 处理完成
    }
    
    // ==================== 数据字段常量 ====================
    
    public static class DataField {
        // 用户查询相关
        public static final String QUERY_TEXT = "query_text";           // 查询文本
        public static final String QUERY_TYPE = "query_type";           // 查询类型
        public static final String CONTEXT = "context";                 // 上下文信息
        
        // AI响应相关
        public static final String RESPONSE_TEXT = "response_text";     // 响应文本
        public static final String CONFIDENCE = "confidence";           // 置信度
        public static final String SOURCES = "sources";                 // 数据来源
        public static final String ACTIONS = "actions";                 // 建议操作
        
        // 状态相关
        public static final String STATUS = "status";                   // 状态
        public static final String PROGRESS = "progress";               // 进度
        public static final String ESTIMATED_TIME = "estimated_time";   // 预计时间
        
        // 错误相关
        public static final String ERROR_CODE = "error_code";           // 错误代码
        public static final String ERROR_MESSAGE = "error_message";     // 错误消息
    }
    
    // ==================== 查询类型常量 ====================
    
    public static class QueryType {
        public static final String HEALTH_QUERY = "health_query";       // 健康查询
        public static final String MEDICATION_QUERY = "medication_query"; // 用药查询
        public static final String DIET_QUERY = "diet_query";           // 饮食查询
        public static final String ACTIVITY_QUERY = "activity_query";   // 活动查询
        public static final String EMERGENCY_QUERY = "emergency_query"; // 紧急查询
        public static final String GENERAL_QUERY = "general_query";     // 一般查询
    }
}