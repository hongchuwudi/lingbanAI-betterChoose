package com.hongchu.cbservice.task;

import com.hongchu.cbpojo.entity.ElderlyProfile;
import com.hongchu.cbpojo.entity.health.MedicationPlan;
import com.hongchu.cbpojo.entity.health.MedicationRecord;
import com.hongchu.cbservice.mapper.ElderlyProfileMapper;
import com.hongchu.cbservice.mapper.health.MedicationPlanMapper;
import com.hongchu.cbservice.service.interfaces.IMedicationRecordService;
import com.hongchu.cbservice.service.interfaces.ISystemNotificationService;
import com.hongchu.cbservice.websocket.WebSocketUtil;
import com.hongchu.cbcommon.vo.WebSocketMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Slf4j
@Component
@RequiredArgsConstructor
public class MedicationReminderTask {

    private final IMedicationRecordService medicationRecordService;
    private final ISystemNotificationService notificationService;
    private final MedicationPlanMapper medicationPlanMapper;
    private final ElderlyProfileMapper elderlyProfileMapper;

    @Scheduled(cron = "0 0 8 * * ?")
    public void sendMorningMedicationReminder() {
        log.info("开始发送早间用药提醒...");
        sendMedicationReminders(LocalTime.of(8, 0));
    }

    @Scheduled(cron = "0 0 12 * * ?")
    public void sendNoonMedicationReminder() {
        log.info("开始发送午间用药提醒...");
        sendMedicationReminders(LocalTime.of(12, 0));
    }

    @Scheduled(cron = "0 0 18 * * ?")
    public void sendEveningMedicationReminder() {
        log.info("开始发送晚间用药提醒...");
        sendMedicationReminders(LocalTime.of(18, 0));
    }

    @Scheduled(cron = "0 5 0 * * ?")
    public void createDailyMedicationRecords() {
        log.info("开始创建每日用药记录...");
        medicationRecordService.createDailyRecords();
    }

    private void sendMedicationReminders(LocalTime time) {
        LocalDate today = LocalDate.now();
        LocalDateTime scheduledTime = today.atTime(time);
        
        List<MedicationPlan> activePlans = medicationPlanMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<MedicationPlan>()
                        .eq(MedicationPlan::getIsActive, true)
                        .le(MedicationPlan::getStartDate, today)
                        .ge(MedicationPlan::getEndDate, today)
        );
        
        for (MedicationPlan plan : activePlans) {
            List<LocalTime> times = parseTimePoints(plan.getTimePoints());
            if (times.contains(time)) {
                sendReminderToUser(plan, scheduledTime);
            }
        }
        
        log.info("用药提醒发送完成");
    }

    private void sendReminderToUser(MedicationPlan plan, LocalDateTime scheduledTime) {
        Long userId = plan.getUserId();
        
        List<MedicationRecord> records = medicationRecordService.lambdaQuery()
                .eq(MedicationRecord::getUserId, userId)
                .eq(MedicationRecord::getPlanId, plan.getId())
                .ge(MedicationRecord::getScheduledTime, scheduledTime.minusMinutes(1))
                .le(MedicationRecord::getScheduledTime, scheduledTime.plusMinutes(1))
                .list();
        
        if (records.isEmpty()) {
            MedicationRecord record = MedicationRecord.builder()
                    .userId(userId)
                    .planId(plan.getId())
                    .scheduledTime(scheduledTime)
                    .status(0)
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build();
            medicationRecordService.save(record);
            records = Collections.singletonList(record);
        }
        
        for (MedicationRecord record : records) {
            if (record.getStatus() == 0) {
                notificationService.createMedicationReminder(
                        userId,
                        record.getId(),
                        plan.getDrugName(),
                        plan.getDosage(),
                        scheduledTime.format(DateTimeFormatter.ofPattern("HH:mm"))
                );
                
                WebSocketMessage wsMessage = WebSocketMessage.medicationReminder(
                        plan.getDrugName(),
                        plan.getDosage(),
                        scheduledTime.format(DateTimeFormatter.ofPattern("HH:mm"))
                );
                wsMessage.getData().put("recordId", String.valueOf(record.getId()));
                
                WebSocketUtil.notifyUser(String.valueOf(userId), wsMessage);
                log.info("发送用药提醒: userId={}, drugName={}", userId, plan.getDrugName());
            }
        }
    }

    private List<LocalTime> parseTimePoints(String timePoints) {
        if (timePoints == null || timePoints.isEmpty()) {
            return Collections.singletonList(LocalTime.of(8, 0));
        }
        
        List<LocalTime> times = new ArrayList<>();
        String[] points = timePoints.split(",");
        
        for (String point : points) {
            point = point.trim();
            switch (point) {
                case "morning":
                    times.add(LocalTime.of(8, 0));
                    break;
                case "noon":
                    times.add(LocalTime.of(12, 0));
                    break;
                case "evening":
                    times.add(LocalTime.of(18, 0));
                    break;
                default:
                    try {
                        times.add(LocalTime.parse(point, DateTimeFormatter.ofPattern("HH:mm")));
                    } catch (Exception e) {
                        log.warn("无法解析时间点: {}", point);
                    }
            }
        }
        
        return times.isEmpty() ? Collections.singletonList(LocalTime.of(8, 0)) : times;
    }
}
