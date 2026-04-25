package com.hongchu.cbservice.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hongchu.cbpojo.entity.FriendMessage;
import com.hongchu.cbpojo.entity.User;
import com.hongchu.cbpojo.vo.ConversationVO;
import com.hongchu.cbpojo.vo.FriendMessageVO;
import com.hongchu.cbcommon.vo.WebSocketMessage;
import com.hongchu.cbservice.mapper.FriendMessageMapper;
import com.hongchu.cbservice.mapper.UserMapper;
import com.hongchu.cbservice.service.interfaces.IFriendMessageService;
import com.hongchu.cbservice.websocket.SimpleNotifyWS;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class FriendMessageServiceImpl extends ServiceImpl<FriendMessageMapper, FriendMessage>
        implements IFriendMessageService {

    private final UserMapper userMapper;
    private final ObjectMapper objectMapper;

    @Override
    @Transactional
    public FriendMessageVO sendMessage(Long fromUserId, Long toUserId, String content) {
        log.info("发送好友消息: fromUserId={}, toUserId={}, content={}", fromUserId, toUserId, content);
        
        FriendMessage msg = FriendMessage.builder()
                .fromUserId(fromUserId)
                .toUserId(toUserId)
                .content(content)
                .messageType("text")
                .status(0)
                .build();
        save(msg);

        // 通过 WebSocket 实时推送给接收方
        try {
            WebSocketMessage wsMsg = WebSocketMessage.chatMessage(
                    String.valueOf(fromUserId),
                    String.valueOf(toUserId),
                    content
            );
            // 补充消息 ID，方便前端去重
            wsMsg.setMessageId(String.valueOf(msg.getId()));
            User sender = userMapper.selectById(fromUserId);
            if (sender != null) {
                wsMsg.getData().put("fromNickname", sender.getNickname());
                wsMsg.getData().put("fromAvatar", sender.getAvatar() != null ? sender.getAvatar() : "");
            }
            String json = objectMapper.writeValueAsString(wsMsg);
            log.info("WebSocket 推送好友消息: toUserId={}, json={}", toUserId, json);
            SimpleNotifyWS.notifyUser(String.valueOf(toUserId), json);
            log.info("WebSocket 推送好友消息完成");
        } catch (Exception e) {
            log.error("WebSocket 推送消息失败: {}", e.getMessage(), e);
        }

        return toVO(msg, fromUserId);
    }

    @Override
    public List<ConversationVO> getConversations(Long myId) {
        List<Map<String, Object>> rows = baseMapper.findConversations(myId);
        List<ConversationVO> result = new ArrayList<>();

        for (Map<String, Object> row : rows) {
            Long friendId = ((Number) row.get("friend_id")).longValue();
            String lastContent = (String) row.get("content");
            Object ts = row.get("created_at");

            User friend = userMapper.selectById(friendId);
            if (friend == null) continue;

            int unread = baseMapper.unreadCount(myId, friendId);

            result.add(ConversationVO.builder()
                    .friendUserId(friendId)
                    .friendNickname(friend.getNickname())
                    .friendAvatar(friend.getAvatar())
                    .lastMessage(lastContent)
                    .lastMessageTime(ts instanceof java.time.LocalDateTime
                            ? (java.time.LocalDateTime) ts
                            : null)
                    .unreadCount(unread)
                    .build());
        }

        // 按最新消息时间倒序
        result.sort((a, b) -> {
            if (a.getLastMessageTime() == null) return 1;
            if (b.getLastMessageTime() == null) return -1;
            return b.getLastMessageTime().compareTo(a.getLastMessageTime());
        });

        return result;
    }

    @Override
    public List<FriendMessageVO> getHistory(Long myId, Long friendUserId, int page, int size) {
        int offset = (page - 1) * size;
        List<FriendMessage> messages = baseMapper.findHistory(myId, friendUserId, size, offset);
        return messages.stream()
                .map(m -> toVO(m, myId))
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void markRead(Long myId, Long friendUserId) {
        baseMapper.markRead(myId, friendUserId);
    }

    @Override
    public int totalUnread(Long myId) {
        return baseMapper.totalUnread(myId);
    }

    private FriendMessageVO toVO(FriendMessage m, Long myId) {
        return FriendMessageVO.builder()
                .id(m.getId())
                .fromUserId(m.getFromUserId())
                .toUserId(m.getToUserId())
                .content(m.getContent())
                .messageType(m.getMessageType())
                .status(m.getStatus())
                .createdAt(m.getCreatedAt())
                .isMine(m.getFromUserId().equals(myId))
                .build();
    }
}
