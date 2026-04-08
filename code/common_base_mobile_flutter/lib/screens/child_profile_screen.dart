import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/websocket_service.dart';
import '../widgets/notification/notification_helper.dart';

/// 子女信息填写页面
///
/// 功能说明：
/// - 用户选择子女身份后进入此页面
/// - 填写子女基本信息、守护设置等
/// - 提交后创建子女档案
class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({super.key});

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // 表单控制器
  final _nicknameController = TextEditingController();

  // 守护设置
  bool _receiveSos = true;
  bool _receiveAlert = true;
  bool _receiveHealthReport = true;
  bool _receiveDailyCheckIn = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  /// 提交表单
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final guardianSettings = {
        'receive_sos': _receiveSos,
        'receive_alert': _receiveAlert,
        'receive_health_report': _receiveHealthReport,
        'receive_daily_check_in': _receiveDailyCheckIn,
      };

      final profileData = {
        'nickname': _nicknameController.text.trim(),
        'guardianSettings': jsonEncode(guardianSettings),
        'checkinSettings': jsonEncode({}),
      };

      final result = await AuthService.createChildProfile(profileData);

      if (mounted) {
        if (result['success']) {
          NotificationHelper.showSuccess(message: '档案创建成功');
          final authStore = Provider.of<AuthStore>(context, listen: false);
          await authStore.init();
          WebSocketService().connect();
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          NotificationHelper.showError(
            message: result['message'] ?? '创建失败，请重试',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showError(message: '网络错误，请重试');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(LucideIcons.arrowLeft, color: colorScheme.onSurface),
        ),
        title: Text(
          '完善子女信息',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                '请完善您的基本信息',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '这些信息将帮助我们更好地为您提供服务',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withAlpha(153),
                ),
              ),
              const SizedBox(height: 32),

              // 昵称
              _buildTextField(
                controller: _nicknameController,
                label: '昵称',
                hint: '请输入您的昵称',
                icon: LucideIcons.user,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入昵称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // 守护设置
              Text(
                '守护设置',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '选择您希望接收的通知类型',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withAlpha(153),
                ),
              ),
              const SizedBox(height: 16),

              // SOS紧急求助
              _buildSettingTile(
                title: 'SOS 紧急求助',
                subtitle: '当父母发出紧急求助时立即通知我',
                icon: LucideIcons.alertCircle,
                iconColor: Colors.red,
                value: _receiveSos,
                onChanged: (value) => setState(() => _receiveSos = value),
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),

              // 健康异常提醒
              _buildSettingTile(
                title: '健康异常提醒',
                subtitle: '当父母健康数据异常时通知我',
                icon: LucideIcons.heartPulse,
                iconColor: Colors.orange,
                value: _receiveAlert,
                onChanged: (value) => setState(() => _receiveAlert = value),
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),

              // 健康周报
              _buildSettingTile(
                title: '健康周报',
                subtitle: '每周接收父母的健康报告',
                icon: LucideIcons.fileText,
                iconColor: Colors.blue,
                value: _receiveHealthReport,
                onChanged: (value) =>
                    setState(() => _receiveHealthReport = value),
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),

              // 每日打卡提醒
              _buildSettingTile(
                title: '每日打卡提醒',
                subtitle: '提醒父母完成每日健康打卡',
                icon: LucideIcons.checkCircle,
                iconColor: Colors.green,
                value: _receiveDailyCheckIn,
                onChanged: (value) =>
                    setState(() => _receiveDailyCheckIn = value),
                colorScheme: colorScheme,
              ),

              const SizedBox(height: 40),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Text(
                          '完成',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withAlpha(77)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
