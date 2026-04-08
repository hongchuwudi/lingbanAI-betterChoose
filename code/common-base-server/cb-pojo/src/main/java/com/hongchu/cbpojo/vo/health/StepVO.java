package com.hongchu.cbpojo.vo.health;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * 步数数据VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StepVO {
    private Integer count;
    private Integer goal;
    private BigDecimal percentage;
    private String date;
}
