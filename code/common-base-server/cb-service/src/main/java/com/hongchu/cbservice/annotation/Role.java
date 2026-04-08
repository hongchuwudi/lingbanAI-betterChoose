package com.hongchu.cbservice.annotation;

import com.hongchu.cbpojo.enums.Logic;

import java.lang.annotation.*;

/**
 * 角色权限注解
 * 用于在Controller方法上声明所需的角色权限
 * 基于角色分类进行权限校验
 */
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Role {
    
    /**
     * 需要的角色分类数组
     * 例如：{"ADMIN", "BUSINESS"}
     */
    String[] value() default {};
    
    /**
     * 逻辑运算符：AND 需要满足所有角色，OR 满足任一角色即可
     */
    Logic logic() default Logic.OR;
    
    /**
     * 是否启用权限检查，默认为true
     */
    boolean enabled() default true;
    
    /**
     * 权限不足时的错误信息
     */
    String message() default "权限不足";
}