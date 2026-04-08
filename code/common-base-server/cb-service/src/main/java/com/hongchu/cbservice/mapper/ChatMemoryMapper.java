package com.hongchu.cbservice.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hongchu.cbpojo.entity.ChatMemory;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

/**
 * 聊天记录Mapper接口
 * 注意：查询的是 Spring AI 的 spring_ai_chat_memory 表
 */
@Mapper
public interface ChatMemoryMapper extends BaseMapper<ChatMemory> {
    
    @Select("SELECT conversation_id as session_id, content, type as role, timestamp as created_at " +
            "FROM spring_ai_chat_memory WHERE conversation_id = #{sessionId} ORDER BY timestamp ASC")
    List<Map<String, Object>> findBySessionId(@Param("sessionId") String sessionId);
    
    @Select("SELECT conversation_id as session_id, content, type as role, timestamp as created_at " +
            "FROM spring_ai_chat_memory WHERE conversation_id = #{sessionId} ORDER BY timestamp DESC LIMIT #{limit}")
    List<Map<String, Object>> findRecentBySessionId(@Param("sessionId") String sessionId, @Param("limit") int limit);
    
    @Delete("DELETE FROM spring_ai_chat_memory WHERE conversation_id = #{sessionId}")
    void deleteBySessionId(@Param("sessionId") String sessionId);
    
    @Select("SELECT COUNT(*) FROM spring_ai_chat_memory WHERE conversation_id = #{sessionId}")
    Integer getMessageCountBySessionId(@Param("sessionId") String sessionId);
    
    @Delete("DELETE FROM spring_ai_chat_memory WHERE timestamp < NOW() - INTERVAL '${days} days'")
    void cleanOldRecords(@Param("days") int days);
}
