package com.hongchu.cbpojo.vo.health;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 血氧数据VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Spo2VO {
    private Integer value;
    private LocalDateTime recordTime;
    private String status;
}
