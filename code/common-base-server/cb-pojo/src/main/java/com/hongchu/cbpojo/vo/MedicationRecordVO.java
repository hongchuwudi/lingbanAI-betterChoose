package com.hongchu.cbpojo.vo;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class MedicationRecordVO {
    
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;
    
    @JsonSerialize(using = ToStringSerializer.class)
    private Long userId;
    
    @JsonSerialize(using = ToStringSerializer.class)
    private Long planId;
    
    private LocalDateTime scheduledTime;
    
    private LocalDateTime actualTime;
    
    private Integer status;
    
    private String remark;
    
    private LocalDateTime createdAt;
    
    private String drugName;
    
    private String dosage;
    
    private String frequency;
    
    private String timePoints;
    
    private String instruction;
    
    private String userName;
    
    private String userAvatar;
    
    private Long notificationId;
}
