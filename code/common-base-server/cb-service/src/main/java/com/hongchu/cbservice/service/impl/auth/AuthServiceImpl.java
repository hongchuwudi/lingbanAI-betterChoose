package com.hongchu.cbservice.service.impl.auth;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hongchu.cbcommon.context.BaseContext;
import com.hongchu.cbcommon.context.BusinessContext;
import com.hongchu.cbcommon.context.EmailConstants;
import com.hongchu.cbcommon.context.ErrorMessageConstants;
import com.hongchu.cbcommon.context.LoginConstants;
import com.hongchu.cbcommon.exception.BusinessException;
import com.hongchu.cbcommon.util.SimplePasswordEncoder;
import com.hongchu.cbpojo.dto.UserDTO;
import com.hongchu.cbpojo.entity.User;
import com.hongchu.cbpojo.entity.UserRole;
import com.hongchu.cbpojo.vo.UserInfoVO;
import com.hongchu.cbservice.mapper.UserMapper;
import com.hongchu.cbservice.service.impl.common.VerifyCodeService;
import com.hongchu.cbservice.service.interfaces.auth.IAuthService;
import com.hongchu.cbservice.service.interfaces.auth.IChildProfileService;
import com.hongchu.cbservice.service.interfaces.auth.IElderlyProfileService;
import com.hongchu.cbservice.service.interfaces.auth.IJwtService;
import com.hongchu.cbservice.service.interfaces.auth.IUserRoleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
@RequiredArgsConstructor
public class AuthServiceImpl extends ServiceImpl<UserMapper, User> implements IAuthService {
    private final UserMapper userMapper;
    private final VerifyCodeService vcs;
    private final IUserRoleService userRoleService;
    private final IJwtService jwtService;
    private final IElderlyProfileService elderlyProfileService;
    private final IChildProfileService childProfileService;

    // 根据nickname查找用户信息
    @Override
    public UserInfoVO getUserInfoByNick(String nick) {
        User user = lambdaQuery().eq(User::getNickname, nick).one();
        if (user == null) throw new BusinessException(ErrorMessageConstants.ERROR_USER_NOT_EXISTS);

        // 查询用户角色
        UserRole userRole = userRoleService.getUserRoleByUserId(user.getId());
        String roleCode = userRole != null ? userRole.getRoleCode() : "user";
        String roleCategory = userRole != null ? userRole.getRoleCategory() : "GUEST";
        String roleName = userRole != null ? userRole.getRoleName() : "普通用户";

        UserInfoVO userInfoVO = new UserInfoVO();
        BeanUtils.copyProperties(user, userInfoVO);
        userInfoVO.setRoleCode(roleCode);
        userInfoVO.setRoleCategory(roleCategory);
        userInfoVO.setRoleName(roleName);
        userInfoVO.setRoleDescription(userRole != null ? userRole.getRoleDescription() : null);
        userInfoVO.setIsActive(userRole != null ? userRole.getIsActive() : true);

        // 查询老人档案信息
        userInfoVO.setElderlyProfile(elderlyProfileService.getElderlyProfileByUserId(user.getId()));
        // 查询子女档案信息
        userInfoVO.setChildProfile(childProfileService.getChildProfileByUserId(user.getId()));

        return userInfoVO;
    }

