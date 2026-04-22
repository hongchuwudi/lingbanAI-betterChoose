package com.hongchu.cbservice.service.impl.ai;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hongchu.cbpojo.entity.ChatMemory;
import com.hongchu.cbpojo.vo.ChatMemoryVO;
import com.hongchu.cbservice.mapper.ChatMemoryMapper;
import com.hongchu.cbservice.service.interfaces.ai.IChatMemoryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 聊天记录服务实现类
 * 注意：此服务查询 Spring AI 的 spring_ai_chat_memory 表
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChatMemoryServiceImpl extends ServiceImpl<ChatMemoryMapper, ChatMemory> implements IChatMemoryService {
    private final ChatMemoryMapper chatMemoryMapper;
    
    private static final Pattern IMAGE_PATTERN = Pattern.compile("^\\[images:([^\\]]+)\\]");
    private static final Pattern AUDIO_PATTERN = Pattern.compile("^\\[audio:([^\\]]+)\\]");
    private static final Pattern TTS_AUDIO_PATTERN = Pattern.compile("^\\[tts:([^\\]]+)\\]");
    
    @Override
    public void saveChatMessage(String sessionId, String role, String content, String aiModel, Integer tokenCount) {
        log.warn("saveChatMessage 方法已弃用，Spring AI 自动管理消息存储");
    }
    
    @Override
    public List<ChatMemoryVO> getChatHistory(String sessionId) {
        return convertToVOListFromMap(chatMemoryMapper.findBySessionId(sessionId));
    }
    
    @Override
    public List<ChatMemoryVO> getRecentChatHistory(String sessionId, int limit) {
        return convertToVOListFromMap(chatMemoryMapper.findRecentBySessionId(sessionId, limit));
    }
    
    @Override
    public void clearChatHistory(String sessionId) {
        chatMemoryMapper.deleteBySessionId(sessionId);
        log.info("清除会话历史，会话ID: {}", sessionId);
    }
    
    @Override
    public ChatMemoryVO convertToVO(ChatMemory chatMemory) {
        if (chatMemory == null) return null;
        return ChatMemoryVO.builder()
                .id(chatMemory.getId())
                .sessionId(chatMemory.getSessionId())
                .role(chatMemory.getRole())
                .content(chatMemory.getContent())
                .aiModel(chatMemory.getAiModel())
                .tokenCount(chatMemory.getTokenCount())
                .createdAt(chatMemory.getCreatedAt())
                .updatedAt(chatMemory.getUpdatedAt())
                .build();
    }
    
    private ChatMemoryVO convertMapToVO(Map<String, Object> map) {
        if (map == null) return null;
        
        LocalDateTime createdAt = toLocalDateTime(map.get("created_at"));
        String content = (String) map.get("content");
        String role = (String) map.get("role");
        
        List<String> imageUrls = null;
        String audioUrl = null;
        String ttsAudioUrl = null;
        String cleanContent = content;
        
        if (content != null) {
            Matcher imageMatcher = IMAGE_PATTERN.matcher(content);
            if (imageMatcher.find()) {
                String urlsStr = imageMatcher.group(1);
                imageUrls = List.of(urlsStr.split(","));
                cleanContent = cleanContent.substring(imageMatcher.end());
            }
            
            Matcher audioMatcher = AUDIO_PATTERN.matcher(cleanContent);
            if (audioMatcher.find()) {
                audioUrl = audioMatcher.group(1);
                cleanContent = cleanContent.substring(audioMatcher.end());
            }
            
            Matcher ttsMatcher = TTS_AUDIO_PATTERN.matcher(cleanContent);
            if (ttsMatcher.find()) {
                ttsAudioUrl = ttsMatcher.group(1);
                cleanContent = cleanContent.substring(ttsMatcher.end());
            }
        }
        
        return ChatMemoryVO.builder()
                .sessionId((String) map.get("session_id"))
                .role(role)
                .content(cleanContent.trim())
                .imageUrls(imageUrls)
                .audioUrl(audioUrl)
                .ttsAudioUrl(ttsAudioUrl)
                .createdAt(createdAt)
                .build();
    }
    
    private LocalDateTime toLocalDateTime(Object obj) {
        if (obj == null) return null;
        if (obj instanceof LocalDateTime) return (LocalDateTime) obj;
        if (obj instanceof java.sql.Timestamp) return ((java.sql.Timestamp) obj).toLocalDateTime();
        if (obj instanceof java.util.Date) return ((java.util.Date) obj).toInstant()
                .atZone(ZoneOffset.systemDefault())
                .toLocalDateTime();
        return null;
    }
    
    @Override
    public List<ChatMemoryVO> convertToVOList(List<ChatMemory> chatMemories) {
        return chatMemories.stream()
                .map(this::convertToVO)
                .toList();
    }
    
    public List<ChatMemoryVO> convertToVOListFromMap(List<Map<String, Object>> maps) {
        return maps.stream()
                .map(this::convertMapToVO)
                .toList();
    }

    @Override
    public void updateLastAssistantTtsUrl(String sessionId, String ttsAudioUrl) {
        Map<String, Object> lastMsg = chatMemoryMapper.findLastAssistantMessage(sessionId);
        if (lastMsg == null) {
            log.warn("未找到会话 {} 的最后助手消息", sessionId);
            return;
        }

        String content = (String) lastMsg.get("content");
        Object id = lastMsg.get("id");

        if (content == null) return;

        String ttsPrefix = "[tts:" + ttsAudioUrl + "]";
        if (content.startsWith("[tts:")) {
            content = TTS_AUDIO_PATTERN.matcher(content).replaceFirst("") ;
        }
        String newContent = ttsPrefix + content;

        chatMemoryMapper.updateContentById(id, newContent);
        log.info("更新会话 {} 最后助手消息的TTS URL: {}", sessionId, ttsAudioUrl);
    }
}
