package com.hongchu.cbservice.service.interfaces;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hongchu.cbpojo.entity.SystemNotification;
import com.hongchu.cbpojo.vo.SystemNotificationVO;

import java.util.List;

public interface ISystemNotificationService extends IService<SystemNotification> {
    
    List<SystemNotificationVO> getUnreadNotifications(Long userId);
    
    List<SystemNotificationVO> getAllNotifications(Long userId);
    
    void markAsRead(Long notificationId, Long userId);
    
    void markAllAsRead(Long userId);
    
    int getUnreadCount(Long userId);
    
    SystemNotification createNotification(Long userId, String type, String title, String content, String level, Long relatedId, String relatedType);
    
    void createMedicationReminder(Long userId, Long recordId, String medicineName, String dosage, String scheduledTime);
}
