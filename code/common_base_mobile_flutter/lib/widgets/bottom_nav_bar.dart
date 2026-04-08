import 'package:flutter/material.dart';
import '../models/nav_item.dart';

/// 底部导航栏组件
/// 遵循开闭原则，新增导航项只需修改配置列表，无需修改组件内部代码
///
/// 功能特性：
/// - 支持普通导航项和特殊样式导航项（如中间凸起按钮）
/// - 支持自定义图标、文字、颜色
/// - 支持页面切换动画
/// - 自动适配亮色/暗色主题
class BottomNavBar extends StatefulWidget {
  /// 导航项列表
  final List<NavItem> items;

  /// 背景颜色（可选，默认跟随主题）
  final Color? backgroundColor;

  /// 选中项颜色（可选，默认使用主题主色）
  final Color? selectedColor;

  /// 未选中项颜色（可选，默认使用主题灰色）
  final Color? unselectedColor;

  /// 普通图标大小（可选，默认24px）
  final double iconSize;

  /// 文字大小（可选，默认12px）
  final double fontSize;

  /// 特殊样式图标大小（可选，默认28px）
  final double specialIconSize;

  /// 特殊样式背景颜色（可选，默认深蓝色）
  final Color? specialBackgroundColor;

  /// 当前选中的索引
  final int currentIndex;

  /// 导航项点击回调
  final Function(int)? onTap;

  /// 构造函数
  const BottomNavBar({
    super.key,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.iconSize = 24,
    this.fontSize = 12,
    this.specialIconSize = 28,
    this.specialBackgroundColor,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with TickerProviderStateMixin {
  /// 当前选中的索引
  late int _currentIndex;

  /// 页面控制器，用于页面切换动画
  late PageController _pageController;

  /// 页面列表
  late List<Widget> _screens;

  /// 每个导航项的动画控制器列表
  late List<AnimationController> _animationControllers;

  /// 每个导航项的缩放动画列表
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    // 初始化当前选中索引为传入的 currentIndex
    _currentIndex = widget.currentIndex;
    // 初始化页面控制器
    _pageController = PageController(initialPage: widget.currentIndex);
    // 从导航项中提取页面组件
    _screens = widget.items.map((item) => item.screen).toList();

    // 初始化动画控制器和动画
    _animationControllers = [];
    _scaleAnimations = [];

    for (int i = 0; i < widget.items.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: 1.0,
        end: 1.3,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));

      _animationControllers.add(controller);
      _scaleAnimations.add(animation);
    }
  }

  @override
  void dispose() {
    //释放页面控制器资源
    _pageController.dispose();
    //释放所有动画控制器资源
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部 currentIndex 改变时，同步更新内部状态
    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        _currentIndex = widget.currentIndex;
      });
      _pageController.animateToPage(
        widget.currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 处理导航项点击事件
  ///
  /// 处理导航项点击事件
  void _onTap(int index) async {
    // 触发点击动画
    _animationControllers[index].forward().then((_) {
      _animationControllers[index].reverse();
    });

    // 如果点击的是当前选中的项，则不处理页面切换
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    // 使用动画切换页面
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // 调用外部回调（如果提供了）
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 获取颜色配置，优先使用自定义颜色，否则使用主题颜色
    final backgroundColor = widget.backgroundColor ?? colorScheme.surface;
    final selectedColor = widget.selectedColor ?? colorScheme.primary;
    final unselectedColor =
        widget.unselectedColor ?? colorScheme.onSurfaceVariant;
    final specialBackgroundColor =
        widget.specialBackgroundColor ?? const Color(0xFF0B5E9E);

    return Scaffold(
      // 使用 PageView 实现页面切换动画，保持页面状态
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          // 当用户滑动页面时，同步更新底部导航栏选中状态
          setState(() => _currentIndex = index);
        },
        children: _screens,
      ),

      // 自定义底部导航栏
      bottomNavigationBar: Container(
        height: 68, // 固定高度，避免溢出
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            // 添加轻微阴影，增加层次感
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = _currentIndex == index;
            final isSpecial = item.isSpecial;

            // 计算图标大小：特殊样式使用自定义大小，否则使用默认大小
            final iconSize = isSpecial
                ? (item.specialIconSize ?? widget.specialIconSize)
                : widget.iconSize;
            // 计算图标容器大小：特殊样式更大一圈
            final iconContainerSize = isSpecial ? 44.0 : 36.0;

            return Expanded(
              child: GestureDetector(
                onTap: () => _onTap(index),
                child: AnimatedBuilder(
                  animation: _scaleAnimations[index],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimations[index].value,
                      child: Container(
                        height: 68,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 图标容器
                            Container(
                              width: iconContainerSize,
                              height: iconContainerSize,
                              decoration: BoxDecoration(
                                // 特殊样式：有背景色；普通样式：透明
                                color: isSpecial
                                    ? (item.specialBackgroundColor ??
                                          specialBackgroundColor)
                                    : Colors.transparent,
                                // 特殊样式：圆形；普通样式：无圆角
                                borderRadius: BorderRadius.circular(
                                  isSpecial ? iconContainerSize / 2 : 0,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  // 选中时使用 activeIcon，否则使用普通 icon
                                  isSelected ? item.activeIconData : item.icon,
                                  size: iconSize,
                                  color: isSpecial
                                      ? Colors
                                            .white // 特殊样式图标固定白色
                                      : (isSelected
                                            ? selectedColor
                                            : unselectedColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // 标签文字
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: widget.fontSize,
                                color: isSelected
                                    ? selectedColor
                                    : unselectedColor,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
