package com.hongchu.cbservice.controller.health;

import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.vo.health.HealthDashboardVO;
import com.hongchu.cbservice.service.interfaces.health.IHealthService;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

/**
 * 健康数据控制器
 */
@Slf4j
@RestController
@RequestMapping("/health")
@RequiredArgsConstructor
public class HealthController {
    
    private final IHealthService healthService;
    
    /**
     * 获取健康看板数据
     */
    @GetMapping("/dashboard")
    public Result<HealthDashboardVO> getDashboard(HttpServletRequest request) {
        Long userId = BaseContext.getCurrentId();
        if (userId == null) {
            userId = extractUserIdFromToken(request);
        }
        
        if (userId == null) {
            return Result.fail("用户未登录");
        }
        
        log.info("获取健康看板数据, userId: {}", userId);
        HealthDashboardVO dashboard = healthService.getDashboard(userId);
        return Result.success(dashboard);
    }
    
    private Long extractUserIdFromToken(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            try {
                String token = authHeader.substring(7);
                Claims claims = (Claims) request.getAttribute("claims");
                if (claims != null) {
                    Object userIdObj = claims.get("user_id");
                    if (userIdObj != null) {
                        return Long.parseLong(userIdObj.toString());
                    }
                }
            } catch (Exception e) {
                log.error("解析Token失败: {}", e.getMessage());
            }
        }
        return null;
    }
}
