import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/websocket_service.dart';

/// 身份类型枚举
enum RoleType { none, elderly, child }

/// 身份选择页面
///
/// 功能说明：
/// - 用户在登录成功后跳转到此页面
/// - 提供老人/子女两种身份选择
/// - 根据后端返回的用户角色信息自动跳转或显示选择界面
///
/// 设计参考：Boss 直聘选择牛人/Boss 的样式
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  // 当前选中的身份
  RoleType _selectedRole = RoleType.none;

  // 页面加载状态
  bool _isLoading = true;

  // 动画控制器
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _checkUserRole();
  }

  /// 初始化动画
  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 检查用户角色信息
  ///
  /// 逻辑：
  /// - 如果用户已有业务角色（BUSINESS）并且角色代码是 oldMan 或 young，直接进入我的页面
  /// - 否则显示身份选择界面
  Future<void> _checkUserRole() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 从 Provider 中获取已登录的用户信息
      if (mounted) {
        final authStore = Provider.of<AuthStore>(context, listen: false);
        final user = authStore.user;

        if (user != null) {
          // 判断用户角色分类和角色代码
          if (user.roleCategory == 'BUSINESS' &&
              (user.roleCode == 'oldMan' || user.roleCode == 'young')) {
            // 已有业务角色（老人或子女），直接进入我的页面
            Navigator.pushReplacementNamed(context, '/main');
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
    }

    // 没有业务角色信息，显示选择界面
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 跳转到对应首页
  void _navigateToHome(RoleType roleType) {
    // TODO: 根据角色跳转到不同的首页
    // 暂时都跳转到 home 页面
    Navigator.pushReplacementNamed(context, '/main');
  }

  /// 选择身份
  void _selectRole(RoleType role) {
    setState(() {
      _selectedRole = role;
    });
  }

  /// 确认选择
  void _confirmSelection() {
    if (_selectedRole == RoleType.none) return;

    // 跳转到对应的信息填写页面
    switch (_selectedRole) {
      case RoleType.elderly:
        Navigator.pushNamed(context, '/elderly-profile');
        break;
      case RoleType.child:
        Navigator.pushNamed(context, '/child-profile');
        break;
      default:
        break;
    }
  }

  /// 返回登录页
  void _backToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingView(colorScheme)
            : _buildSelectionView(theme, colorScheme),
      ),
    );
  }

  /// 构建加载视图
  Widget _buildLoadingView(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            '正在检查用户信息...',
            style: TextStyle(
              color: colorScheme.onSurface.withAlpha(153),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建选择视图
  Widget _buildSelectionView(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // 返回按钮
          IconButton(
            onPressed: _backToLogin,
            icon: const Icon(LucideIcons.arrowLeft),
            color: colorScheme.onSurface,
          ),
          const SizedBox(height: 32),
          // 标题
          Text(
            '选择您的身份',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请选择您的身份以继续',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 60),
          // 身份选择卡片
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRoleCard(
                role: RoleType.elderly,
                imagePath: 'assets/choose_oldMans.jpeg',
                title: '老人',
                description: '健康监测，智能陪伴',
                theme: theme,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 32),
              _buildRoleCard(
                role: RoleType.child,
                imagePath: 'assets/choose_youths.jpeg',
                title: '子女',
                description: '守护父母，远程关怀',
                theme: theme,
                colorScheme: colorScheme,
              ),
            ],
          ),
          const Spacer(),
          // 确认按钮
          _buildConfirmButton(colorScheme),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 构建身份选择卡片
  Widget _buildRoleCard({
    required RoleType role,
    required String imagePath,
    required String title,
    required String description,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _selectedRole == role;
    final primaryColor = colorScheme.primary;

    return GestureDetector(
      onTap: () => _selectRole(role),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? _scaleAnimation.value : 1.0,
            child: Container(
              width: 140,
              height: 180,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? primaryColor.withAlpha(77)
                        : Colors.black.withAlpha(20),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 4),
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 圆形图片
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? primaryColor.withAlpha(77)
                            : Colors.grey.withAlpha(51),
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        imagePath,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              role == RoleType.elderly
                                  ? LucideIcons.user
                                  : LucideIcons.users,
                              size: 40,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 身份名称
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? primaryColor : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 描述文字
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withAlpha(128),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建确认按钮
  Widget _buildConfirmButton(ColorScheme colorScheme) {
    final isEnabled = _selectedRole != RoleType.none;
    final primaryColor = colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isEnabled ? _confirmSelection : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: primaryColor.withAlpha(77),
          disabledForegroundColor: colorScheme.onPrimary.withAlpha(153),
          elevation: isEnabled ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '确认选择',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isEnabled
                ? colorScheme.onPrimary
                : colorScheme.onPrimary.withAlpha(153),
          ),
        ),
      ),
    );
  }
}
