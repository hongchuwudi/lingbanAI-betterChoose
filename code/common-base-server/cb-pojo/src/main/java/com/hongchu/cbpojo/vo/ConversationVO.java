package com.hongchu.cbpojo.vo;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.*;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConversationVO {

    /** 对方 userId */
    @JsonSerialize(using = ToStringSerializer.class)
    private Long friendUserId;

    private String friendNickname;
    private String friendAvatar;

    /** 最新一条消息内容 */
    private String lastMessage;

    private LocalDateTime lastMessageTime;

    /** 未读数量 */
    private Integer unreadCount;
}
