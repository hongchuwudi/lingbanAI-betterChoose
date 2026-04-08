package com.hongchu.cbservice.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hongchu.cbpojo.entity.SystemNotification;
import com.hongchu.cbpojo.entity.health.MedicationRecord;
import com.hongchu.cbpojo.vo.SystemNotificationVO;
import com.hongchu.cbservice.mapper.SystemNotificationMapper;
import com.hongchu.cbservice.mapper.health.MedicationRecordMapper;
import com.hongchu.cbservice.service.interfaces.ISystemNotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class SystemNotificationServiceImpl extends ServiceImpl<SystemNotificationMapper, SystemNotification> implements ISystemNotificationService {

    private final MedicationRecordMapper medicationRecordMapper;

    @Override
    public List<SystemNotificationVO> getUnreadNotifications(Long userId) {
        List<SystemNotification> notifications = lambdaQuery()
                .eq(SystemNotification::getUserId, userId)
                .eq(SystemNotification::getStatus, 0)
                .orderByDesc(SystemNotification::getCreatedAt)
                .list();
        return notifications.stream().map(this::convertToVO).collect(Collectors.toList());
    }

    @Override
    public List<SystemNotificationVO> getAllNotifications(Long userId) {
        List<SystemNotification> notifications = lambdaQuery()
                .eq(SystemNotification::getUserId, userId)
                .orderByDesc(SystemNotification::getCreatedAt)
                .list();
        return notifications.stream().map(this::convertToVO).collect(Collectors.toList());
    }

    @Override
    public void markAsRead(Long notificationId, Long userId) {
        lambdaUpdate()
                .eq(SystemNotification::getId, notificationId)
                .eq(SystemNotification::getUserId, userId)
                .set(SystemNotification::getStatus, 1)
                .set(SystemNotification::getReadAt, LocalDateTime.now())
                .update();
    }

    @Override
    public void markAllAsRead(Long userId) {
        lambdaUpdate()
                .eq(SystemNotification::getUserId, userId)
                .eq(SystemNotification::getStatus, 0)
                .set(SystemNotification::getStatus, 1)
                .set(SystemNotification::getReadAt, LocalDateTime.now())
                .update();
    }

    @Override
    public int getUnreadCount(Long userId) {
        return lambdaQuery()
                .eq(SystemNotification::getUserId, userId)
                .eq(SystemNotification::getStatus, 0)
                .count()
                .intValue();  // Long → int
    }

    @Override
    public SystemNotification createNotification(Long userId, String type, String title, String content, String level, Long relatedId, String relatedType) {
        SystemNotification notification = SystemNotification.builder()
                .userId(userId)
                .type(type)
                .title(title)
                .content(content)
                .level(level != null ? level : "info")
                .relatedId(relatedId)
                .relatedType(relatedType)
                .status(0)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        save(notification);
        log.info("创建通知: userId={}, type={}, title={}", userId, type, title);
        return notification;
    }

    @Override
    public void createMedicationReminder(Long userId, Long recordId, String medicineName, String dosage, String scheduledTime) {
        String title = "用药提醒";
        String content = String.format("请按时服用 %s，剂量：%s", medicineName, dosage);
        
        SystemNotification notification = createNotification(
                userId,
                "medication_reminder",
                title,
                content,
                "important",
                recordId,
                "medication_record"
        );
        
        log.info("创建用药提醒通知: userId={}, recordId={}, medicine={}", userId, recordId, medicineName);
    }

    private SystemNotificationVO convertToVO(SystemNotification notification) {
        if (notification == null) return null;
        SystemNotificationVO vo = new SystemNotificationVO();
        BeanUtils.copyProperties(notification, vo);
        
        if ("medication_reminder".equals(notification.getType()) && notification.getRelatedId() != null) {
            MedicationRecord record = medicationRecordMapper.selectById(notification.getRelatedId());
            if (record != null && record.getStatus() == 0) {
                vo.setCanCheckIn(true);
            } else {
                vo.setCanCheckIn(false);
            }
        }
        
        return vo;
    }
}
