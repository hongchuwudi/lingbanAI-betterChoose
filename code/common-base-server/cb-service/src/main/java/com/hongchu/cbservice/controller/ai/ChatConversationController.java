package com.hongchu.cbservice.controller.ai;

import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.vo.ChatConversationVO;
import com.hongchu.cbservice.service.interfaces.ai.IChatConversationService;
import com.hongchu.cbservice.service.interfaces.auth.IJwtService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 会话管理控制器
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/ai/conversation")
@Slf4j
public class ChatConversationController {

    private final IChatConversationService chatConversationService;
    private final IJwtService jwtService;

    @GetMapping("/list")
    public Result<List<ChatConversationVO>> getConversationList(HttpServletRequest request) {
        Long userId = extractUserId(request);
        if (userId == null) {
            return Result.fail("用户未登录");
        }
        List<ChatConversationVO> conversations = chatConversationService.getConversationsByUserId(userId);
        log.debug("获取用户会话列表, userId: {}, count: {}", userId, conversations.size());
        return Result.success(conversations);
    }

    @GetMapping("/{conversationId}")
    public Result<ChatConversationVO> getConversation(
            @PathVariable String conversationId,
            HttpServletRequest request) {
        Long userId = extractUserId(request);
        ChatConversationVO conversation = chatConversationService.getConversation(conversationId);
        if (conversation == null) {
            return Result.fail("会话不存在");
        }
        if (userId != null && !userId.equals(conversation.getUserId())) {
            return Result.fail("无权访问该会话");
        }
        return Result.success(conversation);
    }

    @DeleteMapping("/{conversationId}")
    public Result<Void> deleteConversation(
            @PathVariable String conversationId,
            HttpServletRequest request) {
        Long userId = extractUserId(request);
        if (userId == null) {
            return Result.fail("用户未登录");
        }
        ChatConversationVO conversation = chatConversationService.getConversation(conversationId);
        if (conversation == null) {
            return Result.fail("会话不存在");
        }
        if (!userId.equals(conversation.getUserId())) {
            return Result.fail("无权删除该会话");
        }
        chatConversationService.deleteConversation(conversationId);
        log.info("删除会话, conversationId: {}, userId: {}", conversationId, userId);
        return Result.success();
    }

    @PutMapping("/{conversationId}/title")
    public Result<Void> updateTitle(
            @PathVariable String conversationId,
            @RequestParam String title,
            HttpServletRequest request) {
        Long userId = extractUserId(request);
        if (userId == null) {
            return Result.fail("用户未登录");
        }
        ChatConversationVO conversation = chatConversationService.getConversation(conversationId);
        if (conversation == null) {
            return Result.fail("会话不存在");
        }
        if (!userId.equals(conversation.getUserId())) {
            return Result.fail("无权修改该会话");
        }
        chatConversationService.updateConversationTitle(conversationId, title);
        log.info("更新会话标题, conversationId: {}, title: {}", conversationId, title);
        return Result.success();
    }

    @GetMapping("/count")
    public Result<Integer> getConversationCount(HttpServletRequest request) {
        Long userId = extractUserId(request);
        if (userId == null) {
            return Result.fail("用户未登录");
        }
        Integer count = chatConversationService.countByUserId(userId);
        return Result.success(count);
    }

    private Long extractUserId(HttpServletRequest request) {
        Long userId = BaseContext.getCurrentId();
        if (userId == null) {
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                try {
                    userId = jwtService.getUserId(authHeader.substring(7));
                } catch (Exception e) {
                    log.error("解析Token失败: {}", e.getMessage());
                }
            }
        }
        return userId;
    }
}
