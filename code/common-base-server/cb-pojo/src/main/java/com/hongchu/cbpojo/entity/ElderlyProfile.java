package com.hongchu.cbpojo.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 老人档案表实体类
 */
@Data
@TableName("elderly_profile")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ElderlyProfile {
    
    @TableId(type = IdType.ASSIGN_ID)
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;
    
    /** 用户ID，关联users表 */
    @TableField("user_id")
    @JsonSerialize(using = ToStringSerializer.class)
    private Long userId;
    
    /** 慢性病列表，格式：["高血压","2型糖尿病"] */
    @TableField("chronic_diseases")
    private String chronicDiseases = "[]";
    
    /** 过敏史，格式：["青霉素","海鲜"] */
    private String allergies = "[]";
    
    /** 血型：A/B/AB/O/unknown */
    @TableField("blood_type")
    private String bloodType = "unk";
    
    /** 身高(cm) */
    private BigDecimal height;
    
    /** 体重(kg) */
    private BigDecimal weight;
    
    /** 居住状态：alone独居/empty_nest空巢/with_family与子女同住/community社区养老 */
    @TableField("living_status")
    private String livingStatus = "alone";
    
    /** 详细地址 */
    private String address;
    
    /** 紧急联系人，格式：{"name":"张三","phone":"138****0000","relation":"儿子"} */
    @TableField("emergency_contact")
    private String emergencyContact;
    
    /** 饮食禁忌，格式：["低盐","低糖"] */
    @TableField("diet_restrictions")
    private String dietRestrictions = "[]";
    
    /** 既往病史 */
    @TableField("medical_history")
    private String medicalHistory;
    
    /** 创建时间 */
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    /** 更新时间 */
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}