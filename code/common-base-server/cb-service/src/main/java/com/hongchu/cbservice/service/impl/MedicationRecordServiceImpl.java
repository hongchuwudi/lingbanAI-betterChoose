package com.hongchu.cbservice.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hongchu.cbcommon.exception.BusinessException;
import com.hongchu.cbcommon.vo.WebSocketMessage;
import com.hongchu.cbpojo.entity.ElderlyProfile;
import com.hongchu.cbpojo.entity.SystemNotification;
import com.hongchu.cbpojo.entity.User;
import com.hongchu.cbpojo.entity.health.MedicationPlan;
import com.hongchu.cbpojo.entity.health.MedicationRecord;
import com.hongchu.cbpojo.vo.MedicationRecordVO;
import com.hongchu.cbservice.mapper.ElderlyProfileMapper;
import com.hongchu.cbservice.mapper.UserMapper;
import com.hongchu.cbservice.mapper.health.MedicationPlanMapper;
import com.hongchu.cbservice.mapper.health.MedicationRecordMapper;
import com.hongchu.cbservice.service.interfaces.IMedicationRecordService;
import com.hongchu.cbservice.service.interfaces.ISystemNotificationService;
import com.hongchu.cbservice.websocket.WebSocketUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class MedicationRecordServiceImpl extends ServiceImpl<MedicationRecordMapper, MedicationRecord> implements IMedicationRecordService {

    private final MedicationPlanMapper medicationPlanMapper;
    private final ElderlyProfileMapper elderlyProfileMapper;
    private final UserMapper usersMapper;
    private final ISystemNotificationService notificationService;

    @Override
    public List<MedicationRecordVO> getTodayRecords(Long userId) {
        return getRecordsByDate(userId, LocalDate.now());
    }

    @Override
    public List<MedicationRecordVO> getRecordsByDate(Long userId, LocalDate date) {
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.atTime(LocalTime.MAX);
        
        List<MedicationRecord> records = lambdaQuery()
                .eq(MedicationRecord::getUserId, userId)
                .ge(MedicationRecord::getScheduledTime, startOfDay)
                .le(MedicationRecord::getScheduledTime, endOfDay)
                .orderByAsc(MedicationRecord::getScheduledTime)
                .list();
        
        return records.stream().map(this::convertToVO).collect(Collectors.toList());
    }

    @Override
    public List<MedicationRecordVO> getRecordsByElderlyId(Long elderlyProfileId, LocalDate date) {
        ElderlyProfile elderlyProfile = elderlyProfileMapper.selectById(elderlyProfileId);
        if (elderlyProfile == null) {
            throw new BusinessException("老人档案不存在");
        }
        
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.atTime(LocalTime.MAX);
        
        List<MedicationRecord> records = lambdaQuery()
                .eq(MedicationRecord::getUserId, elderlyProfile.getUserId())
                .ge(MedicationRecord::getScheduledTime, startOfDay)
                .le(MedicationRecord::getScheduledTime, endOfDay)
                .orderByAsc(MedicationRecord::getScheduledTime)
                .list();
        
        return records.stream().map(this::convertToVO).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public MedicationRecordVO checkIn(Long recordId, Long userId) {
        MedicationRecord record = getById(recordId);
        if (record == null) {
            throw new BusinessException("用药记录不存在");
        }
        if (!record.getUserId().equals(userId)) {
            throw new BusinessException("无权操作此记录");
        }
        if (record.getStatus() == 1) {
            throw new BusinessException("该记录已打卡");
        }
        
        record.setStatus(1);
        record.setActualTime(LocalDateTime.now());
        record.setUpdatedAt(LocalDateTime.now());
        updateById(record);
        
        log.info("用药打卡成功: userId={}, recordId={}", userId, recordId);
        return convertToVO(record);
    }

    @Override
    @Transactional
    public MedicationRecordVO checkInByNotification(Long notificationId, Long userId) {
        SystemNotification notification = notificationService.getById(notificationId);
        if (notification == null || !"medication_reminder".equals(notification.getType())) {
            throw new BusinessException("通知不存在或类型不正确");
        }
        if (!notification.getUserId().equals(userId)) {
            throw new BusinessException("无权操作此通知");
        }
        
        Long recordId = notification.getRelatedId();
        if (recordId == null) {
            throw new BusinessException("关联的用药记录不存在");
        }
        
        MedicationRecordVO vo = checkIn(recordId, userId);
        
        notificationService.markAsRead(notificationId, userId);
        
        return vo;
    }

    @Override
    public void remindElderly(Long elderlyProfileId, Long childUserId) {
        ElderlyProfile elderlyProfile = elderlyProfileMapper.selectById(elderlyProfileId);
        if (elderlyProfile == null) {
            throw new BusinessException("老人档案不存在");
        }
        
        User child = usersMapper.selectById(childUserId);
        String childName = child != null ? child.getNickname() : "您的家人";
        
        String title = "用药提醒";
        String content = childName + " 提醒您按时服药";
        
        SystemNotification notification = notificationService.createNotification(
                elderlyProfile.getUserId(),
                "medication_remind_from_child",
                title,
                content,
                "important",
                null,
                null
        );
        
        WebSocketMessage wsMessage = WebSocketMessage.builder()
                .type("medication_remind_from_child")
                .data(Map.of(
                    "title", title,
                    "content", content,
                    "notificationId", String.valueOf(notification.getId())
                ))
                .timestamp(System.currentTimeMillis())
                .build();
        
        WebSocketUtil.notifyUser(String.valueOf(elderlyProfile.getUserId()), wsMessage);
        log.info("子女提醒老人服药: childUserId={}, elderlyUserId={}", childUserId, elderlyProfile.getUserId());
    }

    @Override
    public Map<String, Object> getCheckInStats(Long userId, LocalDate startDate, LocalDate endDate) {
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end = endDate.atTime(LocalTime.MAX);
        
        List<MedicationRecord> records = lambdaQuery()
                .eq(MedicationRecord::getUserId, userId)
                .ge(MedicationRecord::getScheduledTime, start)
                .le(MedicationRecord::getScheduledTime, end)
                .list();
        
        long total = records.size();
        long checkedIn = records.stream().filter(r -> r.getStatus() == 1).count();
        long missed = records.stream().filter(r -> r.getStatus() == 0 && r.getScheduledTime().isBefore(LocalDateTime.now())).count();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", total);
        stats.put("checkedIn", checkedIn);
        stats.put("missed", missed);
        stats.put("checkInRate", total > 0 ? (double) checkedIn / total * 100 : 0);
        
        return stats;
    }

    @Override
    @Transactional
    public void createDailyRecords() {
        log.info("开始创建每日用药记录...");
        
        LocalDate today = LocalDate.now();
        LocalTime morningTime = LocalTime.of(8, 0);
        LocalTime noonTime = LocalTime.of(12, 0);
        LocalTime eveningTime = LocalTime.of(18, 0);
        
        List<MedicationPlan> activePlans = medicationPlanMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<MedicationPlan>()
                        .eq(MedicationPlan::getIsActive, true)
                        .le(MedicationPlan::getStartDate, today)
                        .ge(MedicationPlan::getEndDate, today)
        );
        
        for (MedicationPlan plan : activePlans) {
            List<LocalTime> times = parseTimePoints(plan.getTimePoints());
            
            for (LocalTime time : times) {
                LocalDateTime scheduledTime = today.atTime(time);
                
                Long existingCount = lambdaQuery()
                        .eq(MedicationRecord::getUserId, plan.getUserId())
                        .eq(MedicationRecord::getPlanId, plan.getId())
                        .eq(MedicationRecord::getScheduledTime, scheduledTime)
                        .count();
                
                if (existingCount == 0) {
                    MedicationRecord record = MedicationRecord.builder()
                            .userId(plan.getUserId())
                            .planId(plan.getId())
                            .scheduledTime(scheduledTime)
                            .status(0)
                            .createdAt(LocalDateTime.now())
                            .updatedAt(LocalDateTime.now())
                            .build();
                    save(record);
                    log.info("创建用药记录: userId={}, planId={}, scheduledTime={}", 
                            plan.getUserId(), plan.getId(), scheduledTime);
                }
            }
        }
        
        log.info("每日用药记录创建完成，共处理 {} 个用药计划", activePlans.size());
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

    private MedicationRecordVO convertToVO(MedicationRecord record) {
        if (record == null) return null;
        MedicationRecordVO vo = new MedicationRecordVO();
        BeanUtils.copyProperties(record, vo);
        
        if (record.getPlanId() != null) {
            MedicationPlan plan = medicationPlanMapper.selectById(record.getPlanId());
            if (plan != null) {
                vo.setDrugName(plan.getDrugName());
                vo.setDosage(plan.getDosage());
                vo.setFrequency(plan.getFrequency());
                vo.setTimePoints(plan.getTimePoints());
                vo.setInstruction(plan.getInstruction());
            }
        }
        
        User user = usersMapper.selectById(record.getUserId());
        if (user != null) {
            vo.setUserName(user.getNickname());
            vo.setUserAvatar(user.getAvatar());
        }
        
        return vo;
    }
}
