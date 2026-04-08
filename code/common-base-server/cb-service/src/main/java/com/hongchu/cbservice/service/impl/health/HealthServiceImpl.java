package com.hongchu.cbservice.service.impl.health;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hongchu.cbpojo.entity.health.*;
import com.hongchu.cbpojo.vo.health.*;
import com.hongchu.cbservice.mapper.health.*;
import com.hongchu.cbservice.service.interfaces.health.IHealthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * 健康服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class HealthServiceImpl implements IHealthService {
    
    private final BloodPressureRecordMapper bpMapper;
    private final GlucoseRecordMapper glucoseMapper;
    private final HeartRateRecordMapper heartRateMapper;
    private final WeightRecordMapper weightMapper;
    private final Spo2RecordMapper spo2Mapper;
    private final StepRecordMapper stepMapper;
    private final SleepRecordMapper sleepMapper;
    private final MedicationPlanMapper medicationPlanMapper;
    private final MedicationRecordMapper medicationRecordMapper;
    private final HealthAlertMapper alertMapper;
    private final ObjectMapper objectMapper = new ObjectMapper();
    
    private static final int STEP_GOAL = 8000;
    
    @Override
    public HealthDashboardVO getDashboard(Long userId) {
        HealthDashboardVO dashboard = new HealthDashboardVO();
        
        dashboard.setBp(getBloodPressureVO(userId));
        dashboard.setGlucose(getGlucoseVO(userId));
        dashboard.setHeartRate(getHeartRateVO(userId));
        dashboard.setWeight(getWeightVO(userId));
        dashboard.setSpo2(getSpo2VO(userId));
        dashboard.setSteps(getStepVO(userId));
        dashboard.setSleep(getSleepVO(userId));
        dashboard.setAlerts(getAlertVOs(userId));
        dashboard.setMedications(getMedicationVOs(userId));
        
        return dashboard;
    }
    
    private BloodPressureVO getBloodPressureVO(Long userId) {
        BloodPressureRecord record = bpMapper.findLatestByUserId(userId);
        if (record == null) return null;
        
        String status = evaluateBloodPressure(record.getSystolic(), record.getDiastolic());
        
        return BloodPressureVO.builder()
                .systolic(record.getSystolic())
                .diastolic(record.getDiastolic())
                .pulse(record.getPulse())
                .recordTime(record.getRecordTime())
                .status(status)
                .build();
    }
    
    private GlucoseVO getGlucoseVO(Long userId) {
        GlucoseRecord record = glucoseMapper.findLatestByUserId(userId);
        if (record == null) return null;
        
        String status = evaluateGlucose(record.getValue(), record.getType());
        
        return GlucoseVO.builder()
                .value(record.getValue())
                .type(record.getType())
                .recordTime(record.getRecordTime())
                .status(status)
                .build();
    }
    
    private HeartRateVO getHeartRateVO(Long userId) {
        HeartRateRecord record = heartRateMapper.findLatestByUserId(userId);
        if (record == null) return null;
        
        String status = evaluateHeartRate(record.getValue());
        
        return HeartRateVO.builder()
                .value(record.getValue())
                .recordTime(record.getRecordTime())
                .status(status)
                .build();
    }
    
    private WeightVO getWeightVO(Long userId) {
        WeightRecord record = weightMapper.findLatestByUserId(userId);
        if (record == null) return null;
        
        String status = "normal";
        
        return WeightVO.builder()
                .value(record.getWeight())
                .bmi(record.getBmi())
                .recordTime(record.getRecordTime())
                .status(status)
                .build();
    }
    
    private Spo2VO getSpo2VO(Long userId) {
        Spo2Record record = spo2Mapper.findLatestByUserId(userId);
        if (record == null) return null;
        
        String status = record.getValue() >= 95 ? "normal" : (record.getValue() >= 90 ? "warning" : "danger");
        
        return Spo2VO.builder()
                .value(record.getValue())
                .recordTime(record.getRecordTime())
                .status(status)
                .build();
    }
    
    private StepVO getStepVO(Long userId) {
        LocalDate today = LocalDate.now();
        StepRecord record = stepMapper.findByUserIdAndDate(userId, today);
        if (record == null) return null;
        
        int steps = record.getSteps();
        BigDecimal percentage = BigDecimal.valueOf(steps)
                .multiply(BigDecimal.valueOf(100))
                .divide(BigDecimal.valueOf(STEP_GOAL), 1, RoundingMode.HALF_UP);
        
        return StepVO.builder()
                .count(steps)
                .goal(STEP_GOAL)
                .percentage(percentage)
                .date(today.toString())
                .build();
    }
    
    private SleepVO getSleepVO(Long userId) {
        LocalDate yesterday = LocalDate.now().minusDays(1);
        SleepRecord record = sleepMapper.findByUserIdAndDate(userId, yesterday);
        if (record == null) return null;
        
        return SleepVO.builder()
                .duration(record.getSleepDuration())
                .quality(record.getSleepQuality())
                .date(yesterday.toString())
                .build();
    }
    
    private List<HealthAlertVO> getAlertVOs(Long userId) {
        List<HealthAlert> alerts = alertMapper.findUnhandledByUserId(userId, 5);
        List<HealthAlertVO> result = new ArrayList<>();
        
        for (HealthAlert alert : alerts) {
            result.add(HealthAlertVO.builder()
                    .id(alert.getId())
                    .indicatorCode(alert.getIndicatorCode())
                    .indicatorName(getIndicatorName(alert.getIndicatorCode()))
                    .alertType(alert.getAlertType())
                    .actualValue(alert.getActualValue() != null ? alert.getActualValue().toString() : "")
                    .normalRange(alert.getNormalRange())
                    .severity(alert.getSeverity())
                    .alertTime(alert.getAlertTime() != null ? 
                            alert.getAlertTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "")
                    .build());
        }
        
        return result;
    }
    
    private List<MedicationTodayVO> getMedicationVOs(Long userId) {
        List<MedicationTodayVO> result = new ArrayList<>();
        
        List<MedicationPlan> plans = medicationPlanMapper.findActiveByUserId(userId);
        if (plans.isEmpty()) return result;
        
        LocalDate today = LocalDate.now();
        LocalDateTime startOfDay = today.atStartOfDay();
        LocalDateTime endOfDay = today.plusDays(1).atStartOfDay();
        
        List<MedicationRecord> todayRecords = medicationRecordMapper.findByUserIdAndTimeRange(userId, startOfDay, endOfDay);
        
        for (MedicationPlan plan : plans) {
            List<String> timePoints = parseTimePoints(plan.getTimePoints());
            
            for (String timePoint : timePoints) {
                LocalTime time = LocalTime.parse(timePoint);
                LocalDateTime scheduledTime = today.atTime(time);
                
                MedicationRecord matchedRecord = todayRecords.stream()
                        .filter(r -> r.getPlanId() != null && 
                                r.getPlanId().equals(plan.getId()) && 
                                r.getScheduledTime() != null &&
                                r.getScheduledTime().toLocalDate().equals(today) &&
                                r.getScheduledTime().toLocalTime().truncatedTo(java.time.temporal.ChronoUnit.MINUTES).equals(time))
                        .findFirst()
                        .orElse(null);
                
                if (matchedRecord == null) {
                    matchedRecord = MedicationRecord.builder()
                            .userId(userId)
                            .planId(plan.getId())
                            .scheduledTime(scheduledTime)
                            .status(0)
                            .createdAt(LocalDateTime.now())
                            .updatedAt(LocalDateTime.now())
                            .build();
                    medicationRecordMapper.insert(matchedRecord);
                }
                
                boolean taken = matchedRecord.getStatus() == 1;
                
                result.add(MedicationTodayVO.builder()
                        .id(matchedRecord.getId())
                        .planId(plan.getId())
                        .drugName(plan.getDrugName())
                        .dosage(plan.getDosage())
                        .scheduledTime(timePoint)
                        .taken(taken)
                        .build());
            }
        }
        
        result.sort((a, b) -> a.getScheduledTime().compareTo(b.getScheduledTime()));
        
        return result;
    }
    
    private String evaluateBloodPressure(Integer systolic, Integer diastolic) {
        if (systolic == null || diastolic == null) return "unknown";
        
        if (systolic < 90 || diastolic < 60) return "low";
        if (systolic >= 140 || diastolic >= 90) return "high";
        if (systolic >= 120 || diastolic >= 80) return "elevated";
        return "normal";
    }
    
    private String evaluateGlucose(BigDecimal value, String type) {
        if (value == null) return "unknown";
        
        double v = value.doubleValue();
        
        if ("fasting".equals(type)) {
            if (v < 3.9) return "low";
            if (v > 6.1) return "high";
            return "normal";
        } else {
            if (v < 3.9) return "low";
            if (v > 11.1) return "high";
            return "normal";
        }
    }
    
    private String evaluateHeartRate(Integer value) {
        if (value == null) return "unknown";
        
        if (value < 60) return "low";
        if (value > 100) return "high";
        return "normal";
    }
    
    private String getIndicatorName(String code) {
        return switch (code) {
            case "bp_systolic" -> "收缩压";
            case "bp_diastolic" -> "舒张压";
            case "glucose" -> "血糖";
            case "heart_rate" -> "心率";
            case "spo2" -> "血氧";
            case "weight" -> "体重";
            default -> code;
        };
    }
    
    private List<String> parseTimePoints(String timePoints) {
        if (timePoints == null || timePoints.isEmpty()) {
            return List.of();
        }
        
        try {
            return objectMapper.readValue(timePoints, new TypeReference<List<String>>() {});
        } catch (JsonProcessingException e) {
            log.error("解析用药时间点失败: {}", e.getMessage());
            return List.of();
        }
    }
}
