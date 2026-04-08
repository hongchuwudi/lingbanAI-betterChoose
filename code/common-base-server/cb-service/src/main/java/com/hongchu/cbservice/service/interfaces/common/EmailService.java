package com.hongchu.cbservice.service.interfaces.common;

public interface EmailService {
    // 发送邮箱验证码
    void sendEmailVerifyCode(String email, String businessType);
}
