package com.hongchu.cbservice.controller;

import java.util.Map;

import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.dto.UserDTO;
import com.hongchu.cbpojo.vo.UserInfoVO;
import com.hongchu.cbservice.annotation.Role;
import com.hongchu.cbservice.service.interfaces.auth.IAuthService;
import com.hongchu.cbservice.service.interfaces.common.EmailService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/auth")
@CrossOrigin
@Role(enabled = false)
public class AuthController {
    @Autowired private IAuthService authService;
    @Autowired private EmailService emailService;

    @GetMapping("/info-nick")
    public Result<UserInfoVO> getUserInfoByNick(@RequestParam String nickname) {
        log.info("根据NickName用户信息: nickname={}",nickname);
        UserInfoVO user = authService.getUserInfoByNick(nickname);
        return Result.success(user);
    }

    @GetMapping("/info-un")
    public Result<UserInfoVO> getUserInfo(@RequestParam String param) {
        log.info("用户信息: 参数猜想param={}", param);
        UserInfoVO user = authService.getUserInfo(param);
        return Result.success(user);
    }

    @GetMapping("/current")
    public Result<UserInfoVO> getCurrentUser() {
        log.info("获取当前登录用户信息");
        UserInfoVO user = authService.getCurrentUser();
        return Result.success(user);
    }

    @PostMapping("/register")
    public Result<String> register(
            @RequestParam String username,
            @RequestParam String password) {
        log.info("用户注册: username={}", username);
        authService.register(username, password);
        return Result.success("注册成功");
    }

    @PostMapping("/register-email")
    public Result<String> registerByEmail(
            @RequestParam String email,
            @RequestParam String password,
            @RequestParam String verifyCode) {
        log.info("用户注册: email={}", email);
        authService.registerByEmail(email, password,verifyCode);
        return Result.success("注册成功");
    }

    @PostMapping("/login")
    public Result<UserInfoVO> loginByPassword(
            @RequestParam String param,
            @RequestParam String password) {
        log.info("用户登录: param={}", param);
        UserInfoVO userInfoVO = authService.loginByPsd(param, password);
        return Result.success(userInfoVO);
    }

    @PostMapping("/login-email")
    public Result<UserInfoVO> loginByEmail(
            @RequestParam String email,
            @RequestParam String verifyCode) {
        log.info("用户登录: param={},email={}", email,verifyCode);
        UserInfoVO userInfoVO = authService.loginByEmail(email, verifyCode);
        return Result.success(userInfoVO);
    }

    @PostMapping("/login-phone")
    public Result<UserInfoVO> loginByPhone(
            @RequestParam String phone,
            @RequestParam String verifyCode) {
        log.info("用户登录: phone={}", phone);
        UserInfoVO userInfoVO = authService.loginByPhone(phone, verifyCode);
        return Result.success(userInfoVO);
    }

    @PostMapping("/register-phone")
    public Result<String> registerByPhone(
            @RequestParam String phone,
            @RequestParam String password,
            @RequestParam String verifyCode) {
        log.info("用户注册: phone={}", phone);
        authService.registerByPhone(phone, password, verifyCode);
        return Result.success("注册成功");
    }

    @PostMapping("/forget-password-phone")
    public Result<String> forgetPasswordByPhone(
            @RequestParam String phone,
            @RequestParam String password,
            @RequestParam String verifyCode) {
        log.info("用户修改密码: phone={}", phone);
        authService.updatePasswordByPhone(phone, password, verifyCode);
        return Result.success("修改密码成功!");
    }

    @PostMapping("/send-email-code")
    public Result<String> sendEmailCode(
            @RequestParam String email,
            @RequestParam String type) {
        log.info("发送邮箱验证码: email={}, type={}", email, type);
        emailService.sendEmailVerifyCode(email, type);
        return Result.success("验证码已发送");
    }

    @PostMapping("/send-phone-code")
    public Result<String> sendPhoneCode(@RequestParam String phone) {
        log.info("发送手机验证码: phone={}", phone);
        return Result.success("验证码已发送");
    }

    @PostMapping("/reset")
    public Result<String> forget(
            @RequestParam String username,
            @RequestParam String oldPassword,
            @RequestParam String newPassword) {
        log.info("用户修改密码: username={}", username);
        authService.updatePassword(username, oldPassword, newPassword);
        return Result.success("修改密码成功!");
    }

    @PostMapping("/username")
    public Result<String> updateUsername(@RequestBody Map<String, String> params) {
        Long id = BaseContext.getCurrentId();
        if (id == null) return Result.fail("用户未登录");
        String username = params.get("username");
        String password = params.get("password");
        String verifyCode = params.get("verifyCode");
        log.info("用户修改用户名: id={}, username={}", id, username);
        authService.updateUsername(id, username, password, verifyCode);
        return Result.success("修改用户名成功!");
    }

    @PostMapping("/forget-password")
    public Result<String> forgetPassword(
            @RequestParam String email,
            @RequestParam String password,
            @RequestParam String verifyCode) {
        log.info("用户修改密码: email={}", email);
        authService.updatePasswordByEmail(email, password, verifyCode);
        return Result.success("修改密码成功!");
    }

    @PutMapping()
    public Result<UserInfoVO> update(@RequestBody UserDTO userDTO) {
        log.info("用户修改信息: Id={}", userDTO.getId());
        UserInfoVO userInfoVO = authService.updateUserInfo(userDTO);
        return Result.success(userInfoVO);
    }

    @DeleteMapping("/{id}")
    public Result<String> delete(@PathVariable Long id) {
        log.info("用户注销: id={}", id);
        authService.deleteUser(id);
        return Result.success("注销成功!");
    }
}
