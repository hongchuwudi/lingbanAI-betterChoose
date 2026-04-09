import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/notification/notification_helper.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final bool _isLoading = false;
  bool _codeCountdown = false;
  int _countdownSeconds = 60;

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      NotificationHelper.showWarning(message: '请输入邮箱地址');
      return;
    }
    if (_codeCountdown) return;

    setState(() {
      _codeCountdown = true;
    });
    _startCountdown();

    final result = await AuthService.sendEmailCode(email, 'reset_pwd');

    //  添加 mounted 检查
    if (mounted) {
      if (result['success'] == true) {
        NotificationHelper.showSuccess(message: result['message']);
      } else {
        NotificationHelper.showError(message: result['message']);
      }
    }
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

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty) {
      NotificationHelper.showWarning(message: '请输入邮箱地址');
      return;
    }
    if (code.isEmpty) {
      NotificationHelper.showWarning(message: '请输入验证码');
      return;
    }
    if (password.isEmpty) {
      NotificationHelper.showWarning(message: '请设置新密码');
      return;
    }
    if (password != confirmPassword) {
      NotificationHelper.showWarning(message: '两次输入的密码不一致');
      return;
    }

    final result = await AuthService.forgetPassword(email, password, code);
    if (result['success'] == true) {
      NotificationHelper.showSuccess(message: '密码重置成功');
      if (mounted) Navigator.pop(context);
    } else {
      NotificationHelper.showError(message: result['message'] ?? '密码重置失败');
    }
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
          '找回密码',
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

            // 邮箱输入框
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: onSurface),
                decoration: InputDecoration(
                  hintText: '请输入邮箱地址',
                  hintStyle: TextStyle(color: onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.email,
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

            // 新密码输入框
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
                  hintText: '请设置新密码',
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
                  hintText: '请确认新密码',
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
            const SizedBox(height: 30),

            // 重置密码按钮
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
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '重置密码',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 40),

            // 登录链接
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '想起密码了？',
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
