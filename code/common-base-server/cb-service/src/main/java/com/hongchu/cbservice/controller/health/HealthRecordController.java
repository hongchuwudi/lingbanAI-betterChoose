package com.hongchu.cbservice.controller.health;

import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbservice.annotation.Role;
import com.hongchu.cbservice.service.interfaces.health.IHealthRecordService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/health/record")
@RequiredArgsConstructor
public class HealthRecordController {

    private final IHealthRecordService healthRecordService;

    @PostMapping
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<String> saveHealthRecord(@RequestBody Map<String, Object> data) {
        Long userId = BaseContext.getCurrentId();
        if (userId == null) {
            return Result.fail("用户未登录");
        }
        
        log.info("保存健康记录: userId={}, data={}", userId, data);
        
        try {
            healthRecordService.saveHealthRecord(userId, data);
            return Result.success("保存成功");
        } catch (Exception e) {
            log.error("保存健康记录失败: {}", e.getMessage(), e);
            return Result.fail(e.getMessage());
        }
    }

    @GetMapping("/bp/list")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<?> getBloodPressureList(
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "20") int size) {
        Long userId = BaseContext.getCurrentId();
        return Result.success(healthRecordService.getBloodPressureList(userId, page, size));
    }

    @GetMapping("/glucose/list")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<?> getGlucoseList(
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "20") int size) {
        Long userId = BaseContext.getCurrentId();
        return Result.success(healthRecordService.getGlucoseList(userId, page, size));
    }

    @GetMapping("/heartRate/list")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<?> getHeartRateList(
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "20") int size) {
        Long userId = BaseContext.getCurrentId();
        return Result.success(healthRecordService.getHeartRateList(userId, page, size));
    }

    @GetMapping("/weight/list")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<?> getWeightList(
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "20") int size) {
        Long userId = BaseContext.getCurrentId();
        return Result.success(healthRecordService.getWeightList(userId, page, size));
    }

    @GetMapping("/spo2/list")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<?> getSpo2List(
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "20") int size) {
        Long userId = BaseContext.getCurrentId();
        return Result.success(healthRecordService.getSpo2List(userId, page, size));
    }

    @DeleteMapping("/{type}/{id}")
    @Role({"ADMIN", "WHITE", "BUSINESS", "GUEST"})
    public Result<String> deleteRecord(
            @PathVariable String type,
            @PathVariable Long id) {
        Long userId = BaseContext.getCurrentId();
        log.info("删除健康记录: userId={}, type={}, id={}", userId, type, id);
        
        try {
            healthRecordService.deleteRecord(userId, type, id);
            return Result.success("删除成功");
        } catch (Exception e) {
            log.error("删除健康记录失败: {}", e.getMessage(), e);
            return Result.fail(e.getMessage());
        }
    }
}
