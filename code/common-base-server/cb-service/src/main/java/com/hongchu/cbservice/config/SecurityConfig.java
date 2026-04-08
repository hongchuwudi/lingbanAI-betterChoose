package com.hongchu.cbservice.config;

import com.hongchu.cbcommon.context.SecurityConstants;
import com.hongchu.cbservice.intercepter.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.config.Customizer;

/**
 * Spring Security 安全配置类
 * 负责配置应用程序的安全策略，包括身份认证、授权、会话管理和JWT过滤器的集成
 *
 * 主要功能：
 * 1. 配置HTTP请求的安全规则
 * 2. 集成JWT认证过滤器
 * 3. 设置无状态会话管理
 * 4. 禁用不必要的安全功能（如CSRF）
 *
 * @author hongchu
 * @since 2024
 */
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    /**
     * JWT认证过滤器，用于验证请求中的JWT令牌
     */
    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    /**
     * 配置Spring Security过滤器链
     *
     * @param http HttpSecurity对象，用于配置Web安全设置
     * @return SecurityFilterChain实例
     * @throws Exception 配置过程中可能抛出的异常
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 启用CORS支持
                .cors(Customizer.withDefaults())

                // 禁用CSRF（跨站请求伪造）保护
                // 适用于基于REST API的项目
                .csrf(AbstractHttpConfigurer::disable)

                // 配置会话管理策略为无状态
                // 每个请求都需要携带认证信息（JWT），服务器不保存会话状态
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

                // 配置请求授权规则
                .authorizeHttpRequests(auth -> auth
                        // 公开接口：使用SecurityConstants中定义的路径列表
                        // 这些路径不需要认证即可访问
                        .requestMatchers(SecurityConstants.PUBLIC_PATHS.toArray(new String[0]))
                        .permitAll()

                        // 其他所有请求都需要经过身份认证
                        // 用户必须提供有效的JWT令牌才能访问
                        .anyRequest().authenticated()
                )

                // 将JWT认证过滤器添加到过滤器链中
                // 在UsernamePasswordAuthenticationFilter之前执行
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}