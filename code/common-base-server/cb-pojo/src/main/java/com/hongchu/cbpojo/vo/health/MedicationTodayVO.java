package com.hongchu.cbpojo.vo.health;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 今日用药VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MedicationTodayVO {
    private Long id;
    private Long planId;
    private String drugName;
    private String dosage;
    private String scheduledTime;
    private Boolean taken;
}
