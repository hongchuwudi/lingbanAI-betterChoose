package com.hongchu.cbservice.service.impl.auth;

import com.hongchu.cbcommon.util.JwtUtil;
import com.hongchu.cbcommon.properties.JwtProperties;
import com.hongchu.cbservice.service.interfaces.auth.IJwtService;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class JwtServiceImpl implements IJwtService {
    private final JwtProperties jwtProperties;

    // 生成Access Token
    @Override
    public String generateAccessToken(Long userId, String username, String roleCode, String roleCategory) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("username", username);
        claims.put("role", roleCode);
        claims.put("role_category", roleCategory);
        claims.put("type", "access");
        
        return JwtUtil.createJWT(jwtProperties.getSecret(), jwtProperties.getExpiration() * 1000L, claims);
    }

    // 生成Refresh Token  
    @Override
    public String generateRefreshToken(Long userId, String username, String roleCode, String roleCategory) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("username", username);
        claims.put("role", roleCode);
        claims.put("role_category", roleCategory);
        claims.put("type", "refresh");
        
        return JwtUtil.createJWT(jwtProperties.getSecret(), jwtProperties.getRefreshTokenExpiration() * 1000L, claims);
    }

    // 验证Token
    @Override
    public boolean validateToken(String token) {
        try {
            parseToken(token);
            return true;
        } catch (Exception e) {
            log.warn("Token验证失败: {}", e.getMessage());
            return false;
        }
    }

    // 解析Token
    @Override
    public Claims parseToken(String token) {
        return JwtUtil.parseJWT(jwtProperties.getSecret(), token);
    }

    // 获取用户ID
    @Override
    public Long getUserId(String token) {
        Claims claims = parseToken(token);
        Object userId = claims.get("userId");
        return userId instanceof Integer ? ((Integer) userId).longValue() : (Long) userId;
    }

    // 获取用户名
    @Override
    public String getUsername(String token) {
        return parseToken(token).get("username", String.class);
    }

    // 获取角色编码
    @Override
    public String getRoleCode(String token) {
        return parseToken(token).get("role", String.class);
    }

    // 获取角色分类
    @Override
    public String getRoleCategory(String token) {
        return parseToken(token).get("role_category", String.class);
    }

    // 刷新Token
    @Override
    public String refreshToken(String refreshToken) {
        if (!"refresh".equals(parseToken(refreshToken).get("type", String.class)))
            throw new RuntimeException("无效的Refresh Token");
        
        Claims claims = parseToken(refreshToken);
        return generateAccessToken(
                getUserId(refreshToken),
                getUsername(refreshToken),
                getRoleCode(refreshToken),
                getRoleCategory(refreshToken)
        );
    }
}