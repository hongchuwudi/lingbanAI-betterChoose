package com.hongchu.cbservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

/**
 * 跨域配置类
 * 配置CORS（跨域资源共享）策略，允许前端应用访问后端API
 *
 * 主要功能：
 * 1. 允许所有来源访问（开发环境）
 * 2. 允许所有HTTP方法（GET, POST, PUT, DELETE, OPTIONS等）
 * 3. 允许所有请求头
 * 4. 允许携带认证信息（cookies等）
 *
 * @author YourName
 * @since 2024
 */
@Configuration
public class CorsConfig {

    /**
     * 配置CORS过滤器
     *
     * @return CorsFilter实例
     */
    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();

        // 允许所有来源（生产环境应指定具体域名）
        config.addAllowedOriginPattern("*");

        // 允许携带认证信息（cookies、authorization头等）
        config.setAllowCredentials(true);

        // 允许所有请求头
        config.addAllowedHeader("*");

        // 允许所有HTTP方法
        config.addAllowedMethod("*");

        // 预检请求缓存时间（秒）
        config.setMaxAge(3600L);

        // 配置CORS策略映射
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);

        return new CorsFilter(source);
    }
}