    // 根据猜想参数查找用户信息
    @Override
    public UserInfoVO getUserInfo(String param) {
        User user = null;
        // 1. ID: 纯数字
        if (param.matches(LoginConstants.REGEX_ID))
            user = lambdaQuery().eq(User::getId, Long.parseLong(param)).one();
            // 2. 手机号: 加法符号开头 + 若干位数字 + 空格 + 若干位纯数字
        else if (param.matches(LoginConstants.REGEX_PHONE_INTERNATIONAL))
            user = lambdaQuery().eq(User::getPhone, param).one();
            // 3. 邮箱: 纯字符串 + @ + 纯字符串 + . + 纯字符串
        else if (param.matches(LoginConstants.REGEX_EMAIL_SIMPLE))
            user = lambdaQuery().eq(User::getEmail, param).one();
            // 4. 账号: 6-18位 大小写字母 + 数字
        else if (param.matches(LoginConstants.REGEX_USERNAME))
            user = lambdaQuery().eq(User::getUsername, param).one();

        if (user == null) throw new BusinessException(ErrorMessageConstants.ERROR_USER_NOT_EXISTS);

        // 查询用户角色
        UserRole userRole = userRoleService.getUserRoleByUserId(user.getId());
        String roleCode = userRole != null ? userRole.getRoleCode() : "user";
        String roleCategory = userRole != null ? userRole.getRoleCategory() : "GUEST";
        String roleName = userRole != null ? userRole.getRoleName() : "普通用户";

        UserInfoVO userInfoVO = new UserInfoVO();
        BeanUtils.copyProperties(user, userInfoVO);
        userInfoVO.setRoleCode(roleCode);
        userInfoVO.setRoleCategory(roleCategory);
        userInfoVO.setRoleName(roleName);
        userInfoVO.setRoleDescription(userRole != null ? userRole.getRoleDescription() : null);
        userInfoVO.setIsActive(userRole != null ? userRole.getIsActive() : true);

        // 查询老人档案信息
        userInfoVO.setElderlyProfile(elderlyProfileService.getElderlyProfileByUserId(user.getId()));
        // 查询子女档案信息
        userInfoVO.setChildProfile(childProfileService.getChildProfileByUserId(user.getId()));

        return userInfoVO;
    }

    // 获取当前登录用户信息
    @Override
    public UserInfoVO getCurrentUser() {
        Long userId = BaseContext.getCurrentId();
        if (userId == null)
            throw new BusinessException(ErrorMessageConstants.ERROR_USER_NOT_LOGIN);

        User user = lambdaQuery().eq(User::getId, userId).one();
        if (user == null)
            throw new BusinessException(ErrorMessageConstants.ERROR_USER_NOT_EXISTS);

        // 查询用户角色
        UserRole userRole = userRoleService.getUserRoleByUserId(user.getId());
        String roleCode = userRole != null ? userRole.getRoleCode() : "user";
        String roleCategory = userRole != null ? userRole.getRoleCategory() : "GUEST";
        String roleName = userRole != null ? userRole.getRoleName() : "普通用户";

        UserInfoVO userInfoVO = new UserInfoVO();
        BeanUtils.copyProperties(user, userInfoVO);
        userInfoVO.setRoleCode(roleCode);
        userInfoVO.setRoleCategory(roleCategory);
        userInfoVO.setRoleName(roleName);
        userInfoVO.setRoleDescription(userRole != null ? userRole.getRoleDescription() : null);
        userInfoVO.setIsActive(userRole != null ? userRole.getIsActive() : true);

        // 查询老人档案信息
        userInfoVO.setElderlyProfile(elderlyProfileService.getElderlyProfileByUserId(user.getId()));
        // 查询子女档案信息
        userInfoVO.setChildProfile(childProfileService.getChildProfileByUserId(user.getId()));

        return userInfoVO;
    }

