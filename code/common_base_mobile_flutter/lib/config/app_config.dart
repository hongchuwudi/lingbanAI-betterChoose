/// 应用配置类
/// 这个类用于存储应用的配置信息，包括API地址、应用名称、版本号等
/// 使用静态常量，可以通过类名直接访问，无需创建实例
class AppConfig {
  /// 应用名称 - 显示在应用标题和启动页
  static const String appName = '灵伴AI-守护健康的你';

  /// API基础URL - 后端接口地址，开发环境使用本地地址
  /// Android模拟器请使用 10.0.2.2，真机请使用电脑局域网IP，Windows桌面版使用 localhost
  // static const String apiBaseUrl = 'https://lingban.hongchu.xyz';
  static const String apiBaseUrl = 'https://lingban.hongchu.xyz';

  /// WebSocket基础URL - WebSocket连接地址
  /// Android模拟器请使用 10.0.2.2，真机请使用电脑局域网IP，Windows桌面版使用 localhost
  // static const String wsBaseUrl = 'wss://lingban.hongchu.xyz';
  static const String wsBaseUrl = 'wss://lingban.hongchu.xyz';

  /// 应用版本号 - 用于显示在启动页和关于页面
  static const String appVersion = '1.0.0';

  // ========== 本地存储key ==========
  /// 这些key用于SharedPreferences存储数据时的键名

  /// 用户token存储key - 用于保存登录凭证
  static const String tokenKey = 'user_token';

  /// 用户信息存储key - 用于保存用户基本信息
  static const String userInfoKey = 'user_info';

  /// 首次启动标记key - 用于判断是否是第一次启动应用
  static const String isFirstLaunchKey = 'is_first_launch';

  // ========== 测试账号 ==========
  /// 这些账号用于开发和测试阶段，实际部署时需要移除或修改

  /// 测试手机号/用户名 - 用于登录测试
  static const String testPhone = 'hongchu123';

  /// 测试密码/验证码 - 用于登录测试
  static const String testCode = 'hongchu123';
}
