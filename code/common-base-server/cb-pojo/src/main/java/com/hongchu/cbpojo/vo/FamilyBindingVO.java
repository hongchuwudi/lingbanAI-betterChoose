package com.hongchu.cbpojo.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class FamilyBindingVO {
    private String id;
    private String elderlyProfileId;
    private String childProfileId;
    private String relationType;
    private String elderlyToChildRelation;
    private Integer status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    private String elderlyName;
    private String childName;
    
    private String elderlyAvatar;
    private String childAvatar;
    
    private String elderlyPhone;
    private String childPhone;
    
    private Integer elderlyGender;
    private Integer childGender;
    
    private String elderlyBirthday;
    private String childBirthday;
    
    private String myRole;
    
    // 老人档案详细信息
    private String elderlyChronicDiseases;
    private String elderlyAllergies;
    private String elderlyBloodType;
    private BigDecimal elderlyHeight;
    private BigDecimal elderlyWeight;
    private String elderlyLivingStatus;
    private String elderlyAddress;
    private String elderlyEmergencyContact;
    private String elderlyDietRestrictions;
    private String elderlyMedicalHistory;
    
    // 子女档案详细信息
    private String childGuardianSettings;
    private String childCheckinSettings;
}
