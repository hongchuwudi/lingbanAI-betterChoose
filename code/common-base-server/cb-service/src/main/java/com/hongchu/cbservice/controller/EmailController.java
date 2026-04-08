package com.hongchu.cbservice.controller;

import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbcommon.util.EmailUtil;
import com.hongchu.cbservice.annotation.Role;
import com.hongchu.cbservice.service.interfaces.common.EmailService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 邮箱
 * <P>用于在前端用户向服务器发送邮箱的服务</P>
 * @author HongChu
 * @deprecated 邮箱服务
 * @date 2026-01-29
 */
@Slf4j
@RestController
@RequestMapping("/email")
@CrossOrigin
@Role(enabled = false) // 邮箱服务接口公开，不需要权限校验
public class EmailController {
    @Autowired private EmailService emailService;

    /**
     * 发送验证码邮件
     * @param email 邮箱
     * @param type 业务类型：login-登录, register-注册, reset_pwd-重置密码
     * @return 状态码
     */
    @GetMapping("/send-vce")
    public Result<String> sendVerifyCodeEmail(String email, String type) {
        log.info("发送{}验证码邮件...", EmailUtil.getBusinessTypeName(type));
        emailService.sendEmailVerifyCode(email, type);
        return Result.success("发送成功");
    }
}
