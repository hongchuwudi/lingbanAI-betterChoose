package com.hongchu.cbservice.controller;

import java.util.Map;

import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbcommon.result.Result;
import com.hongchu.cbpojo.dto.UserDTO;
import com.hongchu.cbpojo.vo.UserInfoVO;
import com.hongchu.cbservice.annotation.Role;
import com.hongchu.cbservice.service.interfaces.auth.IAuthService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 系统认证
 * @author HongChu
 * @deprecated  用于登录,注册,获取信息,修改信息
 */
@Slf4j
@RestController
@RequestMapping("/auth")
@CrossOrigin
@Role(enabled = false) // 认证相关接口默认公开，不需要权限校验
public class AuthController {
    @Autowired private IAuthService authService;

    /**
     * 根据昵称模糊查找用户信息
     */
    @GetMapping("/info-nick")
    public Result<UserInfoVO> getUserInfoByNick(@RequestParam String nickname) {
        log.info("根据NickName用户信息: nickname={}",nickname);
        UserInfoVO user = authService.getUserInfoByNick(nickname);
        return Result.success(user);
    }

    /**
     * 根据参数猜想(ID/手机号/邮箱/账号)查找用户信息
     * ID: 纯数字
     * 手机号: 加法符号开头 + 若干位数字 + 空格 + 11位纯数字
     * 邮箱: 纯字符串 + @ + 纯字符串 + . + 纯字符串
     * 账号: 6-18位 大小写字母 + 符号组合
     */
    @GetMapping("/info-un")
    public Result<UserInfoVO> getUserInfo(@RequestParam String param) {
        log.info("用户信息: 参数猜想param={}", param);
        UserInfoVO user = authService.getUserInfo(param);
        return Result.success(user);
    }

    /**
     * 获取当前登录用户信息
     */
    @GetMapping("/current")
    public Result<UserInfoVO> getCurrentUser() {
        log.info("获取当前登录用户信息");
        UserInfoVO user = authService.getCurrentUser();
        return Result.success(user);
    }

    /**
     * 注册-普通用户
     */
    @PostMapping("/register")
    public Result<String> register(
            @RequestParam String username,
            @RequestParam String password) {
        log.info("用户注册: username={}", username);
        authService.register(username, password);
        return Result.success("注册成功");
    }

    /**
     * 注册-邮箱用户
     */
    @PostMapping("/register-email")
    public Result<String> registerByEmail(
            @RequestParam String email,
            @RequestParam String password,
            @RequestParam String verifyCode) {
        log.info("用户注册: email={}", email);
        authService.registerByEmail(email, password,verifyCode);
        return Result.success("注册成功");
    }

    /**
     * 登录-密码
     * 参数猜想+密码(用户名/手机号/邮箱)
     */
    @PostMapping("/login")
    public Result<UserInfoVO> loginByPassword(
            @RequestParam String param,
            @RequestParam String password) {
        log.info("用户登录: param={}", param);
        UserInfoVO userInfoVO = authService.loginByPsd(param, password);
        return Result.success(userInfoVO);
    }

    /**
     * 登录-邮箱登录
     * 参数猜想+密码(用户名/手机号/邮箱)
     */
    @PostMapping("/login-email")
    public Result<UserInfoVO> loginByEmail(
            @RequestParam String email,
            @RequestParam String verifyCode) {
        log.info("用户登录: param={},email={}", email,verifyCode);
        UserInfoVO userInfoVO = authService.loginByEmail(email, verifyCode);
        return Result.success(userInfoVO);
    }

    /**
     * 登录-手机验证码验证
     */
    @PostMapping("/login-phone")
    public Result<UserInfoVO> loginByPhone(
            @RequestParam String phone,
            @RequestParam String verifyCode) {
        log.info("用户登录: phone={}", phone);
        UserInfoVO userInfoVO = authService.loginByPhone(phone, verifyCode);
        return Result.success(userInfoVO);
    }

    /**
     * 注册用户-手机号+密码
     */
    @PostMapping("/register-phone")
    public Result<String> registerByPhone(
            @RequestParam String phone,
            @RequestParam String password,
            @RequestParam String verifyCode) {
        log.info("用户注册: phone={}", phone);
        authService.registerByPhone(phone, password, verifyCode);
        return Result.success("注册成功");
    }

    /**
     * 忘记密码-根据手机号验证
     */
    @PostMapping("/forget-password-phone")
    public Result<String> forgetPasswordByPhone(
            @RequestParam String phone,
            @RequestParam String password,
            @RequestParam String verifyCode) {
        log.info("用户修改密码: phone={}", phone);
        authService.updatePasswordByPhone(phone, password, verifyCode);
        return Result.success("修改密码成功!");
    }

    /**
     * 发送邮箱验证码
     */
    @PostMapping("/send-email-code")
    public Result<String> sendEmailCode(@RequestParam String email) {
        log.info("发送邮箱验证码: email={}", email);
        // 这里需要调用发送邮箱验证码的服务方法
        return Result.success("验证码已发送");
    }

    /**
     * 发送手机验证码
     */
    @PostMapping("/send-phone-code")
    public Result<String> sendPhoneCode(@RequestParam String phone) {
        log.info("发送手机验证码: phone={}", phone);
        // 这里需要调用发送手机验证码的服务方法
        return Result.success("验证码已发送");
    }

    /**
     * 重置密码
     */
    @PostMapping("/reset")
    public Result<String> forget(
            @RequestParam String username,
            @RequestParam String oldPassword,
            @RequestParam String newPassword) {
        log.info("用户修改密码: username={}", username);
        authService.updatePassword(username, oldPassword, newPassword);
        return Result.success("修改密码成功!");
    }

    /**
     * 修改用户名
     */
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

    /**
     * 忘记密码
     */
    @PostMapping("/forget-password")
    public Result<String> forgetPassword(
            @RequestParam String email,
            @RequestParam String password,
            @RequestParam String verifyCode) {
        log.info("用户修改密码: email={}", email);
        authService.updatePasswordByEmail(email, password, verifyCode);
        return Result.success("修改密码成功!");
    }

    /**
     * 修改用户信息
     */
    @PutMapping()
    public Result<UserInfoVO> update(@RequestBody UserDTO userDTO) {
        log.info("用户修改信息: Id={}", userDTO.getId());
        UserInfoVO userInfoVO = authService.updateUserInfo(userDTO);
        return Result.success(userInfoVO);
    }

    /**
     * 注销用户
     */
    @DeleteMapping("/{id}")
    public Result<String> delete(@PathVariable Long id) {
        log.info("用户注销: id={}", id);
        authService.deleteUser(id);
        return Result.success("注销成功!");
    }
}
