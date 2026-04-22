package com.hongchu.cbpojo.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.*;

import java.time.LocalDateTime;

@Data
@TableName("friend_message")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FriendMessage {

    @TableId(type = IdType.AUTO)
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;

    @TableField("from_user_id")
    @JsonSerialize(using = ToStringSerializer.class)
    private Long fromUserId;

    @TableField("to_user_id")
    @JsonSerialize(using = ToStringSerializer.class)
    private Long toUserId;

    private String content;

    @TableField("message_type")
    private String messageType; // text

    /** 0: 未读  1: 已读 */
    private Integer status;

    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
