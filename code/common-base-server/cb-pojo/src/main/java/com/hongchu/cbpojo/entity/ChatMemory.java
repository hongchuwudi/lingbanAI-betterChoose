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
 * 聊天记录实体类
 * 注意：此表为业务扩展表，Spring AI 的对话历史存储在 spring_ai_chat_memory 表中
 */
@Data
@TableName(value = "chat_memory", autoResultMap = true)
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMemory {
    
    /** 主键ID */
    @TableId(type = IdType.ASSIGN_ID)
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;
    
    /** 会话ID（关联 spring_ai_chat_memory.conversation_id） */
    private String sessionId;
    
    /** 角色：user/assistant/system */
    private String role;
    
    /** 消息内容 */
    private String content;
    
    /** AI模型名称 */
    private String aiModel;
    
    /** token数量 */
    private Integer tokenCount;
    
    /** 创建时间 */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    /** 更新时间 */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
