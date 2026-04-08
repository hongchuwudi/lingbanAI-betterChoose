import 'package:flutter/material.dart';
import 'notification_helper.dart';

class NotificationWidget extends StatefulWidget {
  final NotificationConfig config;
  final VoidCallback onDismiss;

  const NotificationWidget({
    super.key,
    required this.config,
    required this.onDismiss,
  });

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _animationController.reverse();
    if (mounted) {
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final colorScheme = Theme.of(context).colorScheme;

    // 根据类型获取背景色（使用实体背景，不用透明）
    final backgroundColor =
        config.backgroundColor ?? config.defaultBackgroundColor;
    final textColor = config.textColor ?? config.defaultTextColor;
    final iconColor = config.defaultIconColor;
    final icon = config.icon ?? config.defaultIcon;

    // 根据位置计算顶部偏移
    double getTopOffset() {
      final mediaQuery = MediaQuery.of(context);
      switch (config.position) {
        case NotificationPosition.top:
          return mediaQuery.padding.top + 20;
        case NotificationPosition.center:
          return mediaQuery.size.height / 2 - 60;
        case NotificationPosition.bottom:
          return mediaQuery.size.height - mediaQuery.padding.bottom - 100;
      }
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final slideOffset = _slideAnimation.value * 80;

        return Positioned(
          top: getTopOffset() + slideOffset,
          left: 0,
          right: 0,
          child: Center(
            child: Opacity(opacity: _fadeAnimation.value, child: child),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            config.onTap?.call();
            _dismiss();
          },
          child: Container(
            width: 340, // ✅ 固定宽度，让内容居中
            constraints: const BoxConstraints(maxWidth: 340, minWidth: 280),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              // ✅ 实体阴影，更明显
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
              // ✅ 可选：添加边框，增加实体感
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图标容器
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                // 内容
                Expanded(
                  child: config.child != null
                      ? config.child!
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              config.defaultTitle,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              config.message!,
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                ),
                // 关闭按钮
                if (!config.autoDismiss)
                  GestureDetector(
                    onTap: _dismiss,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.close,
                        color: textColor.withValues(alpha: 0.6),
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