    // 登录-参数猜想+密码(用户名/手机号/邮箱)
    @Override
    public UserInfoVO loginByPsd(String param, String password) {
        // 1.校验用户输入信息是否正确
        if (param == null || password == null)
            throw new BusinessException(ErrorMessageConstants.ERROR_USERNAME_PASSWORD_EMPTY);

        // 2.参数猜想和验证
        User user = null;
        String loginType = "";

        // 2.1 手机号: 纯11位数字
        if (param.matches(LoginConstants.REGEX_PHONE_SIMPLE)) {
            param = "+86 " + param; // 添加国际区号前缀
            user = lambdaQuery().eq(User::getPhone, param).one();
            loginType = "手机号";
        }
        // 2.2 邮箱: 包含@和.
        else if (param.matches(LoginConstants.REGEX_EMAIL_SIMPLE)) {
            user = lambdaQuery().eq(User::getEmail, param).one();
            loginType = "邮箱";
        }
        // 2.3 用户名: 符合用户名格式
        else if (param.matches(LoginConstants.REGEX_USERNAME)) {
            user = lambdaQuery().eq(User::getUsername, param).one();
            loginType = "用户名";
        }
        // 2.4 参数格式错误
        else throw new BusinessException("登录参数格式错误，请输入正确的手机号、邮箱或用户名");

        // 3.检查用户是否存在
        if (user == null)
            throw new BusinessException("账户不存在，请检查" + loginType + "是否正确");

        // 3.校验密码是否正确
        if (!SimplePasswordEncoder.verify(password, user.getPasswordHash(), user.getSalt()))
            throw new BusinessException(ErrorMessageConstants.ERROR_PASSWORD_INCORRECT);

        // 4.登录成功
        log.info("用户登录成功-{}(id:{})...", loginType,user.getId());

        UserInfoVO userInfoVO = new UserInfoVO();
        BeanUtils.copyProperties(user, userInfoVO);

        // 5.查询用户角色
        UserRole userRole = userRoleService.getUserRoleByUserId(user.getId());
        String roleCode = userRole != null ? userRole.getRoleCode() : "user";
        String roleCategory = userRole != null ? userRole.getRoleCategory() : "GUEST";
        String roleName = userRole != null ? userRole.getRoleName() : "普通用户";
        userInfoVO.setRoleCode(roleCode);
        userInfoVO.setRoleCategory(roleCategory);
        userInfoVO.setRoleName(roleName);
        userInfoVO.setRoleDescription(userRole != null ? userRole.getRoleDescription() : null);
        userInfoVO.setIsActive(userRole != null ? userRole.getIsActive() : true);

        // 6. 签发token
        String t = jwtService.generateAccessToken(user.getId(), user.getUsername(), roleCode, roleCategory);
        String rt = jwtService.generateRefreshToken(user.getId(), user.getUsername(), roleCode, roleCategory);
        userInfoVO.setToken(t);
        userInfoVO.setRefreshToken(rt);

        // 7.查询老人档案信息
        userInfoVO.setElderlyProfile(elderlyProfileService.getElderlyProfileByUserId(user.getId()));
        // 8.查询子女档案信息
        userInfoVO.setChildProfile(childProfileService.getChildProfileByUserId(user.getId()));

        // 9.返回用户信息
        return userInfoVO;
    }

    // 登录-邮箱验证码验证
    @Override
    public UserInfoVO loginByEmail(String email, String verifyCode) {
        // 1.校验用户输入信息是否正确
        if (email == null || verifyCode == null)
            throw new BusinessException(ErrorMessageConstants.ERROR_USERNAME_PASSWORD_EMPTY);

        // 2.校验邮箱格式
        if (!email.matches(LoginConstants.REGEX_EMAIL_SIMPLE))
            throw new BusinessException(ErrorMessageConstants.ERROR_EMAIL_FORMAT);

        // 3.验证邮箱验证码
        vcs.verifyCode(email, verifyCode, BusinessContext.BUSINESS_TYPE_LOGIN);

        // 4.查询用户
        User user = lambdaQuery().eq(User::getEmail, email).one();
        if (user == null) throw new BusinessException(ErrorMessageConstants.ERROR_USER_NOT_EXISTS);

        // 5.查询用户角色
        UserRole userRole = userRoleService.getUserRoleByUserId(user.getId());
        String roleCode = userRole != null ? userRole.getRoleCode() : "user";
        String roleCategory = userRole != null ? userRole.getRoleCategory() : "GUEST";
        String roleName = userRole != null ? userRole.getRoleName() : "普通用户";

        // 6.签发token
        String token = jwtService.generateAccessToken(user.getId(), user.getUsername(), roleCode, roleCategory);
        String refreshToken = jwtService.generateRefreshToken(user.getId(), user.getUsername(), roleCode, roleCategory);

        // 7.构建返回信息
        UserInfoVO userInfoVO = new UserInfoVO();
        BeanUtils.copyProperties(user, userInfoVO);
        userInfoVO.setRoleCode(roleCode);
        userInfoVO.setRoleCategory(roleCategory);
        userInfoVO.setRoleName(roleName);
        userInfoVO.setRoleDescription(userRole != null ? userRole.getRoleDescription() : null);
        userInfoVO.setIsActive(userRole != null ? userRole.getIsActive() : true);
        userInfoVO.setToken(token);
        userInfoVO.setRefreshToken(refreshToken);

        // 8.查询老人档案信息
        userInfoVO.setElderlyProfile(elderlyProfileService.getElderlyProfileByUserId(user.getId()));
        // 9.查询子女档案信息
        userInfoVO.setChildProfile(childProfileService.getChildProfileByUserId(user.getId()));

        // 10.登录成功
        log.info("用户邮箱验证码登录成功(id:{}, email:{})...", user.getId(), email);

        // TODO 用户登录成功，更新ws状态
        return userInfoVO;
    }

