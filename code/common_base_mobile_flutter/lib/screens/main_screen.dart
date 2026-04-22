import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/nav_config.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/bottom_nav_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    final user = authStore.user;

    final navItems = NavConfig.getNavItems(user);

    if (navItems.isEmpty) {
      return Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (_) => false),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('无法加载菜单',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  '点击屏幕重新登录',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return BottomNavBar(
          items: navItems,
          currentIndex: navigationProvider.currentIndex,
          onTap: (index) {
            navigationProvider.setCurrentIndex(index);
          },
        );
      },
    );
  }
}
