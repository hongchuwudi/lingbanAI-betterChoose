import '../models/friend_message.dart';
import '../models/api_response.dart';
import '../utils/http_interceptor.dart';

class MessageService {
  static Future<ApiResponse<FriendMessage>> sendMessage({
    required String toUserId,
    required String content,
  }) async {
    final response = await HttpInterceptorManager().interceptor.post<Map<String, dynamic>>(
      path: '/message/send',
      data: {'toUserId': toUserId, 'content': content},
    );
    if (response.isSuccess && response.data != null) {
      return ApiResponse<FriendMessage>(
        code: response.code,
        message: response.message,
        data: FriendMessage.fromJson(response.data!),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
    return ApiResponse<FriendMessage>(
      code: response.code,
      message: response.message,
      data: null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<ApiResponse<List<ConversationItem>>> getConversations() async {
    final response = await HttpInterceptorManager().interceptor
        .get<List<dynamic>>(path: '/message/conversations');
    if (response.isSuccess && response.data != null) {
      return ApiResponse<List<ConversationItem>>(
        code: response.code,
        message: response.message,
        data: response.data!
            .map((e) => ConversationItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
    return ApiResponse<List<ConversationItem>>(
      code: response.code,
      message: response.message,
      data: null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<ApiResponse<List<FriendMessage>>> getHistory({
    required String friendUserId,
    int page = 1,
    int size = 50,
  }) async {
    final response = await HttpInterceptorManager().interceptor.get<List<dynamic>>(
      path: '/message/history/$friendUserId',
      queryParameters: {'page': page, 'size': size},
    );
    if (response.isSuccess && response.data != null) {
      return ApiResponse<List<FriendMessage>>(
        code: response.code,
        message: response.message,
        data: response.data!
            .map((e) => FriendMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
    return ApiResponse<List<FriendMessage>>(
      code: response.code,
      message: response.message,
      data: null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<void> markRead(String friendUserId) async {
    await HttpInterceptorManager().interceptor.put<void>(
      path: '/message/read/$friendUserId',
      data: {},
    );
  }

  static Future<ApiResponse<int>> getUnreadCount() async {
    final response = await HttpInterceptorManager().interceptor
        .get<int>(path: '/message/unread-count');
    return ApiResponse<int>(
      code: response.code,
      message: response.message,
      data: response.data ?? 0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