    // 登录-手机验证码验证
    @Override
    public UserInfoVO loginByPhone(String phone,String verifyCode) {
        return null;
    }

    // 注册-用户名密码注册
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void register(String username, String password) {
        // 1.校验用户输入信息是否正确
        if (username == null || password == null)
            throw new BusinessException(ErrorMessageConstants.ERROR_USERNAME_PASSWORD_EMPTY);

        // 2.正则校验用户名和密码格式
        if (!username.matches(LoginConstants.REGEX_USERNAME))
            throw new BusinessException(ErrorMessageConstants.ERROR_USERNAME_FORMAT);
        if (!password.matches(LoginConstants.REGEX_PASSWORD))
            throw new BusinessException(ErrorMessageConstants.ERROR_PASSWORD_FORMAT);

        // 3.校验用户是否存在
        User user = lambdaQuery().eq(User::getUsername, username).one();
        if (user != null) throw new BusinessException(ErrorMessageConstants.ERROR_USER_ALREADY_EXISTS);

        // 4.生成盐和加密密码
        String salt = SimplePasswordEncoder.generateSalt();
        String passwordHash = SimplePasswordEncoder.encrypt(password, salt);

        // 5.创建用户
        user = new User();
        user.setUsername(username);
        user.setPasswordHash(passwordHash);
        user.setSalt(salt);
        user.setNickname(LoginConstants.DEFAULT_NICKNAME_PREFIX + username);

        save(user);
        log.info("用户注册成功-用户名密码注册(id:{})...", user.getId());
    }

    // 注册-邮箱注册
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void registerByEmail(String email, String password, String verifyCode) {
        // 1.基础字段是否为空
        if (email == null || password == null || verifyCode == null)
            throw new BusinessException(ErrorMessageConstants.ERROR_PARAM_NULL);

        // 2.根据邮箱获取缓存验证码校验验证码
        vcs.verifyCode(email, verifyCode, BusinessContext.BUSINESS_TYPE_REGISTER);

        // 3.校验用户密码
        if (!password.matches(LoginConstants.REGEX_PASSWORD))
            throw new BusinessException(ErrorMessageConstants.ERROR_PASSWORD_FORMAT);

        // 4. 检查用户是否已存在
        Long count = lambdaQuery().eq(User::getEmail, email).count();
        if (count > 0) throw new BusinessException(ErrorMessageConstants.ERROR_EMAIL_ALREADY_EXISTS);

        // 5.生成基本信息,保存密码哈希
        User user;
        String salt = SimplePasswordEncoder.generateSalt();
        String passwordHash = SimplePasswordEncoder.encrypt(password, salt);
        user = User.builder()
                .id(null)
                .email(email)
                .username(EmailConstants.DEFAULT_USERNAME + System.currentTimeMillis()) // 随机username = 邮箱前缀 + 时间戳
                .passwordHash(passwordHash)
                .salt(salt)
                .nickname(LoginConstants.DEFAULT_NICKNAME_PREFIX + email.substring(0, email.indexOf("@")))
                .updateUnTimes(2)
                .build();

        // 6.保存用户
        save(user);

        log.info("用户注册成功-邮箱注册(id:{})...", user.getId());
    }

