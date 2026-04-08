package com.hongchu.cbservice.controller;

import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.vo.MedicationRecordVO;
import com.hongchu.cbservice.annotation.Role;
import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbservice.service.interfaces.IMedicationRecordService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/user/medication")
@RequiredArgsConstructor
public class MedicationController {

    private final IMedicationRecordService medicationRecordService;

    @GetMapping("/today")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<List<MedicationRecordVO>> getTodayRecords() {
        Long userId = BaseContext.getCurrentId();
        log.info("获取今日用药记录: userId={}", userId);
        return Result.success(medicationRecordService.getTodayRecords(userId));
    }

    @GetMapping("/date/{date}")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<List<MedicationRecordVO>> getRecordsByDate(
            @PathVariable @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        Long userId = BaseContext.getCurrentId();
        log.info("获取指定日期用药记录: userId={}, date={}", userId, date);
        return Result.success(medicationRecordService.getRecordsByDate(userId, date));
    }

    @GetMapping("/elderly/{elderlyProfileId}/date/{date}")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<List<MedicationRecordVO>> getElderlyRecordsByDate(
            @PathVariable Long elderlyProfileId,
            @PathVariable @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        Long userId = BaseContext.getCurrentId();
        log.info("子女查看老人用药记录: childUserId={}, elderlyProfileId={}, date={}", userId, elderlyProfileId, date);
        return Result.success(medicationRecordService.getRecordsByElderlyId(elderlyProfileId, date));
    }

    @PostMapping("/check-in/{recordId}")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<MedicationRecordVO> checkIn(@PathVariable Long recordId) {
        Long userId = BaseContext.getCurrentId();
        log.info("用药打卡: userId={}, recordId={}", userId, recordId);
        return Result.success(medicationRecordService.checkIn(recordId, userId));
    }

    @PostMapping("/check-in-by-notification/{notificationId}")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<MedicationRecordVO> checkInByNotification(@PathVariable Long notificationId) {
        Long userId = BaseContext.getCurrentId();
        log.info("通过通知打卡: userId={}, notificationId={}", userId, notificationId);
        return Result.success(medicationRecordService.checkInByNotification(notificationId, userId));
    }

    @PostMapping("/remind/{elderlyProfileId}")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<String> remindElderly(@PathVariable Long elderlyProfileId) {
        Long userId = BaseContext.getCurrentId();
        log.info("子女提醒老人服药: childUserId={}, elderlyProfileId={}", userId, elderlyProfileId);
        medicationRecordService.remindElderly(elderlyProfileId, userId);
        return Result.success("提醒已发送");
    }

    @GetMapping("/stats")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<Map<String, Object>> getCheckInStats(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate startDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate endDate) {
        Long userId = BaseContext.getCurrentId();
        log.info("获取打卡统计: userId={}, startDate={}, endDate={}", userId, startDate, endDate);
        return Result.success(medicationRecordService.getCheckInStats(userId, startDate, endDate));
    }
}
