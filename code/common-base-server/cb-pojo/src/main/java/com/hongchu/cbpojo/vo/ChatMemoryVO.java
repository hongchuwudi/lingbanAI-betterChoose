package com.hongchu.cbpojo.vo;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 聊天记录视图对象
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatMemoryVO {
    
    /** 主键ID */
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;
    
    /** 会话ID */
    private String sessionId;
    
    /** 角色：user/assistant */
    private String role;
    
    /** 消息内容 */
    private String content;
    
    /** 图片URL列表 */
    private List<String> imageUrls;
    
    /** 用户语音URL（原始录音） */
    private String audioUrl;
    
    /** AI语音URL（TTS合成） */
    private String ttsAudioUrl;
    
    /** AI模型名称 */
    private String aiModel;
    
    /** token数量 */
    private Integer tokenCount;
    
    /** 创建时间 */
    private LocalDateTime createdAt;
    
    /** 更新时间 */
    private LocalDateTime updatedAt;
}