    // 注册用户-手机号+密码
    @Override
    public void registerByPhone(String phone, String password, String verifyCode){

    }

    // 修改username-多种验证方式
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateUsername(Long id, String username, String password, String verifyCode) {
        // 1.查询用户是否存在
        User user = lambdaQuery().eq(User::getId, id).one();
        if (user == null)
            throw new BusinessException(ErrorMessageConstants.ERROR_USER_NOT_EXISTS);

        // 2.查看用户是否有更改资格
        log.info("用户{}存在,修改username的剩余次数为{}", user.getId(), user.getUpdateUnTimes());
        if (user.getUpdateUnTimes() <= 0)
            throw new BusinessException(ErrorMessageConstants.ERROR_USER_UPDATE_UNTIMES_ZERO);

        // 3.校验参数是否正确
        // 3.1 参数是否为空
        if (username == null)
            throw new BusinessException("用户名" + ErrorMessageConstants.ERROR_PARAM_NULL);

        // 3.2 正则校验用户名格式
        if (!username.matches(LoginConstants.REGEX_USERNAME))
            throw new BusinessException(ErrorMessageConstants.ERROR_USERNAME_FORMAT);

        // 3.3 校验用户名是否已存在
        User existingUser = lambdaQuery().eq(User::getUsername, username).one();
        if (existingUser != null && !existingUser.getId().equals(id))
            throw new BusinessException(ErrorMessageConstants.ERROR_USER_ALREADY_EXISTS);

        // 3.4 校验用户名是否与当前相同
        if (username.equals(user.getUsername()))
            throw new BusinessException(ErrorMessageConstants.ERROR_USERNAME_SAME);

        // 4.两种校验方式二选一
        boolean isAuthenticated = false;

        // 4.1 优先使用密码校验
        if (password != null && !password.trim().isEmpty()) {
            if (SimplePasswordEncoder.verify(password, user.getPasswordHash(), user.getSalt()))
                isAuthenticated = true;
            else throw new BusinessException(ErrorMessageConstants.ERROR_PASSWORD_INCORRECT);
        }
        // 4.2 如果没有密码，使用邮箱验证
        else if (verifyCode != null && !verifyCode.trim().isEmpty()) {
            // 使用正确的业务类型
            if (vcs.verifyCode(user.getEmail(), verifyCode, BusinessContext.BUSINESS_TYPE_CHANGE_USERNAME))
                isAuthenticated = true;
            else throw new BusinessException(ErrorMessageConstants.ERROR_EMAIL_VERIFY_CODE_EXPIRED);
        }

        // 4.3 两种方式都没有提供
        if (!isAuthenticated)
            throw new BusinessException(ErrorMessageConstants.ERROR_USER_UNKNOWN_VERIFY_TYPE);

        // 5.修改用户名并更改剩余次数
        user.setUsername(username);
        user.setUpdateUnTimes(user.getUpdateUnTimes() - 1);
        updateById(user);

        log.info("用户修改用户名成功(id:{})...", user.getId());
    }

    // 修改密码-根据旧密码
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updatePassword(String username, String oldPassword, String newPassword) {
        // 1.校验输入参数
        if (username == null || oldPassword == null || newPassword == null)
            throw new BusinessException(ErrorMessageConstants.ERROR_USERNAME_PASSWORD_EMPTY);

        // 2.校验新旧密码是否相同
        if (oldPassword.equals(newPassword))
            throw new BusinessException(ErrorMessageConstants.ERROR_PASSWORD_SAME);

        // 3.正则校验新密码格式
        if (!newPassword.matches(LoginConstants.REGEX_PASSWORD))
            throw new BusinessException(ErrorMessageConstants.ERROR_PASSWORD_FORMAT);

        // 4.校验用户是否存在
        User user = lambdaQuery()
                .eq(User::getUsername, username)
                .one();
        if (user == null)
            throw new BusinessException(ErrorMessageConstants.ERROR_USER_NOT_EXISTS);

        // 5.校验旧密码是否正确
        if (!SimplePasswordEncoder.verify(oldPassword, user.getPasswordHash(), user.getSalt()))
            throw new BusinessException(ErrorMessageConstants.ERROR_PASSWORD_INCORRECT);

        // 6.修改密码
        user.setPasswordHash(SimplePasswordEncoder.encrypt(newPassword, user.getSalt()));

        // 7.保存用户
        updateById(user);
        log.info("用户密码修改成功(id:{})...", user.getId());
    }

