package com.hongchu.cbpojo.vo.health;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * 睡眠数据VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SleepVO {
    private BigDecimal duration;
    private Integer quality;
    private String date;
}
