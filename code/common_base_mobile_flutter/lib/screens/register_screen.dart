import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
import '../widgets/notification/notification_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final bool _isLoading = false;
  bool _codeCountdown = false;
  int _countdownSeconds = 60;

  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      NotificationHelper.showWarning(message: '请输入手机号');
      return;
    }
    if (_codeCountdown) return;

    setState(() {
      _codeCountdown = true;
    });
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      //  添加 mounted 检查
      if (!mounted) return;

      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
        _startCountdown();
      } else {
        setState(() {
          _codeCountdown = false;
          _countdownSeconds = 60;
        });
      }
    });
  }

  Future<void> _register() async {
    // 注册功能实现
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final onSurface = colorScheme.onSurface;
    final surface = colorScheme.surface;
    final surfaceContainerHighest = colorScheme.surfaceContainerHighest;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '注册新账号',
          style: TextStyle(
            color: onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // 手机号输入框
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: onSurface),
                decoration: InputDecoration(
                  hintText: '请输入手机号',
                  hintStyle: TextStyle(color: onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.phone,
                    color: onSurfaceVariant,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 验证码输入框
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: onSurface),
                      decoration: InputDecoration(
                        hintText: '请输入验证码',
                        hintStyle: TextStyle(color: onSurfaceVariant),
                        prefixIcon: Icon(
                          Icons.sms,
                          color: onSurfaceVariant,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    child: _codeCountdown
                        ? Center(
                            child: Text(
                              '${_countdownSeconds}s',
                              style: TextStyle(
                                color: onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _sendCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              '获取验证码',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 密码输入框
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(color: onSurface),
                decoration: InputDecoration(
                  hintText: '请设置密码',
                  hintStyle: TextStyle(color: onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: onSurfaceVariant,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 确认密码输入框
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: TextStyle(color: onSurface),
                decoration: InputDecoration(
                  hintText: '请确认密码',
                  hintStyle: TextStyle(color: onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: onSurfaceVariant,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 注册按钮
            SizedBox(
              width: double.infinity,
              height: 52,
              child: _isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '注册',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 40),

            // 邮箱注册选项
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '或使用',
                  style: TextStyle(color: onSurfaceVariant, fontSize: 14),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/email-register'),
                  child: Text(
                    '邮箱注册',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 登录链接
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '已有账号？',
                  style: TextStyle(color: onSurfaceVariant, fontSize: 14),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '立即登录',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
