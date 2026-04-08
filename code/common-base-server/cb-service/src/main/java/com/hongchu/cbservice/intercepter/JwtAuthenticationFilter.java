package com.hongchu.cbservice.intercepter;

import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbservice.service.interfaces.auth.IJwtService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final IJwtService jwtService;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {

        // 1. 从请求头获取Token
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            try {
                // 2. 验证Token
                if (jwtService.validateToken(token)) {
                    // 3. 从Token中获取用户信息
                    Long userId = jwtService.getUserId(token);
                    String username = jwtService.getUsername(token);
                    String roleCode = jwtService.getRoleCode(token);
                    String roleCategory = jwtService.getRoleCategory(token); // 获取角色分类

                    // 4.  关键步骤：设置到BaseContext（AOP从这里获取用户信息）
                    BaseContext.setUserContext(userId, roleCategory);

                    // 5. 创建Authentication对象
                    UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(
                                    username,  // principal
                                    null,      // credentials（密码）
                                    Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + roleCode))  // 权限
                            );

                    // 6. 将认证信息设置到SecurityContext
                    SecurityContextHolder.getContext().setAuthentication(authentication);

                    log.debug("用户认证成功: {} (ID: {}, 角色分类: {})", username, userId, roleCategory);
                }
            } catch (Exception e) {
                log.warn("JWT认证失败", e);
            }
        }

        try {
            // 7. 继续过滤器链
            filterChain.doFilter(request, response);
        } finally {
            // 8. ✅ 关键步骤：请求结束后清理BaseContext，防止内存泄漏
            BaseContext.clear();
        }
    }
}