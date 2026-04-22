// EmailUtil.java
package com.hongchu.cbcommon.util;

import com.hongchu.cbcommon.context.CommonData;
import com.hongchu.cbcommon.context.EmailConstants;
import com.hongchu.cbcommon.context.ErrorMessageConstants;
import com.hongchu.cbcommon.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;
import org.springframework.beans.factory.annotation.Value;

import java.time.LocalDateTime;

@Slf4j
@Component
@RequiredArgsConstructor
public class EmailUtil {
    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String username;
    /**
     * 发送简单文本邮件
     */
    public void sendSimpleEmail(String to, String subject, String content) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(CommonData.PROJECT_NAME + " <" + username + ">");
            message.setTo(to);
            message.setSubject(subject);
            message.setText(content);
            mailSender.send(message);
            log.info("邮件发送成功，收件人：{}", to);
        } catch (Exception e) {
            log.error("邮件发送失败，收件人：{}", to, e);
            throw new BusinessException(ErrorMessageConstants.ERROR_EMAIL_SEND);
        }
    }

    /**
     * 发送验证码邮件
     */
    public void sendVerifyCodeEmail(String email, String verifyCode) {
        String subject = EmailConstants.EMAIL_SUBJECT_VERIFY_CODE;
        String content = String.format(
                EmailConstants.EMAIL_TEMPLATE_VERIFY_CODE,
                verifyCode,
                EmailConstants.VERIFY_CODE_EXPIRE_MINUTES,
                LocalDateTime.now());
        sendSimpleEmail(email, subject, content);
    }

    /**
     * 发送欢迎邮件
     */
    public void sendWelcomeEmail(String email, String username) {
        String subject = "欢迎注册";
        String content = String.format("亲爱的 %s，欢迎注册我们的应用！感谢您的加入。", username);
        sendSimpleEmail(email, subject, content);
    }

    /**
     * 发送验证码邮件 - 支持业务类型
     */
    public void sendVerifyCodeEmail(String email, String verifyCode, String businessType) {
        String subject = getEmailSubjectByBusinessType(businessType);
        String content = String.format(
                EmailConstants.EMAIL_TEMPLATE_VERIFY_CODE,
                verifyCode,                        // %s - 验证码
                EmailConstants.VERIFY_CODE_EXPIRE_MINUTES, // %d - 有效期分钟数
                LocalDateTime.now()                // %tF - 日期（自动格式化）
        );
        sendSimpleEmail(email, subject, content);
    }

    /**
     * 根据业务类型获取邮件主题
     */
    public static String getEmailSubjectByBusinessType(String businessType) {
        return switch (businessType) {
            case "login" -> "登录验证码";
            case "register" -> "注册验证码";
            case "reset_pwd" -> "重置密码验证码";
            case "change_username" -> "修改用户名验证码";
            case "forget_pwd" -> "忘记密码验证码";
            case "change_email" -> "修改邮箱验证码";
            case "change_phone" -> "修改手机号验证码";
            default -> EmailConstants.EMAIL_SUBJECT_VERIFY_CODE;
        };
    }

    /**
     * 根据业务类型获取中文名称
     */
    public static String getBusinessTypeName(String businessType) {
        return switch (businessType) {
            case "login" -> "登录";
            case "register" -> "注册";
            case "reset_pwd" -> "重置密码";
            case "change_username" -> "修改用户名";
            case "forget_pwd" -> "忘记密码";
            case "change_email" -> "修改邮箱";
            case "change_phone" -> "修改手机号";
            default -> "验证";
        };
    }

    // 生成随机验证码
    public String generateVerifyCode() {
        return String.valueOf((int) ((Math.random() * 9 + 1) * 100000));
    }

    // 校验邮箱格式是否正确
    public boolean isValidEmail(String email) {
        return email.matches(EmailConstants.EMAIL_FORMAT_REG);
    }
}