package com.hongchu.cbpojo.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 会话关联表VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatConversationVO {

    private Long id;

    private String conversationId;

    private Long userId;

    private String title;

    private List<String> imageUrls;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}
