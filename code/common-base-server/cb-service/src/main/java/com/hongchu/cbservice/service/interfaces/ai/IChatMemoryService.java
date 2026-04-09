package com.hongchu.cbservice.service.interfaces.ai;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hongchu.cbpojo.entity.ChatMemory;
import com.hongchu.cbpojo.vo.ChatMemoryVO;

import java.util.List;

/**
 * 聊天记录服务接口
 * 注意：此服务查询 Spring AI 的 spring_ai_chat_memory 表
 */
public interface IChatMemoryService extends IService<ChatMemory> {
    // 添加聊天记录（已弃用，Spring AI 自动管理）
    void saveChatMessage(String sessionId, String role, String content, String aiModel, Integer tokenCount);
    // 获取聊天记录
    List<ChatMemoryVO> getChatHistory(String sessionId);
    // 获取最近聊天记录
    List<ChatMemoryVO> getRecentChatHistory(String sessionId, int limit);
    // 清空聊天记录
    void clearChatHistory(String sessionId);
    // 转换
    ChatMemoryVO convertToVO(ChatMemory chatMemory);
    // 转换列表
    List<ChatMemoryVO> convertToVOList(List<ChatMemory> chatMemories);
}
