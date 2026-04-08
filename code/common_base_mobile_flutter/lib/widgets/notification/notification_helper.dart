import 'dart:async';
import 'package:flutter/material.dart';
import 'notification_widget.dart';

/// 通知类型枚举
enum NotificationType { success, error, warning, info, custom }

/// 通知显示位置枚举
enum NotificationPosition { top, center, bottom }

/// 通知配置类
class NotificationConfig {
  final String? message;
  final Widget? child;
  final NotificationType type;
  final NotificationPosition position;
  final Duration duration;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final IconData? icon;
  final bool autoDismiss;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationConfig({
    this.message,
    this.child,
    this.type = NotificationType.info,
    this.position = NotificationPosition.top,
    this.duration = const Duration(seconds: 4),
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 20.0,
    this.icon,
    this.autoDismiss = true,
    this.onTap,
    this.onDismiss,
  }) : assert(message != null || child != null, '必须提供message或child');

  IconData get defaultIcon {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
      case NotificationType.custom:
        return Icons.notifications;
    }
  }

  // ✅ 改用固定颜色，不跟随主题
  Color get defaultBackgroundColor {
    switch (type) {
      case NotificationType.success:
        return const Color(0xFFE8F5E9); // 浅绿色
      case NotificationType.error:
        return const Color(0xFFFFEBEE); // 浅红色
      case NotificationType.warning:
        return const Color(0xFFFFF3E0); // 浅橙色
      case NotificationType.info:
        return const Color(0xFFE3F2FD); // 浅蓝色
      case NotificationType.custom:
        return const Color(0xFFF5F5F5); // 浅灰色
    }
  }

  // ✅ 改用固定颜色
  Color get defaultTextColor {
    switch (type) {
      case NotificationType.success:
        return const Color(0xFF2E7D32); // 深绿色
      case NotificationType.error:
        return const Color(0xFFC62828); // 深红色
      case NotificationType.warning:
        return const Color(0xFFED6C02); // 深橙色
      case NotificationType.info:
        return const Color(0xFF0B5E9E); // 深蓝色
      case NotificationType.custom:
        return const Color(0xFF757575); // 深灰色
    }
  }

  // ✅ 改用固定颜色
  Color get defaultIconColor {
    switch (type) {
      case NotificationType.success:
        return const Color(0xFF4CAF50); // 绿色
      case NotificationType.error:
        return const Color(0xFFF44336); // 红色
      case NotificationType.warning:
        return const Color(0xFFFF9800); // 橙色
      case NotificationType.info:
        return const Color(0xFF2196F3); // 蓝色
      case NotificationType.custom:
        return const Color(0xFF9E9E9E); // 灰色
    }
  }

  String get defaultTitle {
    switch (type) {
      case NotificationType.success:
        return '成功';
      case NotificationType.error:
        return '错误';
      case NotificationType.warning:
        return '警告';
      case NotificationType.info:
        return '提示';
      case NotificationType.custom:
        return '通知';
    }
  }
}

/// 通知管理器（单例模式）
class NotificationHelper {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void initialize() {}

  NotificationHelper._internal();

  static final NotificationHelper _instance = NotificationHelper._internal();

  static NotificationHelper get instance => _instance;

  final List<NotificationConfig> _notificationQueue = [];
  bool _isShowing = false;

  void show(NotificationConfig config) {
    _notificationQueue.add(config);
    _processQueue();
  }

  void _processQueue() {
    if (_isShowing || _notificationQueue.isEmpty) return;

    _isShowing = true;
    final config = _notificationQueue.removeAt(0);
    _showNotificationOverlay(config);
  }

  void _showNotificationOverlay(NotificationConfig config) {
    Future.delayed(Duration.zero, () {
      final context = navigatorKey.currentContext;
      if (context == null) {
        _isShowing = false;
        _processQueue();
        return;
      }
      _showOverlayWithContext(context, config);
    });
  }

