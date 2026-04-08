// LoginConstants.java
package com.hongchu.cbcommon.context;

/**
 * 登录相关常量
 */
public final class LoginConstants {
    
    private LoginConstants() {
        // 防止实例化
    }
    
    // Redis Key 前缀
    public static final String REDIS_LOGIN_ATTEMPT_PREFIX = "login:attempt:";
    public static final String REDIS_LOGIN_LOCK_PREFIX = "login:lock:";
    public static final String REDIS_TOKEN_PREFIX = "login:token:";
    
    // 登录限制配置
    public static final int MAX_LOGIN_ATTEMPTS = 5;
    public static final int LOGIN_LOCK_DURATION_MINUTES = 15;
    public static final int LOGIN_ATTEMPT_EXPIRE_MINUTES = 30;
    public static final int TOKEN_EXPIRE_HOURS = 24;
    
    // 错误消息
    public static final String MSG_LOGIN_LOCKED = "登录失败次数过多，请{}分钟后重试";
    public static final String MSG_LOGIN_ATTEMPTS_LEFT = "密码错误，还剩{}次尝试机会";
    public static final String MSG_ACCOUNT_LOCKED = "登录失败次数过多，账户已被锁定{}分钟";
    
    // 用户名和密码长度限制
    public static final int USERNAME_MIN_LENGTH = 6;
    public static final int USERNAME_MAX_LENGTH = 18;
    public static final int PASSWORD_MIN_LENGTH = 6;
    public static final int PASSWORD_MAX_LENGTH = 18;
    
    // 正则表达式
    public static final String REGEX_USERNAME = "^[a-zA-Z0-9]{" + USERNAME_MIN_LENGTH + "," + USERNAME_MAX_LENGTH + "}$";
    public static final String REGEX_PASSWORD = "^(?=.*[a-zA-Z])(?=.*\\d)[a-zA-Z0-9@#$%^&+=-_]{" + PASSWORD_MIN_LENGTH + "," + PASSWORD_MAX_LENGTH + "}$";
    public static final String REGEX_EMAIL = "^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$";

    // 参数猜想
    public static final String REGEX_ID = "^\\d+$";
    public static final String REGEX_PHONE_INTERNATIONAL = "^\\+\\d{1,4}\\s\\d{4,15}$";
    public static final String REGEX_PHONE_SIMPLE = "^1[3-9]\\d{9}$";
    public static final String REGEX_EMAIL_SIMPLE = "^\\w+@\\w+\\.\\w+$";

    // 默认值
    public static final String DEFAULT_NICKNAME_PREFIX = "User-";
    public static final String DEFAULT_AVATAR_URL = "/avatar/default.png";
}