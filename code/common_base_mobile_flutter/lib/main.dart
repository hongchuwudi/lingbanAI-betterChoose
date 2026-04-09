import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/email_register_screen.dart';
import 'screens/forget_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/health_screen.dart';
import 'screens/message_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notification_demo_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/elderly_profile_screen.dart';
import 'screens/child_profile_screen.dart';
import 'screens/main_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/elder/elder_family_screen.dart';
import 'screens/child/child_family_screen.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'models/theme_model.dart';
import 'models/nav_item.dart';
import 'providers/auth_provider.dart';
import 'providers/navigation_provider.dart';
import 'utils/http_interceptor.dart';
import 'widgets/notification/notification_helper.dart';
import 'widgets/bottom_nav_bar.dart';
import 'services/global_notification_service.dart';

/// 应用入口函数
///
/// 功能说明：
/// - 启动Flutter应用
/// - 使用runApp()方法启动根组件
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  HttpInterceptorManager().initialize(
    baseUrl: AppConfig.apiBaseUrl,
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  );

  NotificationHelper.initialize();

  GlobalNotificationService.instance.initialize();

  runApp(const MyApp());
}

/// 应用根组件
///
/// 功能说明：
/// - 使用Provider进行状态管理
/// - 包裹整个应用，提供主题管理功能
/// - 配置MaterialApp的主题和路由
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      //  改用 MultiProvider
      providers: [
        // 创建主题模型实例
        ChangeNotifierProvider(create: (context) => ThemeModel()),
        //  添加认证 Store
        ChangeNotifierProvider(create: (context) => AuthStore()),
        // 添加导航状态管理
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ],
      child: Consumer3<ThemeModel, AuthStore, NavigationProvider>(
        //  使用 Consumer3
        builder: (context, themeModel, authStore, navigationProvider, child) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: NotificationHelper.navigatorKey,

            // 亮色主题配置
            theme: AppTheme.lightTheme,

            // 暗色主题配置
            darkTheme: AppTheme.darkTheme,

            // 当前主题模式，从主题模型中获取
            themeMode: themeModel.themeMode,

            // 应用首页
            home: const SplashScreen(),

            // 路由配置
            routes: {
              '/welcome': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/email-register': (context) => const EmailRegisterScreen(),
              '/forget-password': (context) => const ForgetPasswordScreen(),
              '/role-selection': (context) => const RoleSelectionScreen(),
              '/elderly-profile': (context) => const ElderlyProfileScreen(),
              '/child-profile': (context) => const ChildProfileScreen(),
              '/home': (context) => const HomeScreen(),
              '/notification-demo': (context) => const NotificationDemoScreen(),
              '/main': (context) => const MainScreen(),
              '/edit-profile': (context) => EditProfileScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/elder-family': (context) => const ElderFamilyScreen(),
              '/child-family': (context) => const ChildFamilyScreen(),
            },
          );
        },
      ),
    );
  }
}
