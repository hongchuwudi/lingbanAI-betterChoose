package com.hongchu.cbservice.service.interfaces.ai;

import com.hongchu.cbpojo.entity.ChatConversation;
import com.hongchu.cbpojo.vo.ChatConversationVO;

import java.util.List;

/**
 * 会话关联服务接口
 */
public interface IChatConversationService {

    void createConversation(String conversationId, Long userId, String title);

    ChatConversationVO getConversation(String conversationId);

    List<ChatConversationVO> getConversationsByUserId(Long userId);

    List<String> getConversationIdsByUserId(Long userId);

    void updateConversationTitle(String conversationId, String title);

    void updateConversationImages(String conversationId, List<String> imageUrls);

    void deleteConversation(String conversationId);

    void deleteConversationsByUserId(Long userId);

    Integer countByUserId(Long userId);

    ChatConversationVO convertToVO(ChatConversation chatConversation);
}
