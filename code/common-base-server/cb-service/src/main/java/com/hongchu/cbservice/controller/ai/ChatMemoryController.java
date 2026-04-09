package com.hongchu.cbservice.controller.ai;

import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.vo.ChatMemoryVO;
import com.hongchu.cbservice.service.interfaces.ai.IChatMemoryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 聊天记录管理控制器
 * 注意：此控制器用于业务扩展，Spring AI 的对话历史由 ChatConversationController 管理
 */
@Slf4j
@RestController
@RequestMapping("/chat-memory")
@CrossOrigin
@RequiredArgsConstructor
public class ChatMemoryController {
    
    private final IChatMemoryService chatMemoryService;
    
    @GetMapping("/history/session/{sessionId}")
    public Result<List<ChatMemoryVO>> getChatHistoryBySessionId(
            @PathVariable String sessionId,
            @RequestParam(required = false, defaultValue = "0") int limit) {
        log.info("获取会话聊天记录: 会话ID={}, 限制条数={}", sessionId, limit);
        List<ChatMemoryVO> history;
        if (limit > 0) {
            history = chatMemoryService.getRecentChatHistory(sessionId, limit);
        } else {
            history = chatMemoryService.getChatHistory(sessionId);
        }
        return Result.success(history);
    }
    
    @DeleteMapping("/session/{sessionId}")
    public Result<Void> deleteBySessionId(@PathVariable String sessionId) {
        log.info("删除会话聊天记录: 会话ID={}", sessionId);
        chatMemoryService.clearChatHistory(sessionId);
        return Result.success();
    }

    @PostMapping("/update-tts-url")
    public Result<Void> updateTtsUrl(
            @RequestParam("sessionId") String sessionId,
            @RequestParam("ttsAudioUrl") String ttsAudioUrl) {
        log.info("更新会话TTS音频URL: 会话ID={}, URL={}", sessionId, ttsAudioUrl);
        chatMemoryService.updateLastAssistantTtsUrl(sessionId, ttsAudioUrl);
        return Result.success();
    }
}
