import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/websocket_service.dart';
import '../widgets/notification/notification_helper.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  int _loginType = 0; // 0: 账号密码登录, 1: 邮箱登录
  bool _isLoading = false;
  bool _codeCountdown = false;
  int _countdownSeconds = 60;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _mainController;
  late AnimationController _floatController;
  late Animation<double> _mainFade;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _mainFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeOut));

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendEmailCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      NotificationHelper.showWarning(message: '请输入邮箱地址');
      return;
    }
    if (_codeCountdown) return;

    setState(() => _codeCountdown = true);
    _startCountdown();

    final result = await AuthService.sendEmailCode(email, 'login');
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
      if (!mounted) return;
      if (_countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
        _startCountdown();
      } else {
        setState(() {
          _codeCountdown = false;
          _countdownSeconds = 60;
        });
      }
    });
  }

  Future<void> _login() async {
    if (_loginType == 1) {
      final email = _emailController.text.trim();
      final code = _codeController.text.trim();
      if (email.isEmpty || code.isEmpty) {
        NotificationHelper.showWarning(message: '请输入邮箱地址和验证码');
        return;
      }
      setState(() => _isLoading = true);
      final result = await AuthService.loginByEmail(email, code);
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        NotificationHelper.showSuccess(message: '登录成功');
        _handleLoginSuccess(result['user']);
      } else {
        NotificationHelper.showError(message: result['message'] ?? '登录失败');
      }
    } else {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;
      if (username.isEmpty || password.isEmpty) {
        NotificationHelper.showWarning(message: '请输入账号和密码');
        return;
      }
      setState(() => _isLoading = true);
      final result = await AuthService.loginByPassword(username, password);
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        NotificationHelper.showSuccess(message: '登录成功');
        _handleLoginSuccess(result['user']);
      } else {
        NotificationHelper.showError(message: result['message'] ?? '登录失败');
      }
    }
  }

  void _handleLoginSuccess(dynamic user) async {
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/role-selection');
      return;
    }

    final roleCategory = user.roleCategory;
    final roleCode = user.roleCode;

    if (roleCategory == 'BUSINESS' &&
        (roleCode == 'oldMan' || roleCode == 'young')) {
      final authStore = Provider.of<AuthStore>(context, listen: false);
      await authStore.init();

      WebSocketService().connect().catchError((error) {
        debugPrint('WebSocket 连接失败，但不影响登录: $error');
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/role-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0F4FF),
      body: Stack(
        children: [
          _buildBackground(isDark, colorScheme),
          SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FadeTransition(
                opacity: _mainFade,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    _buildLogoSection(isDark, colorScheme),
                    const SizedBox(height: 36),
                    _buildLoginTypeSwitch(colorScheme, isDark),
                    const SizedBox(height: 24),
                    _buildFormCard(isDark, colorScheme),
                    const SizedBox(height: 24),
                    _buildLoginButton(colorScheme),
                    const SizedBox(height: 16),
                    _buildForgotPassword(colorScheme),
                    const SizedBox(height: 36),
                    _buildRegisterLink(colorScheme),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark, ColorScheme colorScheme) {
    return Positioned.fill(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF1A1A3E), const Color(0xFF0F0F1A)]
                    : [const Color(0xFFE8EEFF), const Color(0xFFF0F4FF)],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              final offset = _floatController.value * 20 - 10;
              return Stack(
                children: [
                  Positioned(
                    top: 80 + offset,
                    right: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(
                          alpha: isDark ? 0.08 : 0.06,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 200 - offset * 0.5,
                    left: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(
                          alpha: isDark ? 0.05 : 0.04,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 150 + offset * 0.7,
                    right: 40,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.tertiary.withValues(
                          alpha: isDark ? 0.06 : 0.05,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80 - offset * 0.3,
                    left: 60,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.secondary.withValues(
                          alpha: isDark ? 0.05 : 0.04,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection(bool isDark, ColorScheme colorScheme) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, _) {
            final floatOffset = _floatController.value * 6 - 3;
            return Transform.translate(
              offset: Offset(0, floatOffset),
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.15),
                      colorScheme.primaryContainer.withValues(alpha: 0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/lbai-logo-nosy.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [colorScheme.primary, colorScheme.tertiary],
          ).createShader(bounds),
          child: const Text(
            '灵伴',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '守护家人健康，温暖每一刻',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white54 : Colors.black45,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginTypeSwitch(ColorScheme colorScheme, bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTypeTab('账号密码', 0, colorScheme, isDark),
          _buildTypeTab('邮箱登录', 1, colorScheme, isDark),
        ],
      ),
    );
  }

  Widget _buildTypeTab(
    String title,
    int type,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final isActive = type == _loginType;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _loginType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 40,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? const Color(0xFF1E1E32) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.08,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E32).withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _loginType == 1
            ? _buildEmailForm(isDark, colorScheme)
            : _buildPasswordForm(isDark, colorScheme),
      ),
    );
  }

  Widget _buildPasswordForm(bool isDark, ColorScheme colorScheme) {
    return Column(
      key: const ValueKey('password'),
      children: [
        _buildInputField(
          controller: _usernameController,
          hintText: '请输入手机号/账号/邮箱/ID号',
          prefixIcon: Icons.person_outline_rounded,
          isDark: isDark,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _passwordController,
          hintText: '请输入密码',
          prefixIcon: Icons.lock_outline_rounded,
          isDark: isDark,
          colorScheme: colorScheme,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm(bool isDark, ColorScheme colorScheme) {
    return Column(
      key: const ValueKey('email'),
      children: [
        _buildInputField(
          controller: _emailController,
          hintText: '请输入邮箱地址',
          prefixIcon: Icons.email_outlined,
          isDark: isDark,
          colorScheme: colorScheme,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _codeController,
                hintText: '请输入验证码',
                prefixIcon: Icons.sms_outlined,
                isDark: isDark,
                colorScheme: colorScheme,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: _codeCountdown
                    ? null
                    : LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                color: _codeCountdown
                    ? (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04))
                    : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _codeCountdown ? null : _sendEmailCode,
                  borderRadius: BorderRadius.circular(14),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        _codeCountdown ? '${_countdownSeconds}s' : '获取验证码',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _codeCountdown
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required bool isDark,
    required ColorScheme colorScheme,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: colorScheme.primary.withValues(alpha: 0.7),
            size: 22,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.tertiary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isLoading
          ? Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.onPrimary,
                ),
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _login,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    '登 录',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                      letterSpacing: 6,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildForgotPassword(ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, '/forget-password'),
        child: Text(
          '忘记密码？',
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '没有账号？',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/email-register'),
          child: Text(
            '立即注册',
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== 以下为注释掉的登录方式 ====================

  // // 手机号登录相关（已注释）
  // // int _loginType = 0; // 0: 手机号登录, 1: 账号密码登录, 2: 邮箱登录
  // // final _phoneController = TextEditingController();
  // //
  // // Future<void> _sendCode() async {
  // //   final phone = _phoneController.text.trim();
  // //   if (phone.isEmpty) {
  // //     NotificationHelper.showWarning(message: '请输入手机号');
  // //     return;
  // //   }
  // //   if (_codeCountdown) return;
  // //   setState(() { _codeCountdown = true; });
  // //   _startCountdown();
  // //   final result = await AuthService.sendPhoneCode(phone);
  // //   if (mounted) {
  // //     NotificationHelper.showError(message: result['message']);
  // //   }
  // // }
  // //
  // // Widget _buildCodeLoginForm(Color primaryColor, Color surfaceContainerHighest) { ... }

  // // 社交登录（已注释）
  // // Widget _buildSocialIcon(IconData icon, String label) {
  // //   final colorScheme = Theme.of(context).colorScheme;
  // //   return GestureDetector(
  // //     onTap: () { /* 社交登录功能 */ },
  // //     child: Column(
  // //       children: [
  // //         Container(
  // //           width: 50, height: 50,
  // //           decoration: BoxDecoration(
  // //             color: colorScheme.surfaceContainerHighest,
  // //             borderRadius: BorderRadius.circular(25),
  // //           ),
  // //           child: Icon(icon, color: colorScheme.onSurfaceVariant, size: 24),
  // //         ),
  // //         const SizedBox(height: 8),
  // //         Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
  // //       ],
  // //     ),
  // //   );
  // // }
}
