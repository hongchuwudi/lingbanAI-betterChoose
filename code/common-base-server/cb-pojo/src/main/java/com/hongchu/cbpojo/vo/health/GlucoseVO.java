package com.hongchu.cbpojo.vo.health;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 血糖数据VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GlucoseVO {
    private BigDecimal value;
    private String type;
    private LocalDateTime recordTime;
    private String status;
}
