package com.hongchu.cbcommon.context;

public final class EmailConstants {
    private EmailConstants() {}
    
    public static final int VERIFY_CODE_LENGTH = 6;
    public static final int VERIFY_CODE_EXPIRE_MINUTES = 5;
    public static final String VERIFY_CODE_PREFIX = "verify:code:";

    public static final String EMAIL_SUBJECT_VERIFY_CODE = "验证码通知";
    public static final String EMAIL_TEMPLATE_VERIFY_CODE =
            "【" + CommonData.PROJECT_NAME +  "】\n" +
            "尊敬的用户，您好！\n\n" +
            "您正在进行的操作需要验证身份，本次请求的验证码为：%s\n\n" +
            "此验证码有效期为%d分钟，请在有效期内完成验证。\n" +
            "为了保障您的账户安全，请勿将验证码泄露给任何人。\n\n" +
            "如果您并未发起此请求，可能是他人误输了您的邮箱地址，请忽略此邮件。\n\n" +
            "感谢您使用我们的服务！\n\n" +
            CommonData.PROJECT_NAME + " 团队\n" +
            "%tF";

    public static final int EMAIL_SEND_LIMIT_PER_MINUTE = 1;
    public static final int EMAIL_SEND_LIMIT_PER_HOUR = 5;
    public static final int EMAIL_SEND_LIMIT_PER_DAY = 10;

    public static final String DEFAULT_USERNAME = "emailTempUsername";
    public static final String EMAIL_FORMAT_REG = "^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$";
}
