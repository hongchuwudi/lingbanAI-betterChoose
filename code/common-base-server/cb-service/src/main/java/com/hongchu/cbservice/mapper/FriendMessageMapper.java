package com.hongchu.cbservice.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hongchu.cbpojo.entity.FriendMessage;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface FriendMessageMapper extends BaseMapper<FriendMessage> {

    /** 查询与某个好友的历史消息，按时间升序 */
    @Select("""
        SELECT * FROM friend_message
        WHERE (from_user_id = #{myId} AND to_user_id = #{friendId})
           OR (from_user_id = #{friendId} AND to_user_id = #{myId})
        ORDER BY created_at ASC
        LIMIT #{limit} OFFSET #{offset}
        """)
    List<FriendMessage> findHistory(@Param("myId") Long myId,
                                    @Param("friendId") Long friendId,
                                    @Param("limit") int limit,
                                    @Param("offset") int offset);

    /** 标记某好友发给我的消息为已读 */
    @Update("""
        UPDATE friend_message
        SET status = 1, updated_at = CURRENT_TIMESTAMP
        WHERE from_user_id = #{friendId} AND to_user_id = #{myId} AND status = 0
        """)
    int markRead(@Param("myId") Long myId, @Param("friendId") Long friendId);

    /** 查询我与某好友的未读数 */
    @Select("""
        SELECT COUNT(*) FROM friend_message
        WHERE from_user_id = #{friendId} AND to_user_id = #{myId} AND status = 0
        """)
    int unreadCount(@Param("myId") Long myId, @Param("friendId") Long friendId);

    /** 查询总未读数 */
    @Select("""
        SELECT COUNT(*) FROM friend_message
        WHERE to_user_id = #{myId} AND status = 0
        """)
    int totalUnread(@Param("myId") Long myId);

    /** 查询我的所有会话（每个好友的最新一条消息） */
    @Select("""
        SELECT DISTINCT ON (friend_id)
            friend_id,
            content,
            created_at
        FROM (
            SELECT
                CASE WHEN from_user_id = #{myId} THEN to_user_id ELSE from_user_id END AS friend_id,
                content,
                created_at
            FROM friend_message
            WHERE from_user_id = #{myId} OR to_user_id = #{myId}
        ) t
        ORDER BY friend_id, created_at DESC
        """)
    List<java.util.Map<String, Object>> findConversations(@Param("myId") Long myId);
}
