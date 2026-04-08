import '../models/system_notification.dart';
import '../models/api_response.dart';
import '../utils/http_interceptor.dart';

class NotificationService {
  static Future<ApiResponse<List<SystemNotification>>>
  getUnreadNotifications() async {
    final response = await HttpInterceptorManager().interceptor
        .get<List<dynamic>>(path: '/user/notification/unread');
    if (response.isSuccess && response.data != null) {
      return ApiResponse<List<SystemNotification>>(
        code: response.code,
        message: response.message,
        data: response.data!
            .map((e) => SystemNotification.fromJson(e))
            .toList(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      return ApiResponse<List<SystemNotification>>(
        code: response.code,
        message: response.message,
        data: null,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  static Future<ApiResponse<List<SystemNotification>>>
  getAllNotifications() async {
    final response = await HttpInterceptorManager().interceptor
        .get<List<dynamic>>(path: '/user/notification/all');
    if (response.isSuccess && response.data != null) {
      return ApiResponse<List<SystemNotification>>(
        code: response.code,
        message: response.message,
        data: response.data!
            .map((e) => SystemNotification.fromJson(e))
            .toList(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      return ApiResponse<List<SystemNotification>>(
        code: response.code,
        message: response.message,
        data: null,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  static Future<ApiResponse<String>> markAsRead(String notificationId) async {
    final response = await HttpInterceptorManager().interceptor.put<String>(
      path: '/user/notification/read/$notificationId',
      data: {},
    );
    return ApiResponse<String>(
      code: response.code,
      message: response.message,
      data: response.data ?? '',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<ApiResponse<String>> markAllAsRead() async {
    final response = await HttpInterceptorManager().interceptor.put<String>(
      path: '/user/notification/read-all',
      data: {},
    );
    return ApiResponse<String>(
      code: response.code,
      message: response.message,
      data: response.data ?? '',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<ApiResponse<int>> getUnreadCount() async {
    final response = await HttpInterceptorManager().interceptor
        .get<Map<String, dynamic>>(path: '/user/notification/unread-count');
    if (response.isSuccess && response.data != null) {
      return ApiResponse<int>(
        code: response.code,
        message: response.message,
        data: response.data!['count'] as int? ?? 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      return ApiResponse<int>(
        code: response.code,
        message: response.message,
        data: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }
}
