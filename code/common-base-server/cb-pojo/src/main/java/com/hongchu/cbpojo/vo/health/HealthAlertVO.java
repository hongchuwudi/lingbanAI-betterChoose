package com.hongchu.cbpojo.vo.health;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 健康预警VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HealthAlertVO {
    private Long id;
    private String indicatorName;
    private String indicatorCode;
    private String alertType;
    private String actualValue;
    private String normalRange;
    private Integer severity;
    private String alertTime;
}
