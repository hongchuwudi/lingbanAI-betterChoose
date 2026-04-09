package com.hongchu.cbcommon.context;

import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class SecurityConstants {
    public static final List<String> PUBLIC_PATHS = List.of(
            "/static/**",
            "/index",
            "/index.html",
            
            "/auth/register",
            "/auth/register-email",
            "/auth/register-phone",
            "/auth/login",
            "/auth/login-email",
            "/auth/login-phone",
            "/auth/send-email-code",
            "/auth/send-phone-code",
            "/auth/forget-password",
            "/auth/forget-password-phone",
            "/email/**",
            
            "/ws",
            
            "/ai/**",
            
            "/wechat-article/list",
            "/wechat-article/{id:[0-9]+}",
            "/health-video/list",
            "/health-video/{id:[0-9]+}"
    );

    public static final String ADMIN_PATH_PREFIX = "/admin";
    public static final String USER_PATH_PREFIX = "/user";
}