    // 忘记密码-根据邮箱验证
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updatePasswordByEmail(String email, String password, String verifyCode) {
        // 1.校验用户是否存在
        User user = lambdaQuery()
                .eq(User::getEmail, email)
                .one();
        if (user == null)
            throw new BusinessException(ErrorMessageConstants.ERROR_USER_NOT_EXISTS);

        // 2.校验输入参数
        // 2.1 非空校验
        if (email == null || password == null || verifyCode == null)
            throw new BusinessException(ErrorMessageConstants.ERROR_USER_NULL);

        // 2.2 校验邮箱格式
        if (!email.matches(LoginConstants.REGEX_EMAIL))
            throw new BusinessException(ErrorMessageConstants.ERROR_EMAIL_FORMAT);

        // 2.3 密码校验
        if (!password.matches(LoginConstants.REGEX_PASSWORD))
            throw new BusinessException(ErrorMessageConstants.ERROR_PASSWORD_FORMAT);

        // 3. 验证邮箱验证码
        if (!vcs.verifyCode(email, verifyCode,BusinessContext.BUSINESS_TYPE_FORGET_PWD))
            throw new BusinessException(ErrorMessageConstants.ERROR_EMAIL_VERIFY_CODE_EXPIRED);

        // 4. 生成新密码哈希并更新
        user.setPasswordHash(SimplePasswordEncoder.encrypt(password, user.getSalt()));
        updateById(user);

        log.info("密码重置成功，邮箱：{}", email);
    }

    // 忘记密码-根据手机号验证
    @Override
    public void updatePasswordByPhone(String phone, String password, String verifyCode){

    }

    // 更新用户信息
    @Override
    public UserInfoVO updateUserInfo(UserDTO userDTO) {
        if (userDTO == null) throw new BusinessException(ErrorMessageConstants.ERROR_USER_NULL);
        // 1.检查用户是否存在
        User user = getById(userDTO.getId());
        if (user == null) throw new BusinessException(ErrorMessageConstants.ERROR_USER_NOT_EXISTS);

        // 2.检查参数并更新字段（只更新非 null 的字段）
        if (userDTO.getNickname() != null) {
            user.setNickname(userDTO.getNickname());
        }
        if (userDTO.getPhone() != null) {
            String phone = userDTO.getPhone();
            if (phone.matches("^1[3-9]\\d{9}$")) {
                phone = "+86 " + phone;
            }
            user.setPhone(phone);
        }
        if (userDTO.getEmail() != null) {
            user.setEmail(userDTO.getEmail());
        }
        if (userDTO.getAvatar() != null) {
            user.setAvatar(userDTO.getAvatar());
        }
        if (userDTO.getBirthday() != null) {
            user.setBirthday(userDTO.getBirthday());
        }
        if (userDTO.getGender() != null) {
            user.setGender(userDTO.getGender());
        }
        if (userDTO.getBio() != null) {
            user.setBio(userDTO.getBio());
        }
        if (userDTO.getIsVip() != null) {
            user.setIsVip(userDTO.getIsVip());
        }

        updateById(user);
        log.info("用户信息更新成功(id:{})...", user.getId());

        // 3.查询更新后的用户信息
        return getUserInfo(user.getId().toString());
    }

    // 删除用户
    @Override
    public void deleteUser(Long id) {
        // 先检查用户是否存在
        User user = getById(id);
        if (user == null) throw new BusinessException(ErrorMessageConstants.ERROR_USER_NOT_EXISTS);

        // 执行删除
        boolean success = removeById(id);
        if (!success) throw new BusinessException(ErrorMessageConstants.ERROR_USER_DELETE);

        log.info("用户注销成功(id:{})...", id);
    }
}