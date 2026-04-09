import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../services/audio_service.dart';
import '../widgets/notification/notification_helper.dart';

enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

typedef WebSocketConnectionCallback =
    void Function(WebSocketConnectionState state);
typedef WebSocketMessageCallback = void Function(Map<String, dynamic> message);

class WebSocketService with WidgetsBindingObserver {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  final AudioService _audioService = AudioService();
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  bool _intentionalDisconnect = false; // 标记是否主动断开，避免触发重连
  Timer? _heartbeatTimer;
  Timer? _heartbeatTimeoutTimer; // 心跳超时检测
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _heartbeatTimeout = Duration(seconds: 60); // 60s无pong则重连

  WebSocketConnectionState _connectionState =
      WebSocketConnectionState.disconnected;
  final List<WebSocketConnectionCallback> _connectionCallbacks = [];
  final List<WebSocketMessageCallback> _messageCallbacks = [];

  final StreamController<String> _familyBindingController =
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<String> get familyBindingStream => _familyBindingController.stream;
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  bool get isConnected => _isConnected;
  WebSocketConnectionState get connectionState => _connectionState;

  void addConnectionCallback(WebSocketConnectionCallback callback) {
    _connectionCallbacks.add(callback);
  }

  void removeConnectionCallback(WebSocketConnectionCallback callback) {
    _connectionCallbacks.remove(callback);
  }

  void addMessageCallback(WebSocketMessageCallback callback) {
    _messageCallbacks.add(callback);
  }

  void removeMessageCallback(WebSocketMessageCallback callback) {
    _messageCallbacks.remove(callback);
  }

  void _notifyConnectionState(WebSocketConnectionState state) {
    _connectionState = state;
    for (final callback in _connectionCallbacks) {
      callback(state);
    }
  }

  void _notifyMessage(Map<String, dynamic> message) {
    for (final callback in _messageCallbacks) {
      callback(message);
    }
  }

  Future<void> connect({bool forceReconnect = false}) async {
    if (_isConnected && !forceReconnect) {
      print('WebSocket 已连接，跳过重复连接');
      return;
    }

    if (_connectionState == WebSocketConnectionState.connecting ||
        _connectionState == WebSocketConnectionState.reconnecting) {
      print('WebSocket 正在连接或重连中，跳过');
      return;
    }

    try {
      _intentionalDisconnect = false;
      _notifyConnectionState(WebSocketConnectionState.connecting);

      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        print('WebSocket 连接失败: Token 为空');
        _notifyConnectionState(WebSocketConnectionState.disconnected);
        return;
      }

      print('正在连接 WebSocket: ${AppConfig.wsBaseUrl}/ws');

      final wsUrl = Uri.parse('${AppConfig.wsBaseUrl}/ws?token=$token');

      print('WebSocket URL: $wsUrl');

      _channel = WebSocketChannel.connect(wsUrl);

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      _notifyConnectionState(WebSocketConnectionState.connected);
      _startHeartbeat();
      print('WebSocket 连接成功');
    } catch (e) {
      _isConnected = false;
      _notifyConnectionState(WebSocketConnectionState.disconnected);
      print('WebSocket 连接异常: $e');
      _handleError(e);

      if (!forceReconnect) {
        _scheduleReconnect();
      }
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('WebSocket 重连次数已达上限，停止重连');
      return;
    }

