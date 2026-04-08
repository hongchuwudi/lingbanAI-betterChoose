package com.hongchu.cbcommon.context;

public final class ErrorMessageConstants {
    private ErrorMessageConstants() {}
    // 基本类型
    public static final String ERROR_PARAM_NULL = "参数不能为空";
    public static final String ERROR_PARAM_INVALID = "参数格式错误";

    // 用户类型
    public static final String ERROR_USER_NOT_EXISTS = "用户不存在";
    public static final String ERROR_USER_ALREADY_EXISTS = "用户已存在";
    public static final String ERROR_PASSWORD_INCORRECT = "用户密码错误";
    public static final String ERROR_USERNAME_PASSWORD_EMPTY = "用户名或密码不能为空";
    public static final String ERROR_USERNAME_FORMAT = "用户名格式错误，请输入" + LoginConstants.USERNAME_MIN_LENGTH + "-" +LoginConstants.USERNAME_MAX_LENGTH + "位长度的字母或数字";
    public static final String ERROR_PASSWORD_FORMAT = "密码格式错误，必须包含字母和数字，可选10种特殊字符(@#$%^&+=-_)，长度"+ LoginConstants.PASSWORD_MIN_LENGTH + "-" +LoginConstants.PASSWORD_MAX_LENGTH + "位";
    public static final String ERROR_PASSWORD_SAME = "新密码不能与旧密码相同";
    public static final String ERROR_USERNAME_SAME = "新用户名不能与旧用户名相同";
    public static final String ERROR_USER_NOT_LOGIN = "用户未登录";
    public static final String ERROR_USER_NULL = "用户信息不能为空";
    public static final String ERROR_USER_DELETE = "用户注销失败";
    public static final String ERROR_USER_UPDATE_UNTIMES_ZERO = "用户已无用户名更改次数,如需更改请联系虹初";
    public static final String ERROR_USER_UNKNOWN_VERIFY_TYPE = "必须提供密码或验证码进行身份验证";
    public static final String ERROR_USER_ID_NULL = "用户ID不能为空";

    // 邮件类型
    public static final String ERROR_EMAIL_NOT_EXISTS = "邮箱不存在";
    public static final String ERROR_EMAIL_NOT_LOGIN = "邮箱格式错误";
    public static final String ERROR_EMAIL_ALREADY_EXISTS = "邮箱已存在";
    public static final String ERROR_EMAIL_FORMAT = "邮箱格式错误";
    public static final String ERROR_EMAIL_SEND = "邮件发送失败";
    public static final String ERROR_EMAIL_VERIFY_CODE_EXPIRED = "验证码已过期/验证码不存在";
    public static final String ERROR_EMAIL_VERIFY_CODE_INCORRECT = "验证码错误";
    public static final String ERROR_EMAIL_VERIFY_CODE_NULL = "验证码不能为空";
    public static final String ERROR_EMAIL_VERIFY_CODE_SEND = "验证码发送失败";

    //
}