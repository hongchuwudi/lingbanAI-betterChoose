package com.hongchu.cbpojo.vo.health;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 体重数据VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WeightVO {
    private BigDecimal value;
    private BigDecimal bmi;
    private LocalDateTime recordTime;
    private String status;
}
