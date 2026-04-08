package com.hongchu.cbcommon.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtBuilder;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Date;
import java.util.Map;

public class JwtUtil {

    /**
     * 验证密钥长度是否安全
     * HS256 算法要求密钥至少 256 位（32 字节）
     */
    private static void validateSecretKey(String secretKey) {
        if (secretKey == null || secretKey.trim().isEmpty()) {
            throw new IllegalArgumentException("JWT密钥不能为空");
        }

        // 计算密钥位数
        int bitLength = secretKey.getBytes(StandardCharsets.UTF_8).length * 8;

        if (bitLength < 256) {
            throw new IllegalArgumentException(
                    String.format("JWT密钥太短！HS256算法要求密钥至少256位，当前密钥为%d位。请使用至少32个字符的密钥。", bitLength)
            );
        }

        // 建议检查
        if (secretKey.length() < 32) {
            System.err.println("⚠️ 警告：虽然密钥位数足够，但字符数少于32个，建议使用更长的密钥以提高安全性。");
        }
    }

    /**
     * 从字符串生成安全的密钥
     */
    private static SecretKey generateSecretKey(String secretKey) {
        // 验证密钥长度
        validateSecretKey(secretKey);

        // 将字符串转换为字节数组
        byte[] keyBytes = secretKey.getBytes(StandardCharsets.UTF_8);

        // 使用 Keys.hmacShaKeyFor 生成安全的密钥
        return Keys.hmacShaKeyFor(keyBytes);
    }

    /**
     * 生成jwt
     * 使用Hs256算法, 私匙使用固定秘钥
     *
     * @param secretKey jwt秘钥（必须至少32个字符）
     * @param ttlMillis jwt过期时间(毫秒)
     * @param claims    设置的信息
     * @return jwt
     */
    public static String createJWT(String secretKey, long ttlMillis, Map<String, Object> claims) {
        // 生成安全的密钥
        SecretKey key = generateSecretKey(secretKey);

        // 生成JWT的时间
        long expMillis = System.currentTimeMillis() + ttlMillis;
        Date exp = new Date(expMillis);

        // 设置jwt的body
        JwtBuilder builder = Jwts.builder()
                // 如果有私有声明，一定要先设置这个自己创建的私有的声明，这个是给builder的claim赋值，一旦写在标准的声明赋值之后，就是覆盖了那些标准的声明的
                .setClaims(claims)
                // 使用安全的密钥进行签名
                .signWith(key, SignatureAlgorithm.HS256)
                // 设置过期时间
                .setExpiration(exp);

        return builder.compact();
    }

    /**
     * Token解密
     *
     * @param secretKey jwt秘钥 此秘钥一定要保留好在服务端, 不能暴露出去, 否则sign就可以被伪造, 如果对接多个客户端建议改造成多个
     * @param token     加密后的token
     * @return 解密后的信息
     */
    public static Claims parseJWT(String secretKey, String token) {
        // 生成安全的密钥
        SecretKey key = generateSecretKey(secretKey);

        // 解析JWT
        return Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
}