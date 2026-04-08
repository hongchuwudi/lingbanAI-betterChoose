import 'package:flutter/material.dart';
import '../models/theme_model.dart';

/// 主题切换按钮组件
///
/// 功能说明：
/// - 显示当前主题对应的图标
/// - 点击按钮切换亮色/暗色主题
/// - 支持动画过渡效果
/// - 集成到应用栏或其他位置
///
/// 使用方式：
/// 1. 在需要主题切换的地方使用此组件
/// 2. 通过Provider.of<ThemeModel>(context)获取主题模型
/// 3. 组件会自动监听主题变化并更新UI
class ThemeToggleButton extends StatelessWidget {
  /// 主题模型实例，通过Provider获取
  final ThemeModel themeModel;

  /// 图标大小，默认为24
  final double iconSize;

  /// 按钮大小，默认为40
  final double buttonSize;

  /// 是否有背景，默认为true
  final bool hasBackground;

  /// 构造函数
  ///
  /// 参数：
  /// - themeModel：主题模型实例（必需）
  /// - iconSize：图标大小（可选，默认24）
  /// - buttonSize：按钮大小（可选，默认40）
  /// - hasBackground：是否有背景（可选，默认true）
  const ThemeToggleButton({
    Key? key,
    required this.themeModel,
    this.iconSize = 24,
    this.buttonSize = 40,
    this.hasBackground = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 点击事件：切换主题
      onTap: () {
        themeModel.toggleTheme();
      },
      child: Container(
        width: buttonSize,
        height: buttonSize,
        // 根据是否有背景设置装饰
        decoration: hasBackground
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(buttonSize / 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Icon(
          // 使用主题模型中的图标
          themeModel.themeIcon,
          size: iconSize,
          // 图标颜色使用主题的主色
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// 带文字的主题切换按钮
///
/// 功能说明：
/// - 包含图标和文字描述
/// - 更适合设置页面使用
/// - 显示当前主题模式的文字描述
class ThemeToggleButtonWithText extends StatelessWidget {
  final ThemeModel themeModel;

  const ThemeToggleButtonWithText({Key? key, required this.themeModel})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // 前导图标
      leading: Icon(
        themeModel.themeIcon,
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
      // 标题
      title: const Text('主题模式'),
      // 副标题显示当前主题描述
      subtitle: Text(themeModel.themeModeDescription),
      // 尾随切换图标
      trailing: Switch(
        value: themeModel.isDarkMode,
        onChanged: (value) {
          // 根据开关状态切换主题
          if (value) {
            themeModel.setThemeMode(ThemeMode.dark);
          } else {
            themeModel.setThemeMode(ThemeMode.light);
          }
        },
        // 使用主题的主色
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      // 点击整个列表项也可以切换主题
      onTap: () {
        themeModel.toggleTheme();
      },
    );
  }
}

/// 主题选择对话框
///
/// 功能说明：
/// - 弹出对话框让用户选择主题模式
/// - 支持亮色、暗色、跟随系统三种模式
/// - 显示每种模式的预览
class ThemeSelectionDialog extends StatelessWidget {
  final ThemeModel themeModel;

  const ThemeSelectionDialog({Key? key, required this.themeModel})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择主题'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 亮色主题选项
          _buildThemeOption(
            context,
            ThemeMode.light,
            Icons.wb_sunny,
            '亮色主题',
            '使用明亮的色彩方案',
          ),
          const SizedBox(height: 12),
          // 暗色主题选项
          _buildThemeOption(
            context,
            ThemeMode.dark,
            Icons.nightlight_round,
            '暗色主题',
            '使用深色的色彩方案',
          ),
          const SizedBox(height: 12),
          // 系统主题选项
          _buildThemeOption(
            context,
            ThemeMode.system,
            Icons.brightness_auto,
            '跟随系统',
            '自动跟随系统主题设置',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
      ],
    );
  }

  /// 构建主题选项组件
  Widget _buildThemeOption(
    BuildContext context,
    ThemeMode mode,
    IconData icon,
    String title,
    String description,
  ) {
    final isSelected = themeModel.themeMode == mode;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(title),
      subtitle: Text(description),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      tileColor: isSelected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
          : null,
      onTap: () {
        themeModel.setThemeMode(mode);
        Navigator.of(context).pop();
      },
    );
  }
}
