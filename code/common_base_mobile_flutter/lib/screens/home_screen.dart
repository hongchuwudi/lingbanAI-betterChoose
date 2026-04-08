import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/theme_toggle_button.dart';
import '../models/theme_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/notification/notification_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    setState(() {
      // 直接从 authStore 读取 user
      _userInfo = authStore.user?.toJson() ?? {};
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    NotificationHelper.showInfo(message: '已退出登录');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取主题颜色
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final onSurface = colorScheme.onSurface;
    final surface = colorScheme.surface;
    final surfaceContainerHighest = colorScheme.surfaceContainerHighest;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: Text(
          '首页',
          style: TextStyle(color: onSurface, fontWeight: FontWeight.bold),
        ),
        actions: [
          // 主题切换按钮
          Consumer<ThemeModel>(
            builder: (context, themeModel, child) {
              return ThemeToggleButton(
                themeModel: themeModel,
                iconSize: 20,
                buttonSize: 40,
                hasBackground: false,
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 用户头像
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                size: 40,
                color: primaryColor, // ✅ 使用主题主色
              ),
            ),
            const SizedBox(height: 20),

            // 欢迎信息
            Text(
              _userInfo?['userInfo']?['nickname'] ?? '欢迎回来',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: onSurface, // ✅ 使用主题文字颜色
              ),
            ),
            const SizedBox(height: 8),

            Text(
              '@${_userInfo?['userInfo']?['phone'] ?? '用户'}',
              style: TextStyle(
                fontSize: 14,
                color: onSurface.withValues(alpha: 0.6), // ✅ 次要文字
              ),
            ),
            const SizedBox(height: 40),

            // 首页内容
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              decoration: BoxDecoration(
                color: surfaceContainerHighest, // ✅ 主题背景色
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '首页',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: primaryColor, // ✅ 主题主色
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              '这里是应用的主界面，后续功能将在这里展示',
              style: TextStyle(
                fontSize: 14,
                color: onSurface.withValues(alpha: 0.6), // ✅ 次要文字
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
