import '../utils/error_message_manager.dart';

/// 统一API响应模型
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;
  final int timestamp;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
    required this.timestamp,
  });

  /// 从JSON创建ApiResponse
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse<T>(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] as T?,
      timestamp: json['timestamp'] as int,
    );
  }

  /// 创建成功响应
  static ApiResponse<T> success<T>(T data) {
    return ApiResponse<T>(
      code: ApiResultCode.success,
      message: '操作成功',
      data: data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 创建失败响应
  static ApiResponse<T> fail<T>(int code, [String? customMessage]) {
    return ApiResponse<T>(
      code: code,
      message: customMessage ?? ErrorMessageManager.getErrorMessage(code),
      data: null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 创建网络错误响应
  static ApiResponse<T> networkError<T>(String errorType) {
    return ApiResponse<T>(
      code: ApiResultCode.networkError,
      message: ErrorMessageManager.getNetworkErrorMessage(errorType),
      data: null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 判断是否成功
  bool get isSuccess => code == ApiResultCode.success;

  /// 获取错误消息
  String get errorMessage => message;

  @override
  String toString() {
    return 'ApiResponse{code: $code, message: $message, data: $data, timestamp: $timestamp}';
  }
}
