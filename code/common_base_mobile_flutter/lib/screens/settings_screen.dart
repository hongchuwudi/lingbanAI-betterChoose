import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import '../models/theme_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/notification/notification_helper.dart';
import '../utils/http_interceptor.dart';
import '../config/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _cacheSize = '计算中...';

  @override
  void initState() {
    super.initState();
    _calculateCacheSize();
  }

  Future<void> _calculateCacheSize() async {
    try {
      final dir = await getTemporaryDirectory();
      final size = await _dirSize(dir);
      if (mounted) {
        setState(() => _cacheSize = _formatBytes(size));
      }
    } catch (_) {
      if (mounted) setState(() => _cacheSize = '未知');
    }
  }

  Future<int> _dirSize(Directory dir) async {
    int total = 0;
    try {
      await for (final entity
          in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          total += await entity.length();
        }
      }
    } catch (_) {}
    return total;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _clearCache() async {
    try {
      final dir = await getTemporaryDirectory();
      if (dir.existsSync()) {
        await for (final entity
            in dir.list(recursive: false, followLinks: false)) {
          try {
            await entity.delete(recursive: true);
          } catch (_) {}
        }
      }
      if (mounted) {
        setState(() => _cacheSize = '0 B');
        NotificationHelper.showSuccess(message: '缓存已清除');
      }
    } catch (e) {
      NotificationHelper.showError(message: '清除失败：$e');
    }
  }

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
      title: Text('主题颜色',
          style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
      subtitle: Text(themeModel.themeModeDescription,
          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
      trailing: Icon(LucideIcons.chevronRight,
          size: 18, color: colorScheme.onSurfaceVariant),
      onTap: () => _showThemeDialog(context, themeModel),
    );
  }

  Widget _buildFontSizeSetting(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(LucideIcons.type, color: colorScheme.primary, size: 22),
      title: Text('字体大小',
          style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
      subtitle: Text(themeModel.fontScaleLabel,
          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
      trailing: Icon(LucideIcons.chevronRight,
          size: 18, color: colorScheme.onSurfaceVariant),
      onTap: () => _showFontSizeDialog(context, themeModel),
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
      title: Text('关于软件',
          style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
      trailing: Icon(LucideIcons.chevronRight,
          size: 18, color: colorScheme.onSurfaceVariant),
      onTap: () => _showAboutDialog(context),
    );
  }

  Widget _buildUserAgreementSetting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(LucideIcons.fileText, color: colorScheme.primary, size: 22),
      title: Text('用户协议',
          style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
      trailing: Icon(LucideIcons.chevronRight,
          size: 18, color: colorScheme.onSurfaceVariant),
      onTap: () => _showUserAgreementDialog(context),
    );
  }

  Widget _buildPrivacyPolicySetting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(LucideIcons.shield, color: colorScheme.primary, size: 22),
      title: Text('隐私政策',
          style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
      trailing: Icon(LucideIcons.chevronRight,
          size: 18, color: colorScheme.onSurfaceVariant),
      onTap: () => _showPrivacyPolicyDialog(context),
    );
  }

  Widget _buildVersionSetting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(LucideIcons.tag, color: colorScheme.primary, size: 22),
      title: Text('版本信息',
          style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
      subtitle: Text('v${AppConfig.appVersion}',
          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
      trailing: ElevatedButton(
        onPressed: () => _checkUpdate(context),
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
      title: Text('清除缓存',
          style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
      subtitle: Text('缓存大小: $_cacheSize',
          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
      trailing: Icon(LucideIcons.chevronRight,
          size: 18, color: colorScheme.onSurfaceVariant),
      onTap: () => _showClearCacheDialog(context),
    );
  }

  Widget _buildFeedbackSetting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading:
          Icon(LucideIcons.messageSquare, color: colorScheme.primary, size: 22),
      title: Text('意见反馈',
          style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
      trailing: Icon(LucideIcons.chevronRight,
          size: 18, color: colorScheme.onSurfaceVariant),
      onTap: () => _showFeedbackDialog(context),
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
          title: Text('退出登录',
              style: TextStyle(fontSize: 16, color: colorScheme.error)),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.2),
            colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
      trailing:
          isSelected ? Icon(Icons.check, color: colorScheme.primary) : null,
      onTap: onTap,
    );
  }

  void _showFontSizeDialog(BuildContext context, ThemeModel themeModel) {
    final colorScheme = Theme.of(context).colorScheme;
    double tempScale = themeModel.fontScale;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text('字体大小', style: TextStyle(color: colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '预览文字大小',
                style: TextStyle(
                    fontSize: 16 * tempScale, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('小',
                      style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  Expanded(
                    child: Slider(
                      value: tempScale,
                      min: 0.8,
                      max: 1.3,
                      divisions: 5,
                      label: _scaleName(tempScale),
                      onChanged: (v) => setDialogState(() => tempScale = v),
                    ),
                  ),
                  Text('大',
                      style: TextStyle(color: colorScheme.onSurfaceVariant)),
                ],
              ),
              Text(
                _scaleName(tempScale),
                style: TextStyle(
                    color: colorScheme.primary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('取消',
                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () {
                themeModel.setFontScale(tempScale);
                Navigator.pop(ctx);
                NotificationHelper.showSuccess(message: '字体大小已更新');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  String _scaleName(double scale) {
    if (scale <= 0.85) return '小';
    if (scale <= 1.0) return '标准';
    if (scale <= 1.15) return '大';
    return '超大';
  }

  Future<void> _checkUpdate(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    try {
      final response = await HttpInterceptorManager()
          .interceptor
          .get<Map<String, dynamic>>(path: '/app/version');
      if (!mounted) return;
      if (response.isSuccess && response.data != null) {
        final latest =
            response.data!['version']?.toString() ?? AppConfig.appVersion;
        if (latest != AppConfig.appVersion) {
          _showUpdateDialog(context, latest, colorScheme);
          return;
        }
      }
    } catch (_) {}
    NotificationHelper.showSuccess(message: '已是最新版本 v${AppConfig.appVersion}');
  }

  void _showUpdateDialog(
      BuildContext context, String newVersion, ColorScheme cs) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('发现新版本', style: TextStyle(color: cs.onSurface)),
        content: Text('最新版本 v$newVersion，建议更新。',
            style: TextStyle(color: cs.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('稍后', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
            ),
            child: const Text('立即更新'),
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
        content: Text('确定要清除缓存吗？这将删除应用中的临时文件（$_cacheSize）。',
            style: TextStyle(color: colorScheme.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消',
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearCache();
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

  void _showFeedbackDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text('意见反馈', style: TextStyle(color: colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('请告诉我们您的建议或遇到的问题：',
                  style: TextStyle(
                      fontSize: 14, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: '请输入您的反馈内容...',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('取消',
                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: isSending
                  ? null
                  : () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) {
                        NotificationHelper.showError(message: '请输入反馈内容');
                        return;
                      }
                      setDialogState(() => isSending = true);
                      try {
                        await HttpInterceptorManager().interceptor.post<void>(
                          path: '/user/feedback',
                          data: {'content': text},
                        );
                      } catch (_) {}
                      if (ctx.mounted) Navigator.pop(ctx);
                      NotificationHelper.showSuccess(message: '感谢您的反馈！');
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('提交'),
            ),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
  }

  void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('退出登录', style: TextStyle(color: colorScheme.onSurface)),
        content:
            Text('确定要退出登录吗？', style: TextStyle(color: colorScheme.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消',
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authStore = Provider.of<AuthStore>(context, listen: false);
              await authStore.logout();
              if (mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
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
                      child: Icon(LucideIcons.heart,
                          size: 40, color: colorScheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text('灵伴AI',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface)),
                    const SizedBox(height: 4),
                    Text('v${AppConfig.appVersion}',
                        style: TextStyle(
                            fontSize: 14, color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('软件简介',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text(
                '灵伴AI是一款专为老年人和其家人设计的智能健康关怀应用。通过AI驱动的功能，帮助老年人更好地管理健康，让家人能够实时了解老人的身体状况。',
                style: TextStyle(
                    fontSize: 14, color: colorScheme.onSurface, height: 1.5),
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
          child: Text(
            '1. 服务条款\n使用本应用即表示您同意本协议的所有条款。\n\n'
            '2. 用户信息收集\n我们可能会收集：基本个人信息、健康数据、设备信息、使用日志。\n\n'
            '3. 信息使用\n收集的信息将用于提供个性化服务、改进功能、数据分析和安全保障。\n\n'
            '4. 信息保护\n我们采取严格安全措施保护您的个人信息，不会未经授权向第三方泄露。',
            style: TextStyle(
                fontSize: 14, color: colorScheme.onSurface, height: 1.6),
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
          child: Text(
            '1. 信息收集\n我们会收集您主动提供的注册信息、健康数据、位置信息和设备信息。\n\n'
            '2. 信息使用\n用于提供和改进服务、个性化体验、安全防护和法律合规。\n\n'
            '3. 信息共享\n除法律要求或保护公众安全外，我们不会共享您的个人信息。\n\n'
            '4. 您的权利\n您有权访问和更新个人信息、删除账户、撤销授权和投诉举报。',
            style: TextStyle(
                fontSize: 14, color: colorScheme.onSurface, height: 1.6),
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
}
