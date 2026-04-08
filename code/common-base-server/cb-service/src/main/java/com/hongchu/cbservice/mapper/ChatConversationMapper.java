package com.hongchu.cbservice.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hongchu.cbpojo.entity.ChatConversation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 会话关联表Mapper
 */
@Mapper
public interface ChatConversationMapper extends BaseMapper<ChatConversation> {

    @Select("SELECT * FROM chat_conversation WHERE conversation_id = #{conversationId}")
    ChatConversation findByConversationId(@Param("conversationId") String conversationId);

    @Select("SELECT * FROM chat_conversation WHERE user_id = #{userId} ORDER BY updated_at DESC")
    List<ChatConversation> findByUserId(@Param("userId") Long userId);

    @Select("SELECT conversation_id FROM chat_conversation WHERE user_id = #{userId} ORDER BY updated_at DESC")
    List<String> findConversationIdsByUserId(@Param("userId") Long userId);

    @Select("SELECT COUNT(*) FROM chat_conversation WHERE user_id = #{userId}")
    Integer countByUserId(@Param("userId") Long userId);
}
