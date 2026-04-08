import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import 'error_message_manager.dart';
import '../services/auth_service.dart';

/// HTTP请求拦截器（基于Dio）
/// 统一处理API请求和响应，适配后端Result<T>格式
class HttpInterceptor {
  /// Dio实例
  late final Dio _dio;

  /// 基础URL
  final String baseUrl;

  /// 请求头
  final Map<String, dynamic> defaultHeaders;

  HttpInterceptor({required this.baseUrl, Map<String, dynamic>? headers})
    : defaultHeaders =
          headers ?? {'Content-Type': 'application/x-www-form-urlencoded'} {
    // 初始化Dio实例
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: defaultHeaders,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );

    // 添加请求拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (RequestOptions options, RequestInterceptorHandler handler) async {
              // 获取 JWT token
              final token = await AuthService.getToken();

              // 如果有 token，添加到请求头
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
                print(
                  '已添加 Authorization 头: Bearer ${token.substring(0, 10)}...',
                );
              } else {
                print('警告: 未找到 token，请求可能失败');
              }

              // 请求前处理
              print('发送请求: ${options.method} ${options.path}');
              print('请求头: ${options.headers}');
              handler.next(options);
            },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          // 响应处理
          print('收到响应: ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) {
          // 错误处理
          print('请求错误: ${error.type} ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// 发送POST请求
  Future<ApiResponse<T>> post<T>({
    required String path,
    required dynamic data,
    Map<String, dynamic>? headers,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) async {
    try {
      final requestHeaders = {...defaultHeaders, ...?headers};

      final response = await _dio.post(
        path,
        data: data,
        options: Options(
          headers: requestHeaders,
          sendTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
        ),
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// 发送GET请求
  Future<ApiResponse<T>> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      // 合并请求头
      final requestHeaders = {...defaultHeaders, ...?headers};

      // 发送请求
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: requestHeaders),
      );

      // 处理响应
      return _handleResponse<T>(response);
    } catch (e) {
      // 处理网络异常
      return _handleError<T>(e);
    }
  }

  /// 发送PUT请求
  Future<ApiResponse<T>> put<T>({
    required String path,
    required Map<String, dynamic> data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      // 合并请求头
      final requestHeaders = {...defaultHeaders, ...?headers};

      // 发送请求
      final response = await _dio.put(
        path,
        data: data,
        options: Options(headers: requestHeaders),
      );

      // 处理响应
      return _handleResponse<T>(response);
    } catch (e) {
      // 处理网络异常
      return _handleError<T>(e);
    }
  }

  /// 发送DELETE请求
  Future<ApiResponse<T>> delete<T>({
    required String path,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final requestHeaders = {...defaultHeaders, ...?headers};

      final response = await _dio.delete(
        path,
        options: Options(headers: requestHeaders),
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> uploadMultipart<T>({
    required String path,
    required String filePath,
    required String fileName,
    String fieldName = 'file',
    Map<String, dynamic>? extraData,
    Map<String, dynamic>? headers,
    ProgressCallback? onProgress,
    Duration? receiveTimeout,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath, filename: fileName),
        ...?extraData,
      });

      final requestHeaders = headers ?? {};

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: requestHeaders,
          receiveTimeout: receiveTimeout,
        ),
        onSendProgress: onProgress,
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> uploadMultipartBytes<T>({
    required String path,
    required List<int> bytes,
    required String fileName,
    String fieldName = 'file',
    Map<String, dynamic>? extraData,
    Map<String, dynamic>? headers,
    ProgressCallback? onProgress,
    Duration? receiveTimeout,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: MultipartFile.fromBytes(bytes, filename: fileName),
        ...?extraData,
      });

      final requestHeaders = headers ?? {};

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: requestHeaders,
          receiveTimeout: receiveTimeout,
        ),
        onSendProgress: onProgress,
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// 处理Dio响应
  ApiResponse<T> _handleResponse<T>(Response response) {
    // 检查HTTP状态码
    if (response.statusCode != ApiResultCode.success) {
      final statusCode =
          response.statusCode ?? ApiResultCode.internalServerError;
      return ApiResponse.fail<T>(
        statusCode,
        'HTTP请求失败: ${response.statusCode}',
      );
    }

    try {
      // 解析响应数据
      final jsonData = response.data;

      // 如果响应数据是字符串，尝试解析为JSON
      if (jsonData is String) {
        final parsedData = jsonDecode(jsonData);
        return ApiResponse<T>.fromJson(parsedData);
      }

      // 如果已经是Map类型，直接转换
      if (jsonData is Map<String, dynamic>) {
        return ApiResponse<T>.fromJson(jsonData);
      }

      // 其他类型的数据
      return ApiResponse.fail<T>(ApiResultCode.internalServerError, '响应数据格式错误');
    } catch (e) {
      // JSON解析失败
      return ApiResponse.fail<T>(
        ApiResultCode.internalServerError,
        '响应数据解析失败: $e',
      );
    }
  }

  /// 处理网络异常
  ApiResponse<T> _handleError<T>(Object error) {
    if (error is DioException) {
      // Dio异常处理
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiResponse.fail<T>(
            ApiResultCode.networkTimeout,
            ErrorMessageManager.getDioErrorMessage(error.type),
          );
        case DioExceptionType.badResponse:
          final statusCode =
              error.response?.statusCode ?? ApiResultCode.internalServerError;
          return ApiResponse.fail<T>(
            statusCode,
            ErrorMessageManager.getDioErrorMessage(error.type),
          );
        case DioExceptionType.cancel:
          return ApiResponse.fail<T>(
            ApiResultCode.customError,
            ErrorMessageManager.getDioErrorMessage(error.type),
          );
        case DioExceptionType.connectionError:
          return ApiResponse.fail<T>(
            ApiResultCode.networkError,
            ErrorMessageManager.getDioErrorMessage(error.type),
          );
        default:
          return ApiResponse.fail<T>(
            ApiResultCode.internalServerError,
            ErrorMessageManager.getDioErrorMessage(error.type),
          );
      }
    }

    // 其他异常
    return ApiResponse.fail<T>(
      ApiResultCode.internalServerError,
      '网络请求异常: $error',
    );
  }
}

/// HTTP拦截器单例
class HttpInterceptorManager {
  static final HttpInterceptorManager _instance =
      HttpInterceptorManager._internal();

  factory HttpInterceptorManager() => _instance;

  HttpInterceptorManager._internal();

  // 改为可空类型
  HttpInterceptor? _interceptor;

  /// 初始化拦截器
  void initialize({required String baseUrl, Map<String, dynamic>? headers}) {
    _interceptor = HttpInterceptor(baseUrl: baseUrl, headers: headers);
  }

  /// 获取拦截器实例
  HttpInterceptor get interceptor {
    if (_interceptor == null) {
      throw Exception('HttpInterceptor未初始化，请先调用initialize方法');
    }
    return _interceptor!;
  }

  /// 检查是否已初始化
  bool get isInitialized => _interceptor != null;
}
