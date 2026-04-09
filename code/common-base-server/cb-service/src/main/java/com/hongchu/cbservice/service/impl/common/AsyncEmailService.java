package com.hongchu.cbservice.service.impl.common;

import com.hongchu.cbcommon.context.EmailConstants;
import com.hongchu.cbcommon.util.EmailUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class AsyncEmailService {

    private final EmailUtil emailUtil;

    @Async("taskExecutor")
    public void sendVerifyCodeAsync(String email, String verifyCode, String businessType) {
        try {
            String subject = EmailUtil.getEmailSubjectByBusinessType(businessType);
            String content = String.format(
                    EmailConstants.EMAIL_TEMPLATE_VERIFY_CODE,
                    verifyCode,
                    EmailConstants.VERIFY_CODE_EXPIRE_MINUTES,
                    LocalDateTime.now()
            );
            emailUtil.sendSimpleEmail(email, subject, content);
            log.info("{}验证码邮件发送成功，邮箱：{}", EmailUtil.getBusinessTypeName(businessType), email);
        } catch (Exception e) {
            log.error("{}验证码邮件发送失败，邮箱：{}", EmailUtil.getBusinessTypeName(businessType), email, e);
        }
    }
}
