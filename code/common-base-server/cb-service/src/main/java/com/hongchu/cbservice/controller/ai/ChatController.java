package com.hongchu.cbservice.controller.ai;

import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbservice.service.interfaces.ai.IChatConversationService;
import com.hongchu.cbservice.service.interfaces.ai.IChatFileService;
import com.hongchu.cbservice.service.interfaces.ai.IChatMemoryService;
import com.hongchu.cbservice.service.interfaces.auth.IJwtService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.content.Media;
import org.springframework.core.io.UrlResource;
import org.springframework.http.MediaType;
import org.springframework.util.MimeType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Flux;

import java.net.MalformedURLException;
import java.util.List;
import java.util.Objects;

/**
 * AI聊天控制器
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/ai")
@Slf4j
public class ChatController {
    private final ChatClient chatClient;
    private final ChatMemory chatMemory;
    private final IChatConversationService chatConversationService;
    private final IChatFileService chatFileService;
    private final IJwtService jwtService;

    @PostMapping(value = "/chat", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<String> chat(
            @RequestParam("prompt") String prompt,
            @RequestParam("chatId") String chatId,
            @RequestParam(value = "files", required = false) List<MultipartFile> files,
            HttpServletRequest request) {
        log.info("开始聊天处理, chatId: {}, prompt: {}, files: {}", chatId, prompt, files);
        
        Long userId = extractUserId(request);
        log.info("当前用户ID: {}", userId);
        
        List<String> imageUrls = chatFileService.uploadImages(files, userId);
        
        if (userId != null) {
            ensureConversationExists(chatId, userId, prompt);
            if (imageUrls != null && !imageUrls.isEmpty()) {
                chatConversationService.updateConversationImages(chatId, imageUrls);
            }
        }

        if (files != null && !files.isEmpty()) {
            return MultipartFileChat(prompt, chatId, files, imageUrls);
        } else {
            return textChat(prompt, chatId);
        }
    }

    private Long extractUserId(HttpServletRequest request) {
        Long userId = BaseContext.getCurrentId();
        if (userId == null) {
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                try {
                    userId = jwtService.getUserId(authHeader.substring(7));
                    log.debug("从Token中提取用户ID: {}", userId);
                } catch (Exception e) {
                    log.error("解析Token失败: {}", e.getMessage());
                }
            }
        }
        return userId;
    }

    private void ensureConversationExists(String chatId, Long userId, String prompt) {
        if (chatConversationService.getConversation(chatId) == null) {
            String title = prompt.length() > 20 ? prompt.substring(0, 20) + "..." : prompt;
            chatConversationService.createConversation(chatId, userId, title);
            log.debug("创建会话关联, chatId: {}, userId: {}", chatId, userId);
        }
    }

    private Flux<String> MultipartFileChat(String prompt, String chatId, List<MultipartFile> files, 
                                           List<String> imageUrls) {
        List<Media> medias = new java.util.ArrayList<>();
        
        if (imageUrls != null && !imageUrls.isEmpty()) {
            for (String imageUrl : imageUrls) {
                try {
                    UrlResource urlResource = new UrlResource(imageUrl);
                    Media media = new Media(MimeType.valueOf("image/jpeg"), urlResource);
                    medias.add(media);
                    log.info("添加图片URL到AI请求: {}", imageUrl);
                } catch (MalformedURLException e) {
                    log.error("创建图片Media失败, URL格式错误: {}", e.getMessage());
                }
            }
        }
        
        StringBuilder fullResponse = new StringBuilder();
        return chatClient.prompt()
                .user(p -> {
                    p.text(prompt);
                    if (!medias.isEmpty()) {
                        p.media(medias.toArray(Media[]::new));
                    }
                })
                .advisors(a -> a.param(ChatMemory.CONVERSATION_ID, chatId))
                .stream()
                .content()
                .doOnNext(fullResponse::append)
                .doOnComplete(() -> log.debug("AI响应完成, chatId: {}, length: {}", chatId, fullResponse.length()))
                .doOnError(error -> log.error("聊天出错: {}", error.getMessage()));
    }

    private Flux<String> textChat(String prompt, String chatId) {
        StringBuilder fullResponse = new StringBuilder();
        return chatClient.prompt()
                .user(prompt)
                .advisors(a -> a.param(ChatMemory.CONVERSATION_ID, chatId))
                .stream()
                .content()
                .doOnNext(fullResponse::append)
                .doOnComplete(() -> log.debug("AI响应完成, chatId: {}, length: {}", chatId, fullResponse.length()))
                .doOnError(error -> log.error("聊天出错: {}", error.getMessage()));
    }
}
