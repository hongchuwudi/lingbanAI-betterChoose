package com.hongchu.cbservice.annotation;

import com.hongchu.cbpojo.enums.LogType;
import com.hongchu.cbpojo.enums.LogLevel;

import java.lang.annotation.*;

/**
 * 日志注解
 */
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Log {
    
    /**
     * 日志类型
     */
    LogType type() default LogType.OPERATION;
    
    /**
     * 日志级别
     */
    LogLevel level() default LogLevel.INFO;
    
    /**
     * 模块名称
     */
    String module() default "";
    
    /**
     * 业务类型
     */
    String businessType() default "";
    
    /**
     * 操作描述
     */
    String operation() default "";
    
    /**
     * 是否记录请求参数
     */
    boolean recordParams() default true;
    
    /**
     * 是否记录响应体
     */
    boolean recordResponse() default true;
    
    /**
     * 是否记录执行时间
     */
    boolean recordExecuteTime() default true;
    
    /**
     * 是否记录用户信息
     */
    boolean recordUser() default true;
}