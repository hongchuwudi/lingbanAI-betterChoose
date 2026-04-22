package com.hongchu.cbpojo.vo;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.*;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FriendMessageVO {

    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;

    @JsonSerialize(using = ToStringSerializer.class)
    private Long fromUserId;

    @JsonSerialize(using = ToStringSerializer.class)
    private Long toUserId;

    private String content;
    private String messageType;
    private Integer status;
    private LocalDateTime createdAt;

    /** 是否是我发出的消息 */
    private Boolean isMine;
}
