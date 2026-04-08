package com.hongchu.cbpojo.vo.health;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 血压数据VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BloodPressureVO {
    private Integer systolic;
    private Integer diastolic;
    private Integer pulse;
    private LocalDateTime recordTime;
    private String status;
}
