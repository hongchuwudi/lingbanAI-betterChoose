package com.hongchu.cbservice.repository;

import java.util.List;

public interface ChatHistoryRepository {

    /**
     * 保存回话记录
     * @param chatId 绘画id
     * @param type 回复类型 chat service pdf
     */
    void save(String chatId, String type);

    /**
     * 获取会话列表
     * @param type 聊天类型
     * @return List-ids>
     */
    List<String> getChatIds(String type);
}
