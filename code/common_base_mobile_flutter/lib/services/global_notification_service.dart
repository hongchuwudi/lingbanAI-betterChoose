import 'dart:async';
import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import '../services/audio_service.dart'; 
import '../../widgets/notification/notification_helper.dart';

class GlobalNotificationService {
  static final GlobalNotificationService _instance =
      GlobalNotificationService._internal();
  factory GlobalNotificationService() => _instance;
  GlobalNotificationService._internal();

  static GlobalNotificationService get instance => _instance;

  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;
  StreamSubscription<String>? _familyBindingSubscription;
  final AudioService _audioService = AudioService();

  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    _notificationSubscription = WebSocketService().notificationStream.listen((
      data,
    ) {
      _handleNotification(data);
    });

    _familyBindingSubscription = WebSocketService().familyBindingStream.listen((
      event,
    ) {
      _handleFamilyBindingEvent(event);
    });

    debugPrint('全局通知服务已初始化');
  }

  void _handleNotification(Map<String, dynamic> data) {
    final type = data['type'] ?? '';

    _audioService.playReceiveMessage();

    switch (type) {
      case 'medication_reminder':
        final medicineName = data['medicineName'] ?? '';
        final dosage = data['dosage'] ?? '';
        final time = data['time'] ?? '';
        NotificationHelper.showWarning(
          message: '用药提醒: $medicineName $dosage 于 $time',
          duration: const Duration(seconds: 5),
        );
        break;
      case 'medication_remind_from_child':
        final content = data['content'] ?? '您的家人提醒您按时服药';
        NotificationHelper.showWarning(
          message: content,
          duration: const Duration(seconds: 5),
        );
        break;
      default:
        final content = data['content'] ?? data['message'] ?? '收到新消息';
        NotificationHelper.showInfo(message: content);
    }
  }

  void _handleFamilyBindingEvent(String event) {
    _audioService.playReceiveMessage();

    switch (event) {
      case 'request':
        NotificationHelper.showInfo(message: '您收到一个新的家人绑定请求');
        break;
      case 'confirmed':
        NotificationHelper.showSuccess(message: '家人绑定请求已被确认');
        break;
      case 'rejected':
        NotificationHelper.showWarning(message: '家人绑定请求已被拒绝');
        break;
      case 'deleted':
        NotificationHelper.showWarning(message: '家人关系已被解除');
        break;
    }
  }

  void dispose() {
    _notificationSubscription?.cancel();
    _familyBindingSubscription?.cancel();
    _isInitialized = false;
  }
}
