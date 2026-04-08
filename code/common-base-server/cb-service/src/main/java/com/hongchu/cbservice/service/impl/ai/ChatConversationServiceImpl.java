package com.hongchu.cbservice.service.impl.ai;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hongchu.cbpojo.entity.ChatConversation;
import com.hongchu.cbpojo.vo.ChatConversationVO;
import com.hongchu.cbservice.mapper.ChatConversationMapper;
import com.hongchu.cbservice.service.interfaces.ai.IChatConversationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

/**
 * 会话关联服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChatConversationServiceImpl implements IChatConversationService {

    private final ChatConversationMapper chatConversationMapper;
    private final ObjectMapper objectMapper = new ObjectMapper();

    private String listToJson(List<String> list) {
        if (list == null || list.isEmpty()) return null;
        try {
            return objectMapper.writeValueAsString(list);
        } catch (JsonProcessingException e) {
            log.error("List转JSON失败: {}", e.getMessage());
            return null;
        }
    }

    private List<String> jsonToList(String json) {
        if (json == null || json.isEmpty()) return null;
        try {
            return objectMapper.readValue(json, new TypeReference<List<String>>() {});
        } catch (JsonProcessingException e) {
            log.error("JSON转List失败: {}", e.getMessage());
            return null;
        }
    }

    @Override
    public void createConversation(String conversationId, Long userId, String title) {
        ChatConversation conversation = ChatConversation.builder()
                .conversationId(conversationId)
                .userId(userId)
                .title(title != null ? title : "新对话")
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        chatConversationMapper.insert(conversation);
        log.debug("创建会话关联, conversationId: {}, userId: {}", conversationId, userId);
    }

    @Override
    public ChatConversationVO getConversation(String conversationId) {
        ChatConversation conversation = chatConversationMapper.findByConversationId(conversationId);
        return convertToVO(conversation);
    }

    @Override
    public List<ChatConversationVO> getConversationsByUserId(Long userId) {
        List<ChatConversation> conversations = chatConversationMapper.findByUserId(userId);
        return conversations.stream()
                .map(this::convertToVO)
                .toList();
    }

    @Override
    public List<String> getConversationIdsByUserId(Long userId) {
        return chatConversationMapper.findConversationIdsByUserId(userId);
    }

    @Override
    public void updateConversationTitle(String conversationId, String title) {
        ChatConversation conversation = chatConversationMapper.findByConversationId(conversationId);
        if (conversation != null) {
            conversation.setTitle(title);
            conversation.setUpdatedAt(LocalDateTime.now());
            chatConversationMapper.updateById(conversation);
            log.debug("更新会话标题, conversationId: {}, title: {}", conversationId, title);
        }
    }

    @Override
    public void updateConversationImages(String conversationId, List<String> imageUrls) {
        ChatConversation conversation = chatConversationMapper.findByConversationId(conversationId);
        if (conversation != null) {
            conversation.setImageUrlsJson(listToJson(imageUrls));
            conversation.setUpdatedAt(LocalDateTime.now());
            chatConversationMapper.updateById(conversation);
            log.debug("更新会话图片, conversationId: {}, imageCount: {}", conversationId, 
                    imageUrls != null ? imageUrls.size() : 0);
        }
    }

    @Override
    public void deleteConversation(String conversationId) {
        chatConversationMapper.deleteByMap(
                Collections.singletonMap("conversation_id", conversationId));
        log.debug("删除会话关联, conversationId: {}", conversationId);
    }

    @Override
    public void deleteConversationsByUserId(Long userId) {
        chatConversationMapper.deleteByMap(
                Collections.singletonMap("user_id", userId));
        log.debug("删除用户所有会话关联, userId: {}", userId);
    }

    @Override
    public Integer countByUserId(Long userId) {
        return chatConversationMapper.countByUserId(userId);
    }

    @Override
    public ChatConversationVO convertToVO(ChatConversation chatConversation) {
        if (chatConversation == null) return null;
        
        List<String> imageUrls = jsonToList(chatConversation.getImageUrlsJson());
        
        return ChatConversationVO.builder()
                .id(chatConversation.getId())
                .conversationId(chatConversation.getConversationId())
                .userId(chatConversation.getUserId())
                .title(chatConversation.getTitle())
                .imageUrls(imageUrls)
                .createdAt(chatConversation.getCreatedAt())
                .updatedAt(chatConversation.getUpdatedAt())
                .build();
    }
}
