package com.hongchu.cbpojo.vo;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * 老人档案视图对象
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ElderlyProfileVO {
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;
    @JsonSerialize(using = ToStringSerializer.class)
    private Long userId;
    private String chronicDiseases;
    private String allergies;
    private String bloodType;
    private BigDecimal height;
    private BigDecimal weight;
    private String livingStatus;
    private String address;
    private String emergencyContact;
    private String dietRestrictions;
    private String medicalHistory;
}