package com.hongchu.cbservice.aspect;

import com.hongchu.cbservice.annotation.Role;
import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbpojo.enums.Logic;
import com.hongchu.cbcommon.exception.BusinessException;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;

/**
 * 角色权限切面
 */
@Slf4j
@Aspect
@Component
public class RoleAspect {

    /**
     * 检查角色权限
     */
    @Before("@annotation(com.hongchu.cbservice.annotation.Role) || @within(com.hongchu.cbservice.annotation.Role)")
    public void checkRole(JoinPoint joinPoint) {
        // 获取方法上的@Role注解
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        Role roleAnnotation = method.getAnnotation(Role.class);

        // 如果方法上没有注解，尝试获取类上的注解
        if (roleAnnotation == null) {
            roleAnnotation = method.getDeclaringClass().getAnnotation(Role.class);
            if (roleAnnotation == null) return;
        }

        // 检查是否启用
        if (!roleAnnotation.enabled()) return;

        // 获取当前用户ID和角色分类
        Long currentUserId = BaseContext.getCurrentId();
        String currentRoleCategory = BaseContext.getCurrentRoleCategory();
        if (currentUserId == null || currentRoleCategory == null) throw new BusinessException("用户未登录");

        // 获取需要的角色分类
        String[] requiredRoleCategories = roleAnnotation.value();

        // 如果没有指定角色分类，默认允许所有
        if (requiredRoleCategories == null || requiredRoleCategories.length == 0) return;

        // 检查权限
        boolean hasPermission;
        if (roleAnnotation.logic() == Logic.AND)
            hasPermission = checkAndLogic(currentRoleCategory, requiredRoleCategories);  // AND逻辑：需要所有角色分类
         else hasPermission = checkOrLogic(currentRoleCategory, requiredRoleCategories); // OR逻辑：只需要任一角色分类

        if (!hasPermission) {
            String message = roleAnnotation.message();
            log.warn("权限不足: 用户ID={}, 当前角色分类={}, 需要角色分类={}, 逻辑={}",
                    currentUserId, currentRoleCategory, requiredRoleCategories, roleAnnotation.logic());
            throw new BusinessException(message);
        }

        log.debug("权限校验通过: 用户ID={}, 当前角色分类={}, 需要角色分类={}", currentUserId, currentRoleCategory, requiredRoleCategories);
    }

    private boolean checkAndLogic(String currentRoleCategory, String[] requiredRoleCategories) {
        // AND逻辑：需要用户拥有所有指定的角色分类
        for (String requiredCategory : requiredRoleCategories) {
            if (!currentRoleCategory.equalsIgnoreCase(requiredCategory)) {
                return false;
            }
        }
        return true;
    }

    private boolean checkOrLogic(String currentRoleCategory, String[] requiredRoleCategories) {
        // OR逻辑：只需要用户拥有任一指定的角色分类
        for (String requiredCategory : requiredRoleCategories) {
            if (currentRoleCategory.equalsIgnoreCase(requiredCategory)) {
                return true;
            }
        }
        return false;
    }
}