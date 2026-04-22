package com.hongchu.cbservice.controller;

import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.vo.ConversationVO;
import com.hongchu.cbpojo.vo.FriendMessageVO;
import com.hongchu.cbservice.service.interfaces.IFriendMessageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/message")
@RequiredArgsConstructor
public class FriendMessageController {

    private final IFriendMessageService friendMessageService;

    /** 发送消息 */
    @PostMapping("/send")
    public Result<FriendMessageVO> send(
            @RequestParam String toUserId,
            @RequestParam String content) {
        Long myId = BaseContext.getCurrentId();
        if (content == null || content.isBlank()) {
            return Result.fail("消息内容不能为空");
        }
        FriendMessageVO vo = friendMessageService.sendMessage(myId, Long.parseLong(toUserId), content);
        return Result.success(vo);
    }

    /** 会话列表 */
    @GetMapping("/conversations")
    public Result<List<ConversationVO>> conversations() {
        Long myId = BaseContext.getCurrentId();
        return Result.success(friendMessageService.getConversations(myId));
    }

    /** 与某好友的历史消息 */
    @GetMapping("/history/{friendUserId}")
    public Result<List<FriendMessageVO>> history(
            @PathVariable Long friendUserId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "50") int size) {
        Long myId = BaseContext.getCurrentId();
        List<FriendMessageVO> list = friendMessageService.getHistory(myId, friendUserId, page, size);
        // 自动标已读
        friendMessageService.markRead(myId, friendUserId);
        return Result.success(list);
    }

    /** 标记某好友消息为已读 */
    @PutMapping("/read/{friendUserId}")
    public Result<Void> markRead(@PathVariable Long friendUserId) {
        Long myId = BaseContext.getCurrentId();
        friendMessageService.markRead(myId, friendUserId);
        return Result.success();
    }

    /** 总未读数 */
    @GetMapping("/unread-count")
    public Result<Integer> unreadCount() {
        Long myId = BaseContext.getCurrentId();
        return Result.success(friendMessageService.totalUnread(myId));
    }
}
