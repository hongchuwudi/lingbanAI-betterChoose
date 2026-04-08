package com.hongchu.cbcommon.context;

import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * 安全配置常量类
 * 集中管理所有安全相关的路径和配置常量
 * <p>
 * 优点：
 * 1. 便于统一管理和维护公开路径
 * 2. 避免在多个地方重复定义路径
 * 3. 提高代码的可读性和可维护性
 * 4. 方便后续扩展和修改
 */
@Configuration
public class SecurityConstants {
    /**
     * 公开访问路径列表
     * 这些路径不需要认证即可访问
     * 注意：使用通配符 ** 表示匹配该路径及其所有子路径
     */
    public static final List<String> PUBLIC_PATHS = List.of(
            "/static/**",
            "/index",
            "/index.html",
            
            // 认证相关接口
            "/auth/register",
            "/auth/login",
            "/email/**",
            
            // WebSocket 端点
            "/ws",
            
            // AI 对话接口
            "/ai/**"
    );

    public static final String ADMIN_PATH_PREFIX = "/admin";
    public static final String USER_PATH_PREFIX = "/user";
}