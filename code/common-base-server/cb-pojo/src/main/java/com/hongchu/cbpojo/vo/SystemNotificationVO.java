package com.hongchu.cbpojo.vo;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 系统通知消息视图对象
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class SystemNotificationVO {
    
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;
    
    @JsonSerialize(using = ToStringSerializer.class)
    private Long userId;
    
    private String type;
    
    private String title;
    
    private String content;
    
    private String level;
    
    @JsonSerialize(using = ToStringSerializer.class)
    private Long relatedId;
    
    private String relatedType;
    
    private Integer status;
    
    private LocalDateTime readAt;
    
    private LocalDateTime createdAt;
    
    private String medicineName;
    
    private String dosage;
    
    private String scheduledTime;
    
    private Boolean canCheckIn;
    
    private Boolean checkedIn;
}
