import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/theme_model.dart';
import '../widgets/theme_toggle_button.dart';

/// 主题演示页面
class ThemeDemoScreen extends StatelessWidget {
  const ThemeDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final surface = colorScheme.surface;
    final primaryContainer = colorScheme.primaryContainer;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text('主题设置', style: TextStyle(color: onSurface)),
        backgroundColor: surface,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ThemeToggleButton(
              themeModel: themeModel,
              iconSize: 24,
              buttonSize: 40,
              hasBackground: true,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentThemeInfo(context, themeModel),
            const SizedBox(height: 24),
            _buildThemeToggleDemo(
              context,
              themeModel,
              primaryContainer,
              primaryColor,
            ), // ✅ 传入 context
            const SizedBox(height: 24),
            _buildUIComponentsDemo(context),
            const SizedBox(height: 24),
            _buildThemeOptions(context, themeModel, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentThemeInfo(BuildContext context, ThemeModel themeModel) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前主题',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  themeModel.themeIcon,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  themeModel.themeModeDescription,
                  style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '当前为${themeModel.isDarkMode ? '暗色' : '亮色'}模式',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 添加 context 参数
  Widget _buildThemeToggleDemo(
    BuildContext context,
    ThemeModel themeModel,
    Color primaryContainer,
    Color primaryColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '主题切换组件',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ThemeToggleButtonWithText(
              themeModel: themeModel,
              primaryContainer: primaryContainer,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  '简单按钮:',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                ThemeToggleButton(
                  themeModel: themeModel,
                  iconSize: 20,
                  buttonSize: 36,
                  hasBackground: true,
                ),
                ThemeToggleButton(
                  themeModel: themeModel,
                  iconSize: 20,
                  buttonSize: 36,
                  hasBackground: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUIComponentsDemo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UI组件演示',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('主要按钮'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('轮廓按钮'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: '示例输入框',
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                hintText: '请输入内容',
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.text_fields,
                  color: colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: colorScheme.surfaceContainerHighest,
              elevation: 0,
              child: ListTile(
                leading: Icon(Icons.palette, color: colorScheme.primary),
                title: Text(
                  '主题颜色卡片',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                subtitle: Text(
                  '展示当前主题的色彩',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOptions(
    BuildContext context,
    ThemeModel themeModel,
    Color primaryColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '主题设置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(
                Icons.brightness_medium,
                color: colorScheme.onSurfaceVariant,
              ),
              title: Text(
                '主题模式',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              subtitle: Text(
                themeModel.themeModeDescription,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                onPressed: () => _showThemeSelectionDialog(context, themeModel),
              ),
              onTap: () => _showThemeSelectionDialog(context, themeModel),
            ),
            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ListTile(
              leading: Icon(
                Icons.swap_horiz,
                color: colorScheme.onSurfaceVariant,
              ),
              title: Text(
                '快速切换',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              subtitle: Text(
                '点击切换亮色/暗色主题',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              trailing: Switch(
                value: themeModel.isDarkMode,
                activeColor: primaryColor,
                onChanged: (value) {
                  if (value) {
                    themeModel.setThemeMode(ThemeMode.dark);
                  } else {
                    themeModel.setThemeMode(ThemeMode.light);
                  }
                },
              ),
              onTap: () => themeModel.toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelectionDialog(BuildContext context, ThemeModel themeModel) {
    showDialog(
      context: context,
      builder: (context) => ThemeSelectionDialog(themeModel: themeModel),
    );
  }
}

/// 带文字的主题切换按钮
class ThemeToggleButtonWithText extends StatelessWidget {
  final ThemeModel themeModel;
  final Color? primaryContainer;
  final Color? primaryColor;

  const ThemeToggleButtonWithText({
    super.key,
    required this.themeModel,
    this.primaryContainer,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => themeModel.toggleTheme(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: primaryContainer ?? colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              themeModel.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              size: 18,
              color: primaryColor ?? colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              themeModel.isDarkMode ? '切换到亮色' : '切换到暗色',
              style: TextStyle(
                fontSize: 14,
                color: primaryColor ?? colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 主题选择对话框
class ThemeSelectionDialog extends StatelessWidget {
  final ThemeModel themeModel;

  const ThemeSelectionDialog({super.key, required this.themeModel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text('选择主题', style: TextStyle(color: colorScheme.onSurface)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            context: context,
            icon: Icons.light_mode,
            title: '亮色模式',
            isSelected: themeModel.themeMode == ThemeMode.light,
            onTap: () {
              themeModel.setThemeMode(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          _buildThemeOption(
            context: context,
            icon: Icons.dark_mode,
            title: '暗色模式',
            isSelected: themeModel.themeMode == ThemeMode.dark,
            onTap: () {
              themeModel.setThemeMode(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
          _buildThemeOption(
            context: context,
            icon: Icons.settings,
            title: '跟随系统',
            isSelected: themeModel.themeMode == ThemeMode.system,
            onTap: () {
              themeModel.setThemeMode(ThemeMode.system);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title, style: TextStyle(color: colorScheme.onSurface)),
      trailing: isSelected
          ? Icon(Icons.check, color: colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
