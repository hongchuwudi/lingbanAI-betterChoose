import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/websocket_service.dart';

/// 认证 Store - 像 Pinia 一样简单
class AuthStore extends ChangeNotifier {
  // 状态
  User? user;
  bool loading = false;
  String? error;

  // 计算属性
  bool get isLoggedIn => user != null;
  String get nickname => user?.nickname ?? '';

  // 初始化
  AuthStore() {
    init();
  }

  Future<void> init() async {
    final result = await AuthService.getCurrentUser();
    if (result['success'] && result['user'] != null) {
      user = result['user'];

      // 连接 WebSocket
      WebSocketService().connect().catchError((error) {
        print('WebSocket 连接失败: $error');
      });
    }
    notifyListeners();
  }

  // Actions - 只做一件事
  Future<void> setUser(User? newUser) async {
    user = newUser;
    notifyListeners();
  }

  Future<void> login(String param, String password) async {
    loading = true;
    notifyListeners();

    final result = await AuthService.loginByPassword(param, password);

    if (result['success']) {
      user = result['user'];
      error = null;
    } else {
      error = result['message'];
    }

    loading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.logout();
    user = null;
    error = null;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
