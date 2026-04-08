package com.hongchu.cbservice.service.interfaces.auth;

import io.jsonwebtoken.Claims;

public interface IJwtService {
    // 生成Access Token
    String generateAccessToken(Long userId, String username, String roleCode, String roleCategory);
    // 生成Refresh Token  
    String generateRefreshToken(Long userId, String username, String roleCode, String roleCategory);
    // 验证Token
    boolean validateToken(String token);
    // 解析Token
    Claims parseToken(String token);
    // 获取用户ID
    Long getUserId(String token);
    // 获取用户名
    String getUsername(String token);
    // 获取角色编码
    String getRoleCode(String token);
    // 获取角色分类
    String getRoleCategory(String token);
    // 刷新Token
    String refreshToken(String refreshToken);
}