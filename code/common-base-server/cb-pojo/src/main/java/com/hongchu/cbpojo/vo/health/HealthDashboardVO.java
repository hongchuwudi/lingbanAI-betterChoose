package com.hongchu.cbpojo.vo.health;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 健康看板数据VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HealthDashboardVO {
    
    private BloodPressureVO bp;
    
    private GlucoseVO glucose;
    
    private HeartRateVO heartRate;
    
    private WeightVO weight;
    
    private Spo2VO spo2;
    
    private StepVO steps;
    
    private SleepVO sleep;
    
    private List<HealthAlertVO> alerts;
    
    private List<MedicationTodayVO> medications;
}
