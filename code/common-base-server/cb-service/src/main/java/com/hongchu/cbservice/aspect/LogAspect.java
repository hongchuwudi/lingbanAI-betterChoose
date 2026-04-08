package com.hongchu.cbservice.aspect;

import com.hongchu.cbservice.annotation.Log;
import com.hongchu.cbpojo.entity.CommonLog;
import com.hongchu.cbservice.service.interfaces.common.ICommonLogService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.*;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import java.lang.reflect.Method;
import java.time.LocalDateTime;

/**
 * 日志切面
 */
@Slf4j
@Aspect
@Component
@RequiredArgsConstructor
public class LogAspect {
    private final ICommonLogService logService;
    private final ThreadLocal<Long> startTime = new ThreadLocal<>();

    /**
     * 定义切点：所有被@Log注解的方法
     */
    @Pointcut("@annotation(com.hongchu.cbservice.annotation.Log)")
    public void logPointCut() {}

    /**
     * 前置通知
     */
    @Before("logPointCut()")
    public void doBefore(JoinPoint joinPoint) {
        startTime.set(System.currentTimeMillis());
    }

    /**
     * 后置通知
     */
    @AfterReturning(pointcut = "logPointCut()", returning = "result")
    public void doAfterReturning(JoinPoint joinPoint, Object result) {
        try {
            saveLog(joinPoint, result, null);
        } catch (Exception e) {
            log.error("记录日志异常: {}", e.getMessage());
        }
    }

    /**
     * 异常通知
     */
    @AfterThrowing(pointcut = "logPointCut()", throwing = "e")
    public void doAfterThrowing(JoinPoint joinPoint, Throwable e) {
        try {
            saveLog(joinPoint, null, e);
        } catch (Exception ex) {
            log.error("记录异常日志异常: {}", ex.getMessage());
        }
    }

    /**
     * 保存日志
     */
    private void saveLog(JoinPoint joinPoint, Object result, Throwable e) {
        // 1. 获取当前请求对象
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes == null) return;

        HttpServletRequest request = attributes.getRequest();

        // 2. 获取@Log注解
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        Log logAnnotation = method.getAnnotation(Log.class);
        if (logAnnotation == null) {
            // 如果方法上没有，尝试获取类上的注解
            logAnnotation = method.getDeclaringClass().getAnnotation(Log.class);
            if (logAnnotation == null) return;
        }

        // 3. 计算执行时间
        Long executeTime = null;
        if (logAnnotation.recordExecuteTime() && startTime.get() != null) {
            executeTime = System.currentTimeMillis() - startTime.get();
        }

        // 4. 构建日志实体
        CommonLog commonLog = CommonLog.builder()
                .logType(logAnnotation.type().name())
                .logLevel(e != null ? "ERROR" : logAnnotation.level().name())
                .module(getModuleName(logAnnotation, method))
                .businessType(logAnnotation.businessType())
                .operation(getOperationName(logAnnotation, method))
                .userId(getCurrentUserId())
                .username(getCurrentUsername())
                .userRole(getCurrentUserRole())
                .requestMethod(request.getMethod())
                .requestUrl(request.getRequestURI())
                .requestParams(logAnnotation.recordParams() ? getRequestParams(joinPoint) : null)
                .requestBody(logAnnotation.recordParams() ? getRequestBody(request) : null)
                .responseStatus(e != null ? 500 : 200)
                .responseBody(logAnnotation.recordResponse() && result != null ? result.toString() : null)
                .executeTime(executeTime)
                .clientIp(getClientIp(request))
                .userAgent(request.getHeader("User-Agent"))
                .deviceType(getDeviceType(request))
                .serverIp(request.getLocalAddr())
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        // 5. 异步保存日志
        logService.saveAsync(commonLog);

        // 6. 清理ThreadLocal
        startTime.remove();
    }

    /**
     * 获取模块名称
     */
    private String getModuleName(Log logAnnotation, Method method) {
        if (!logAnnotation.module().isEmpty()) {
            return logAnnotation.module();
        }
        // 默认使用类名作为模块名
        return method.getDeclaringClass().getSimpleName();
    }

    /**
     * 获取操作描述
     */
    private String getOperationName(Log logAnnotation, Method method) {
        if (!logAnnotation.operation().isEmpty()) {
            return logAnnotation.operation();
        }
        // 默认使用方法名
        return method.getName();
    }

    /**
     * 获取请求参数
     */
    private String getRequestParams(JoinPoint joinPoint) {
        Object[] args = joinPoint.getArgs();
        if (args == null || args.length == 0) return null;

        StringBuilder params = new StringBuilder();
        for (Object arg : args)
            if (arg != null && !isHttpObject(arg))
                params.append(arg.toString()).append("; ");

        return params.toString();
    }

    /**
     * 获取请求体
     */
    private String getRequestBody(HttpServletRequest request) {
        // 这里可以扩展获取@RequestBody参数
        return null;
    }

    /**
     * 判断是否为HTTP对象
     */
    private boolean isHttpObject(Object obj) {
        return obj instanceof HttpServletRequest ||
                obj instanceof jakarta.servlet.http.HttpServletResponse ||
                obj instanceof MultipartFile;
    }

    /**
     * 获取客户端IP
     */
    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) ip = request.getHeader("Proxy-Client-IP");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) ip = request.getHeader("WL-Proxy-Client-IP");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) ip = request.getRemoteAddr();
        return ip;
    }

    /**
     * 获取设备类型
     */
    private String getDeviceType(HttpServletRequest request) {
        String userAgent = request.getHeader("User-Agent");
        if (userAgent == null) return "unknown";

        if (userAgent.contains("Mobile")) return "mobile";
        if (userAgent.contains("Tablet")) return "tablet";
        return "web";
    }

    /**
     * 获取当前用户ID（需要根据你的认证系统实现）
     */
    private Long getCurrentUserId() {
        // 实现从SecurityContext或ThreadLocal获取当前用户ID
        // 例如：SecurityContextHolder.getContext().getAuthentication().getPrincipal()
        return null;
    }

    /**
     * 获取当前用户名
     */
    private String getCurrentUsername() {
        // 实现从SecurityContext或ThreadLocal获取当前用户名
        return null;
    }

    /**
     * 获取当前用户角色
     */
    private String getCurrentUserRole() {
        // 实现从SecurityContext或ThreadLocal获取当前用户角色
        return null;
    }
}