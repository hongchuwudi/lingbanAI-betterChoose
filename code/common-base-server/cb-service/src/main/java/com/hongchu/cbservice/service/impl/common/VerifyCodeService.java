package com.hongchu.cbservice.service.impl.common;


import com.hongchu.cbcommon.cache.ManualCacheManager;
import com.hongchu.cbcommon.context.EmailConstants;
import com.hongchu.cbcommon.context.ErrorMessageConstants;
import com.hongchu.cbcommon.exception.BusinessException;
import com.hongchu.cbcommon.util.EmailUtil;
import com.hongchu.cbservice.service.interfaces.common.EmailService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;


@Slf4j
@Service
@RequiredArgsConstructor
public class VerifyCodeService implements EmailService {

    private final ManualCacheManager cacheManager;
    private final EmailUtil emailUtil;
    private final AsyncEmailService asyncEmailService;

    /**
     * 发送邮箱验证码 - 支持不同业务场景（异步发送）
     */
    public void sendEmailVerifyCode(String email, String businessType) {
        if (!emailUtil.isValidEmail(email))
            throw new BusinessException(ErrorMessageConstants.ERROR_EMAIL_FORMAT);

        String verifyCode = emailUtil.generateVerifyCode();

        saveVerifyCode(email, verifyCode, businessType);

        asyncEmailService.sendVerifyCodeAsync(email, verifyCode, businessType);

        log.info("{}验证码已提交异步发送，邮箱：{}", EmailUtil.getBusinessTypeName(businessType), email);
    }

    /**
     * 保存验证码到缓存 - 支持业务类型
     */
    public void saveVerifyCode(String email, String verifyCode, String businessType) {
        String cacheKey = buildCacheKey(email, businessType);
        cacheManager.put(cacheKey, verifyCode, EmailConstants.VERIFY_CODE_EXPIRE_MINUTES, TimeUnit.MINUTES);
        log.debug("{}验证码保存到缓存，邮箱：{}", EmailUtil.getBusinessTypeName(businessType), email);
    }

    /**
     * 获取验证码 - 支持业务类型
     */
    public String getVerifyCode(String email, String businessType) {
        String cacheKey = buildCacheKey(email, businessType);
        String verifyCode = cacheManager.get(cacheKey);
        if (verifyCode == null) log.debug("{}验证码不存在或已过期，邮箱：{}", EmailUtil.getBusinessTypeName(businessType), email);
        else log.info("获取{}验证码成功，邮箱：{}", EmailUtil.getBusinessTypeName(businessType), email);
        return verifyCode;
    }

    /**
     * 验证验证码 - 支持业务类型
     */
    public boolean verifyCode(String email, String inputCode, String businessType) {
        String storedCode = getVerifyCode(email, businessType);

        if (storedCode == null)
            throw new BusinessException(ErrorMessageConstants.ERROR_EMAIL_VERIFY_CODE_EXPIRED);

        boolean isValid = storedCode.equals(inputCode);
        if (isValid) {
            deleteVerifyCode(email, businessType);
            log.info("{}验证码验证成功，邮箱：{}", EmailUtil.getBusinessTypeName(businessType), email);
        } else {
            log.warn("{}验证码验证失败，邮箱：{}",EmailUtil.getBusinessTypeName(businessType), email);
            throw new BusinessException(ErrorMessageConstants.ERROR_EMAIL_VERIFY_CODE_INCORRECT);
        }

        return isValid;
    }

    /**
     * 删除验证码 - 支持业务类型
     */
    public void deleteVerifyCode(String email, String businessType) {
        String cacheKey = buildCacheKey(email, businessType);
        cacheManager.delete(cacheKey);
        log.debug("{}验证码删除成功，邮箱：{}", EmailUtil.getBusinessTypeName(businessType), email);
    }

    /**
     * 构建缓存key
     */
    private String buildCacheKey(String email, String businessType) {
        return EmailConstants.VERIFY_CODE_PREFIX + businessType + ":" + email;
    }
}
