package com.hongchu.cbcommon.util;

import org.springframework.stereotype.Component;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.SecureRandom;

@Component
public class SimplePasswordEncoder {

    /**
     * 生成随机盐
     */
    public static String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[16];
        random.nextBytes(salt);
        return new BigInteger(1, salt).toString(16);
    }

    /**
     * SHA256加密
     */
    public static String encrypt(String password, String salt) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt.getBytes());

            // 多次哈希增加安全性
            byte[] hash = md.digest(password.getBytes());
            for (int i = 0; i < 16; i++) {
                hash = md.digest(hash);
            }

            return new BigInteger(1, hash).toString(16);
        } catch (Exception e) {
            throw new RuntimeException("加密失败");
        }
    }

    /**
     * 验证密码
     */
    public static boolean verify(String password, String hash, String salt) {
        String newHash = encrypt(password, salt);
        return newHash.equals(hash);
    }
}