    _reconnectAttempts++;
    print(
      'WebSocket 将在 ${_reconnectDelay.inSeconds} 秒后进行第 $_reconnectAttempts 次重连',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _notifyConnectionState(WebSocketConnectionState.reconnecting);
      connect(forceReconnect: true);
    });
  }

  void refreshConnection() {
    print('WebSocket 刷新连接...');
    _intentionalDisconnect = false;
    disconnect();
    _reconnectAttempts = 0;
    connect(forceReconnect: true);
  }

  void disconnect() {
    _intentionalDisconnect = true;
    _heartbeatTimer?.cancel();
    _heartbeatTimeoutTimer?.cancel();
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _notifyConnectionState(WebSocketConnectionState.disconnected);
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        _handleError(e);
      }
    }
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      final type = data['type'];

      switch (type) {
        case 'connected':
          print('WebSocket 连接成功: ${data['data']}');
          break;
        case 'pong':
          // 收到pong，取消超时计时器，连接正常
          _heartbeatTimeoutTimer?.cancel();
          print('收到心跳响应，连接正常');
          break;
        case 'system_notification':
          _handleSystemNotification(data['data']);
          break;
        case 'chat_message':
          _handleChatMessage(data);
          break;
        case 'health_reminder':
          _handleHealthReminder(data['data']);
          break;
        case 'medication_reminder':
          _handleMedicationReminder(data['data']);
          break;
        case 'medication_remind_from_child':
          _handleMedicationRemindFromChild(data['data']);
          break;
        case 'family_binding_request':
          _handleFamilyBindingRequest(data['data']);
          break;
        case 'family_binding_confirmed':
          _handleFamilyBindingConfirmed(data['data']);
          break;
        case 'family_binding_rejected':
          _handleFamilyBindingRejected(data['data']);
          break;
        case 'family_binding_deleted':
          _handleFamilyBindingDeleted(data['data']);
          break;
        case 'error':
          print('WebSocket 错误: ${data['data']['error_message']}');
          break;
        default:
          print('收到未知消息类型: $type');
      }

      _notifyMessage(data);
    } catch (e) {
      print('消息解析失败: $e');
    }
  }

  void _handleSystemNotification(dynamic data) {
    final title = data['title'] ?? '系统通知';
    final content = data['content'] ?? '';
    final level = data['level'] ?? 'info';

    print('收到系统通知: $title - $content (级别: $level)');

    _audioService.playReceiveMessage();

    if (level == 'important') {
      NotificationHelper.showWarning(message: content);
    } else if (level == 'warning') {
      NotificationHelper.showError(message: content);
    } else {
      NotificationHelper.showSuccess(message: content);
    }
  }

  void _handleChatMessage(Map<String, dynamic> message) {
    final fromUserId = message['fromUserId'];
    final content = message['data']['content'] ?? '';

    print('收到聊天消息: 来自 $fromUserId - $content');

    _audioService.playReceiveMessage();
    NotificationHelper.showSuccess(message: '收到新消息: $content');
  }

  void _handleHealthReminder(dynamic data) {
    final reminderType = data['reminderType'] ?? 'health';
    final message = data['message'] ?? '';
    final level = data['level'] ?? 'info';

    print('收到健康提醒: $reminderType - $message');

    _audioService.playReceiveMessage();

    if (level == 'warning') {
      NotificationHelper.showWarning(message: message);
    } else {
      NotificationHelper.showSuccess(message: message);
    }
  }

  void _handleMedicationReminder(dynamic data) {
    final medicineName = data['medicineName'] ?? '';
    final dosage = data['dosage'] ?? '';
    final time = data['time'] ?? '';
    final recordId = data['recordId'] ?? '';
    final notificationId = data['notificationId'] ?? '';

    final message = '用药提醒: $medicineName $dosage 于 $time';
    print('收到用药提醒: $message');

    _audioService.playReceiveMessage();
    NotificationHelper.showWarning(message: message);

    _notificationController.add({
      'type': 'medication_reminder',
      'medicineName': medicineName,
      'dosage': dosage,
      'time': time,
      'recordId': recordId,
      'notificationId': notificationId,
    });
  }

  void _handleMedicationRemindFromChild(dynamic data) {
    final title = data['title'] ?? '用药提醒';
    final content = data['content'] ?? '';
    final notificationId = data['notificationId'] ?? '';

    print('收到子女提醒: $title - $content');

    _audioService.playReceiveMessage();
    NotificationHelper.showWarning(message: content);

    _notificationController.add({
      'type': 'medication_remind_from_child',
      'title': title,
      'content': content,
      'notificationId': notificationId,
    });
  }

  void _handleFamilyBindingRequest(dynamic data) {
    final content = data['content'] ?? '';
    final fromUserName = data['fromUserName'] ?? '用户';

    print('收到家人绑定请求: $content');

    _audioService.playReceiveMessage();
    NotificationHelper.showSuccess(message: '$fromUserName 想要添加您为家人关系');
    _familyBindingController.add('request');
  }

  void _handleFamilyBindingConfirmed(dynamic data) {
    final content = data['content'] ?? '';
    final fromUserName = data['fromUserName'] ?? '用户';

    print('收到家人绑定确认: $content');

    _audioService.playReceiveMessage();
    NotificationHelper.showSuccess(message: '$fromUserName 已确认您的家人绑定请求');
    _familyBindingController.add('confirmed');
  }

  void _handleFamilyBindingRejected(dynamic data) {
    final content = data['content'] ?? '';
    final fromUserName = data['fromUserName'] ?? '用户';

    print('收到家人绑定拒绝: $content');

    _audioService.playReceiveMessage();
    NotificationHelper.showWarning(message: '$fromUserName 拒绝了您的家人绑定请求');
    _familyBindingController.add('rejected');
  }

  void _handleFamilyBindingDeleted(dynamic data) {
    final content = data['content'] ?? '';
    final fromUserName = data['fromUserName'] ?? '用户';

    print('收到家人关系解除: $content');

    _audioService.playReceiveMessage();
    NotificationHelper.showWarning(message: '$fromUserName 解除了与您的家人关系');
    _familyBindingController.add('deleted');
  }

  void _onError(dynamic error) {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _heartbeatTimeoutTimer?.cancel();
    _notifyConnectionState(WebSocketConnectionState.disconnected);
    print('WebSocket 错误: $error');
    // 修复：错误时触发重连（之前此处缺少重连逻辑）
    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    }
  }

  void _onDone() {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _heartbeatTimeoutTimer?.cancel();
    _reconnectTimer?.cancel();
    _notifyConnectionState(WebSocketConnectionState.disconnected);
    print('WebSocket 连接已关闭');
    // 非主动断开时自动重连
    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimeoutTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_isConnected) return;
      sendMessage({
        'type': 'heartbeat',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      // 发送心跳后启动超时检测，60s内收不到pong则重连
      _heartbeatTimeoutTimer?.cancel();
      _heartbeatTimeoutTimer = Timer(_heartbeatTimeout, () {
        print('WebSocket 心跳超时，主动重连...');
        refreshConnection();
      });
    });
  }

  /// 监听应用生命周期，后台→前台时检查并恢复连接
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App 回到前台，检查 WebSocket 连接状态...');
      if (!_isConnected && !_intentionalDisconnect) {
        _reconnectAttempts = 0;
        connect(forceReconnect: true);
      }
    } else if (state == AppLifecycleState.paused) {
      print('App 进入后台，暂停心跳检测');
      _heartbeatTimeoutTimer?.cancel();
    }
  }

  void _handleError(dynamic error) {
    print('WebSocket 错误: $error');
  }
}