  void _showOverlayWithContext(
    BuildContext context,
    NotificationConfig config,
  ) {
    final navigatorState = navigatorKey.currentState;
    if (navigatorState == null) {
      _isShowing = false;
      _processQueue();
      return;
    }

    final overlayState = navigatorState.overlay;
    if (overlayState == null) {
      _isShowing = false;
      _processQueue();
      return;
    }

    OverlayEntry? overlayEntry;
    Timer? dismissTimer;

    overlayEntry = OverlayEntry(
      builder: (context) => NotificationWidget(
        config: config,
        onDismiss: () {
          dismissTimer?.cancel();
          overlayEntry?.remove();
          _isShowing = false;
          config.onDismiss?.call();
          _processQueue();
        },
      ),
    );

    overlayState.insert(overlayEntry!);

    if (config.autoDismiss) {
      dismissTimer = Timer(config.duration, () {
        if (overlayEntry != null && overlayEntry!.mounted) {
          overlayEntry!.remove();
          _isShowing = false;
          config.onDismiss?.call();
          _processQueue();
        }
      });
    }
  }

  static void showSuccess({
    required String message,
    NotificationPosition position = NotificationPosition.top,
    Duration? duration,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 20.0,
    IconData? icon,
    bool autoDismiss = true,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    instance.show(
      NotificationConfig(
        message: message,
        type: NotificationType.success,
        position: position,
        duration: duration ?? const Duration(seconds: 2),
        backgroundColor: backgroundColor,
        textColor: textColor,
        borderRadius: borderRadius,
        icon: icon,
        autoDismiss: autoDismiss,
        onTap: onTap,
        onDismiss: onDismiss,
      ),
    );
  }

  static void showError({
    required String message,
    NotificationPosition position = NotificationPosition.top,
    Duration? duration,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 20.0,
    IconData? icon,
    bool autoDismiss = true,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    instance.show(
      NotificationConfig(
        message: message,
        type: NotificationType.error,
        position: position,
        duration: duration ?? const Duration(seconds: 4),
        backgroundColor: backgroundColor,
        textColor: textColor,
        borderRadius: borderRadius,
        icon: icon,
        autoDismiss: autoDismiss,
        onTap: onTap,
        onDismiss: onDismiss,
      ),
    );
  }

  static void showWarning({
    required String message,
    NotificationPosition position = NotificationPosition.top,
    Duration? duration,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 20.0,
    IconData? icon,
    bool autoDismiss = true,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    instance.show(
      NotificationConfig(
        message: message,
        type: NotificationType.warning,
        position: position,
        duration: duration ?? const Duration(seconds: 3),
        backgroundColor: backgroundColor,
        textColor: textColor,
        borderRadius: borderRadius,
        icon: icon,
        autoDismiss: autoDismiss,
        onTap: onTap,
        onDismiss: onDismiss,
      ),
    );
  }

  static void showInfo({
    required String message,
    NotificationPosition position = NotificationPosition.top,
    Duration? duration,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 20.0,
    IconData? icon,
    bool autoDismiss = true,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    instance.show(
      NotificationConfig(
        message: message,
        type: NotificationType.info,
        position: position,
        duration: duration ?? const Duration(seconds: 4),
        backgroundColor: backgroundColor,
        textColor: textColor,
        borderRadius: borderRadius,
        icon: icon,
        autoDismiss: autoDismiss,
        onTap: onTap,
        onDismiss: onDismiss,
      ),
    );
  }

  static void showCustom({
    required Widget child,
    NotificationPosition position = NotificationPosition.top,
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
    double borderRadius = 20.0,
    bool autoDismiss = true,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    instance.show(
      NotificationConfig(
        child: child,
        type: NotificationType.custom,
        position: position,
        duration: duration,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        autoDismiss: autoDismiss,
        onTap: onTap,
        onDismiss: onDismiss,
      ),
    );
  }

  static void clearAll() {
    instance._notificationQueue.clear();
    instance._isShowing = false;
  }
}
