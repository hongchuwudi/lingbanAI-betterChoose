package com.hongchu.cbservice.service.interfaces;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hongchu.cbpojo.entity.health.MedicationRecord;
import com.hongchu.cbpojo.vo.MedicationRecordVO;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface IMedicationRecordService extends IService<MedicationRecord> {
    
    List<MedicationRecordVO> getTodayRecords(Long userId);
    
    List<MedicationRecordVO> getRecordsByDate(Long userId, LocalDate date);
    
    List<MedicationRecordVO> getRecordsByElderlyId(Long elderlyProfileId, LocalDate date);
    
    MedicationRecordVO checkIn(Long recordId, Long userId);
    
    MedicationRecordVO checkInByNotification(Long notificationId, Long userId);
    
    void remindElderly(Long elderlyProfileId, Long childUserId);
    
    Map<String, Object> getCheckInStats(Long userId, LocalDate startDate, LocalDate endDate);
    
    void createDailyRecords();
}
