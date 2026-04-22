package com.hongchu.cbservice.service.interfaces;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hongchu.cbpojo.entity.FriendMessage;
import com.hongchu.cbpojo.vo.ConversationVO;
import com.hongchu.cbpojo.vo.FriendMessageVO;

import java.util.List;

public interface IFriendMessageService extends IService<FriendMessage> {

    /** 发送消息，保存 DB 并推送 WebSocket */
    FriendMessageVO sendMessage(Long fromUserId, Long toUserId, String content);

    /** 会话列表（每个好友最新一条消息 + 未读数） */
    List<ConversationVO> getConversations(Long myId);

    /** 与某好友的历史消息 */
    List<FriendMessageVO> getHistory(Long myId, Long friendUserId, int page, int size);

    /** 标记某好友发的消息为已读 */
    void markRead(Long myId, Long friendUserId);

    /** 总未读消息数 */
    int totalUnread(Long myId);
}
