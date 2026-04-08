import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isCodeLogin = true;
  bool _isLoading = false;
  bool _codeCountdown = false;
  int _countdownSeconds = 60;

  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // 显示提示消息的方法
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showMessage('请输入手机号');
      return;
    }
    if (_codeCountdown) return;

    setState(() {
      _codeCountdown = true;
    });
    _startCountdown();

    final result = await AuthService.sendPhoneCode(phone);

    if (mounted) {
      _showMessage(result['message']);
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
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

  Future<void> _login() async {
    if (_isCodeLogin) {
      final phone = _phoneController.text.trim();
      final code = _codeController.text.trim();
      if (phone.isEmpty || code.isEmpty) {
        _showMessage('请输入手机号和验证码');
        return;
      }
      setState(() => _isLoading = true);
      final result = await AuthService.loginByPhone(phone, code);

      if (!mounted) return;

      setState(() => _isLoading = false);
      if (result['success'] == true) {
        _showMessage('登录成功');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showMessage(result['message'] ?? '登录失败');
      }
    } else {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;
      if (username.isEmpty || password.isEmpty) {
        _showMessage('请输入账号和密码');
        return;
      }
      setState(() => _isLoading = true);
      final result = await AuthService.loginByPassword(username, password);

      if (!mounted) return;

      setState(() => _isLoading = false);
      if (result['success'] == true) {
        _showMessage('登录成功');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showMessage(result['message'] ?? '登录失败');
      }
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: Text(
              '注册',
              style: TextStyle(
                color: primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              '欢迎回来',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '登录你的账号，守护家人健康',
              style: TextStyle(fontSize: 14, color: onSurfaceVariant),
            ),
            const SizedBox(height: 40),

            // 登录方式切换
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildTabButton(
                    '手机号登录',
                    true,
                    primaryColor,
                    onSurface,
                    surface,
                  ),
                  _buildTabButton(
                    '账号密码登录',
                    false,
                    primaryColor,
                    onSurface,
                    surface,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 表单区域
            if (_isCodeLogin)
              _buildCodeLoginForm(primaryColor, surfaceContainerHighest)
            else
              _buildPasswordLoginForm(surfaceContainerHighest),

            const SizedBox(height: 30),

            // 登录按钮
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
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '登录',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 40),

            // 其他登录方式
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: onSurfaceVariant.withValues(alpha: 0.2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '其他登录方式',
                    style: TextStyle(fontSize: 12, color: onSurfaceVariant),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: onSurfaceVariant.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 社交登录图标
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialIcon(Icons.wechat, '微信'),
                _buildSocialIcon(Icons.payment, '支付宝'),
                _buildSocialIcon(Icons.apple, 'Apple ID'),
              ],
            ),
            const SizedBox(height: 40),

            // 注册链接
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '没有账号？',
                  style: TextStyle(color: onSurfaceVariant, fontSize: 14),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text(
                    '立即注册',
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

  Widget _buildTabButton(
    String title,
    bool isCodeLogin,
    Color primaryColor,
    Color onSurface,
    Color surface,
  ) {
    final isActive = isCodeLogin == _isCodeLogin;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isCodeLogin = isCodeLogin),
        child: Container(
          height: 40,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isActive ? surface : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
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
                    ? primaryColor
                    : onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeLoginForm(
    Color primaryColor,
    Color surfaceContainerHighest,
  ) {
    return Column(
      children: [
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: '请输入手机号',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.phone, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
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
                  decoration: const InputDecoration(
                    hintText: '请输入验证码',
                    prefixIcon: Icon(Icons.sms, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
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
                          style: TextStyle(color: Colors.grey.shade600),
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
      ],
    );
  }

  Widget _buildPasswordLoginForm(Color surfaceContainerHighest) {
    return Column(
      children: [
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              hintText: '请输入手机号/账号/邮箱/ID',
              prefixIcon: Icon(Icons.person, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: '请输入密码',
              prefixIcon: const Icon(Icons.lock, color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
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
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        // 社交登录功能
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: colorScheme.onSurfaceVariant, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
