package com.hongchu.cbservice.controller.ai;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.dto.HealthDocumentParseResponse;
import com.hongchu.cbpojo.entity.health.HealthDocumentParseRecord;
import com.hongchu.cbservice.service.interfaces.ai.IHealthParseService;
import com.hongchu.cbservice.service.interfaces.auth.IJwtService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RequiredArgsConstructor
@RestController
@RequestMapping("/ai")
@Slf4j
@CrossOrigin
public class HealthParseController {

    private final IHealthParseService healthParseService;
    private final IJwtService jwtService;

    @PostMapping("/parse-health-document")
    public Result<HealthDocumentParseResponse> parseDocument(
            @RequestParam("file") MultipartFile file,
            HttpServletRequest request) throws IOException {

        Long userId = extractUserId(request);
        if (userId == null) return Result.fail("用户未登录");

        log.info("开始上传健康文档，用户ID: {}, 文件名: {}, 大小: {} bytes",
                userId, file.getOriginalFilename(), file.getSize());

        byte[] fileBytes = file.getBytes();
        String fileName = file.getOriginalFilename();
        String contentType = file.getContentType();

        HealthDocumentParseRecord record = healthParseService.createParseRecord(file, userId);

        healthParseService.parseDocumentAsync(record.getId(), fileBytes, fileName, contentType);

        HealthDocumentParseResponse response = HealthDocumentParseResponse.builder()
                .recordId(record.getId())
                .status(record.getStatus())
                .fileUrl(record.getFileUrl())
                .fileName(record.getFileName())
                .createdAt(record.getCreatedAt())
                .build();

        log.info("文档上传成功，解析任务已创建: recordId={}", record.getId());
        return Result.success(response);
    }

    @GetMapping("/parse-record/{recordId}")
    public Result<HealthDocumentParseRecord> getParseRecord(@PathVariable Long recordId) {
        HealthDocumentParseRecord record = healthParseService.getParseRecord(recordId);
        if (record == null) {
            return Result.fail("解析记录不存在");
        }
        return Result.success(record);
    }

    @GetMapping("/parse-record-list")
    public Result<Page<HealthDocumentParseRecord>> getParseRecordList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            HttpServletRequest request) {
        Long userId = extractUserId(request);
        if (userId == null) return Result.fail("用户未登录");

        Page<HealthDocumentParseRecord> records = healthParseService.getParseRecordList(userId, page, size);
        return Result.success(records);
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
