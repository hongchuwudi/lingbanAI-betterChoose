import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/theme_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/notification/notification_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '设置',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAppearanceSection(context),
            const SizedBox(height: 16),
            _buildAboutSection(context),
            const SizedBox(height: 16),
            _buildOtherSection(context),
            const SizedBox(height: 16),
            _buildDangerSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildSection(
      context,
      title: '外观设置',
      children: [
        _buildThemeSetting(context),
        _buildDivider(colorScheme),
        _buildFontSizeSetting(context),
      ],
    );
  }

  Widget _buildThemeSetting(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(LucideIcons.palette, color: colorScheme.primary, size: 22),
      title: Text(
        '主题颜色',
        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ),
      subtitle: Text(
        themeModel.themeModeDescription,
        style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 18,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: () => _showThemeDialog(context, themeModel),
    );
  }

  Widget _buildFontSizeSetting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(LucideIcons.type, color: colorScheme.primary, size: 22),
      title: Text(
        '字体大小',
        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ),
      subtitle: Text(
        '标准',
        style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 18,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: () {
        NotificationHelper.showInfo(message: '字体大小设置功能即将上线');
      },
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildSection(
      context,
      title: '关于',
      children: [
        _buildAboutAppSetting(context),
        _buildDivider(colorScheme),
        _buildUserAgreementSetting(context),
        _buildDivider(colorScheme),
        _buildPrivacyPolicySetting(context),
        _buildDivider(colorScheme),
        _buildVersionSetting(context),
      ],
    );
  }

  Widget _buildAboutAppSetting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(LucideIcons.info, color: colorScheme.primary, size: 22),
      title: Text(
        '关于软件',
        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 18,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: () => _showAboutDialog(context),
    );
  }

  Widget _buildUserAgreementSetting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(LucideIcons.fileText, color: colorScheme.primary, size: 22),
      title: Text(
        '用户协议',
        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 18,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: () => _showUserAgreementDialog(context),
    );
  }

  Widget _buildPrivacyPolicySetting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(LucideIcons.shield, color: colorScheme.primary, size: 22),
      title: Text(
        '隐私政策',
        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 18,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: () => _showPrivacyPolicyDialog(context),
    );
  }

  Widget _buildVersionSetting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(LucideIcons.tag, color: colorScheme.primary, size: 22),
      title: Text(
        '版本信息',
        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ),
      subtitle: Text(
        'v1.0.0',
        style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
      ),
      trailing: ElevatedButton(
        onPressed: () {
          NotificationHelper.showInfo(message: '已是最新版本');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('检查更新', style: TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildOtherSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildSection(
      context,
      title: '其他',
      children: [
        _buildClearCacheSetting(context),
        _buildDivider(colorScheme),
        _buildFeedbackSetting(context),
      ],
    );
  }

  Widget _buildClearCacheSetting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(LucideIcons.trash2, color: colorScheme.primary, size: 22),
      title: Text(
        '清除缓存',
        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ),
      subtitle: Text(
        '缓存大小: 12.5 MB',
        style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 18,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: () => _showClearCacheDialog(context),
    );
  }

  Widget _buildFeedbackSetting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        LucideIcons.messageSquare,
        color: colorScheme.primary,
        size: 22,
      ),
      title: Text(
        '意见反馈',
        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 18,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: () {
        NotificationHelper.showInfo(message: '意见反馈功能即将上线');
      },
    );
  }

  Widget _buildDangerSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildSection(
      context,
      title: '',
      children: [
        ListTile(
          leading: Icon(LucideIcons.logOut, color: colorScheme.error, size: 22),
          title: Text(
            '退出登录',
            style: TextStyle(fontSize: 16, color: colorScheme.error),
          ),
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Divider(
      height: 1,
      indent: 58,
      endIndent: 16,
      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeModel themeModel) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              icon: Icons.brightness_auto,
              title: '跟随系统',
              isSelected: themeModel.themeMode == ThemeMode.system,
              onTap: () {
                themeModel.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
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

  void _showAboutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('关于软件', style: TextStyle(color: colorScheme.onSurface)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        LucideIcons.heart,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '关爱老年人',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '软件简介',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '关爱老年人是一款专为老年人和其家人设计的智能健康关怀应用。通过智能化的功能，帮助老年人更好地管理健康，让家人能够实时了解老人的身体状况。',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '主要功能',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• 健康数据监测\n• 家人关怀互动\n• 智能提醒服务\n• 紧急求助功能\n• 个性化健康管理',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('关闭', style: TextStyle(color: colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showUserAgreementDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('用户协议', style: TextStyle(color: colorScheme.onSurface)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. 服务条款',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '欢迎使用关爱老年人应用。使用本应用即表示您同意本协议的所有条款。',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '2. 用户信息收集',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '为了提供更好的服务，我们可能会收集以下信息：\n• 基本个人信息（姓名、年龄等）\n• 健康数据\n• 设备信息\n• 使用日志',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '3. 信息使用',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '我们收集的信息将用于：\n• 提供个性化服务\n• 改进应用功能\n• 数据分析和研究\n• 安全保障',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '4. 信息保护',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '我们采取严格的安全措施保护您的个人信息，不会未经授权向第三方泄露。',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('关闭', style: TextStyle(color: colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('隐私政策', style: TextStyle(color: colorScheme.onSurface)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. 信息收集',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '我们会收集您主动提供的信息，包括但不限于：\n• 注册信息\n• 健康数据\n• 位置信息\n• 设备信息',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '2. 信息使用',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '我们使用收集的信息来：\n• 提供和改进服务\n• 个性化体验\n• 安全防护\n• 法律合规',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '3. 信息共享',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '除以下情况外，我们不会共享您的个人信息：\n• 获得您的明确同意\n• 法律法规要求\n• 保护用户或公众安全',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '4. 您的权利',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '您有权：\n• 访问和更新您的个人信息\n• 删除您的账户\n• 撤销授权\n• 投诉举报',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('关闭', style: TextStyle(color: colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('清除缓存', style: TextStyle(color: colorScheme.onSurface)),
        content: Text(
          '确定要清除缓存吗？这将删除应用中的临时文件。',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              NotificationHelper.showSuccess(message: '缓存已清除');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('退出登录', style: TextStyle(color: colorScheme.onSurface)),
        content: Text(
          '确定要退出登录吗？',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authStore = Provider.of<AuthStore>(context, listen: false);
              await authStore.logout();
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
