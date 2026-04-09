package com.hongchu.cbservice.controller.ai;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.dto.HealthAnalysisResponse;
import com.hongchu.cbpojo.entity.health.HealthAnalysisRecord;
import com.hongchu.cbservice.service.interfaces.ai.IHealthAnalysisService;
import com.hongchu.cbservice.service.interfaces.auth.IJwtService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

/**
 * 健康分析控制器
 * 提供健康数据的分析接口
 * 包括健康数据的解析、分析、查询等功能
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/ai")
@Slf4j
@CrossOrigin
public class HealthAnalysisController {

    private final IHealthAnalysisService healthAnalysisService;
    private final IJwtService jwtService;

    @PostMapping("/analyze-health/{parseRecordId}")
    public Result<HealthAnalysisResponse> analyzeHealth(
            @PathVariable Long parseRecordId,
            HttpServletRequest request) {

        Long userId = extractUserId(request);
        if (userId == null) {
            return Result.fail("用户未登录");
        }

        log.info("开始健康分析，用户ID: {}, 解析记录ID: {}", userId, parseRecordId);

        try {
            HealthAnalysisResponse response = healthAnalysisService.analyzeHealthData(parseRecordId, userId);
            log.info("健康分析任务已创建: analysisId={}", response.getAnalysisId());
            return Result.success(response);

        } catch (IllegalArgumentException e) {
            log.warn("健康分析参数错误: {}", e.getMessage());
            return Result.fail(e.getMessage());
        } catch (Exception e) {
            log.error("健康分析失败: {}", e.getMessage(), e);
            return Result.fail("健康分析失败，请稍后重试");
        }
    }

    @GetMapping("/analysis-record/{analysisId}")
    public Result<HealthAnalysisRecord> getAnalysisRecord(@PathVariable Long analysisId) {
        HealthAnalysisRecord record = healthAnalysisService.getAnalysisRecord(analysisId);
        if (record == null) {
            return Result.fail("分析记录不存在");
        }
        return Result.success(record);
    }

    @GetMapping("/analysis-record-list")
    public Result<Page<HealthAnalysisRecord>> getAnalysisRecordList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            HttpServletRequest request) {
        Long userId = extractUserId(request);
        if (userId == null) {
            return Result.fail("用户未登录");
        }

        Page<HealthAnalysisRecord> records = healthAnalysisService.getAnalysisRecordList(userId, page, size);
        return Result.success(records);
    }

    @GetMapping("/analysis-by-parse/{parseRecordId}")
    public Result<HealthAnalysisRecord> getAnalysisByParseRecordId(@PathVariable Long parseRecordId) {
        HealthAnalysisRecord record = healthAnalysisService.getAnalysisByParseRecordId(parseRecordId);
        if (record == null) {
            return Result.fail("分析记录不存在");
        }
        return Result.success(record);
    }

    private Long extractUserId(HttpServletRequest request) {
        Long userId = BaseContext.getCurrentId();
        if (userId == null) {
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                try {
                    userId = jwtService.getUserId(authHeader.substring(7));
                    log.debug("从Token中提取用户ID: {}", userId);
                } catch (Exception e) {
                    log.error("解析Token失败: {}", e.getMessage());
                }
            }
        }
        return userId;
    }
}
