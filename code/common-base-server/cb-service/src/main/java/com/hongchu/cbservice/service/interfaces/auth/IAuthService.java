package com.hongchu.cbservice.service.interfaces.auth;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hongchu.cbpojo.dto.UserDTO;
import com.hongchu.cbpojo.entity.User;
import com.hongchu.cbpojo.vo.UserInfoVO;

public interface IAuthService extends IService<User> {
    // 获取用户信息-根据昵称
    UserInfoVO getUserInfoByNick(String nickname);
    // 获取用户信息-根据参数猜想(用户名/手机号/邮箱)
    UserInfoVO getUserInfo(String param);
    // 获取当前登录用户信息
    UserInfoVO getCurrentUser();
    // 登录-参数猜想(用户名/手机号/邮箱)+密码
    UserInfoVO loginByPsd(String param, String password);
    // 登录-邮箱验证码验证
    UserInfoVO loginByEmail(String email,String verifyCode);
    // 登录-手机验证码验证
    UserInfoVO loginByPhone(String phone,String verifyCode);
    // 注册用户-用户名+密码
    void register(String username, String password);
    // 注册用户-邮箱+密码
    void registerByEmail(String email, String password, String verifyCode);
    // 注册用户-手机号+密码
    void registerByPhone(String phone, String password, String verifyCode);
    // 更改用户名username
    void updateUsername(Long id, String username,String password,String verifyCode);
    // 忘记密码-根据邮箱验证
    void updatePasswordByEmail(String email, String password, String verifyCode);
    // 忘记密码-根据手机号验证
    void updatePasswordByPhone(String phone, String password, String verifyCode);
    // 修改密码-用户名+旧密码
    void updatePassword(String username, String oldPassword, String newPassword);
    // 修改用户信息
    UserInfoVO updateUserInfo(UserDTO userDTO);
    // 注销用户
    void deleteUser(Long id);
}
