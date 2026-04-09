package com.hongchu.cbservice.controller.health;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.entity.ChildProfile;
import com.hongchu.cbpojo.entity.ElderlyProfile;
import com.hongchu.cbpojo.entity.FamilyBinding;
import com.hongchu.cbpojo.vo.health.HealthDashboardVO;
import com.hongchu.cbservice.mapper.ChildProfileMapper;
import com.hongchu.cbservice.mapper.ElderlyProfileMapper;
import com.hongchu.cbservice.mapper.FamilyBindingMapper;
import com.hongchu.cbservice.service.interfaces.health.IHealthService;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/health/child")
@RequiredArgsConstructor
public class ChildHealthController {

    private final IHealthService healthService;
    private final ElderlyProfileMapper elderlyProfileMapper;
    private final ChildProfileMapper childProfileMapper;
    private final FamilyBindingMapper familyBindingMapper;

    @GetMapping("/elderly-dashboard")
    public Result<HealthDashboardVO> getElderlyDashboard(
            @RequestParam Long elderlyProfileId,
            HttpServletRequest request) {
        Long childUserId = BaseContext.getCurrentId();
        if (childUserId == null) {
            childUserId = extractUserIdFromToken(request);
        }

        if (childUserId == null) {
            return Result.fail("用户未登录");
        }

        ChildProfile childProfile = childProfileMapper.selectOne(
                new LambdaQueryWrapper<ChildProfile>()
                        .eq(ChildProfile::getUserId, childUserId));
        if (childProfile == null) {
            return Result.fail("子女档案不存在");
        }

        FamilyBinding binding = familyBindingMapper.selectOne(
                new LambdaQueryWrapper<FamilyBinding>()
                        .eq(FamilyBinding::getElderlyProfileId, elderlyProfileId)
                        .eq(FamilyBinding::getChildProfileId, childProfile.getId())
                        .eq(FamilyBinding::getStatus, 1));
        if (binding == null) {
            return Result.fail("无权查看该老人健康数据，请确认绑定关系");
        }

        ElderlyProfile elderlyProfile = elderlyProfileMapper.selectById(elderlyProfileId);
        if (elderlyProfile == null) {
            return Result.fail("老人档案不存在");
        }

        Long elderlyUserId = elderlyProfile.getUserId();
        log.info("子女查看老人健康数据, childUserId: {}, elderlyProfileId: {}, elderlyUserId: {}",
                childUserId, elderlyProfileId, elderlyUserId);

        HealthDashboardVO dashboard = healthService.getDashboard(elderlyUserId);
        return Result.success(dashboard);
    }

    private Long extractUserIdFromToken(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            try {
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
