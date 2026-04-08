package com.hongchu.cbservice.service.impl.ai;

import jakarta.annotation.PostConstruct;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.memory.MessageWindowChatMemory;
import org.springframework.ai.chat.memory.repository.jdbc.JdbcChatMemoryRepository;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ChatMemoryService {
    @Qualifier("openAiChatModel")
    @Autowired private ChatModel chatModel;
    @Autowired private JdbcChatMemoryRepository chatMemoryRepository;
    private ChatMemory chatMemory;

    @PostConstruct
    public void init() {
        this.chatMemory = MessageWindowChatMemory.builder()
                .chatMemoryRepository(chatMemoryRepository)
                .maxMessages(20)  // 限制消息窗口大小
                .build();
    }

    public String call(String message, String conversationId) {
        // 1. 创建用户消息
        UserMessage userMessage = new UserMessage(message);
        
        // 2. 存储用户消息到 memory
        this.chatMemory.add(conversationId, userMessage);
        
        // 3. 从 memory 获取对话历史
        List<Message> messages = chatMemory.get(conversationId);
        
        // 4. 调用 ChatModel 生成响应
        ChatResponse response = chatModel.call(new Prompt(messages));
        
        // 5. 存储 AI 响应到 memory
        chatMemory.add(conversationId, response.getResult().getOutput());

        return response.getResult().getOutput().getText();
    }
}