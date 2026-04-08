import 'package:dio/dio.dart';

/// 错误消息管理类
/// 统一管理所有错误码对应的错误消息
class ErrorMessageManager {
  /// 根据错误码获取对应的错误消息
  static String getErrorMessage(int code) {
    switch (code) {
      // HTTP状态码错误
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '访问禁止';
      case 404:
        return '请求的资源不存在';
      case 405:
        return '请求方法不被允许';
      case 408:
        return '请求超时';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务暂时不可用';
      case 504:
        return '网关超时';

      // 业务错误码 1000-1999
      case 1000:
        return '业务异常';
      case 1001:
        return '参数校验失败';
      case 1002:
        return '数据不存在';
      case 1003:
        return '数据已存在';
      case 1004:
        return '操作失败';
      case 1005:
        return '权限不足';
      case 1006:
        return '验证码错误';
      case 1007:
        return '验证码已过期';
      case 1008:
        return '账号或密码错误';
      case 1009:
        return '账号已被禁用';
      case 1010:
        return '账号不存在';

      // 代理相关错误码 2000-2999
      case 2000:
        return '代理服务错误';
      case 2001:
        return '代理服务超时';
      case 2002:
        return '代理目标错误';

      // 网络相关错误码 3000-3999
      case 3000:
        return '网络连接失败';
      case 3001:
        return '网络连接超时';
      case 3002:
        return 'DNS解析失败';
      case 3003:
        return 'SSL证书错误';

      // 自定义错误码 6000-6999
      case 6666:
        return '自定义错误';

      // 默认错误消息
      default:
        if (code >= 400 && code < 500) {
          return '客户端错误: $code';
        } else if (code >= 500 && code < 600) {
          return '服务器错误: $code';
        } else {
          return '未知错误: $code';
        }
    }
  }

  /// 获取网络异常错误消息
  static String getNetworkErrorMessage(String errorType) {
    switch (errorType) {
      case 'connection_timeout':
        return '网络连接超时，请检查网络设置';
      case 'send_timeout':
        return '请求发送超时';
      case 'receive_timeout':
        return '响应接收超时';
      case 'bad_response':
        return '服务器响应错误';
      case 'cancel':
        return '请求已取消';
      case 'unknown':
        return '网络连接失败';
      default:
        return '网络请求异常';
    }
  }

  /// 获取Dio异常错误消息
  static String getDioErrorMessage(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '网络连接超时，请检查网络设置';
      case DioExceptionType.badResponse:
        return '服务器响应错误';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.unknown:
        return '网络连接失败';
      default:
        return '网络请求异常';
    }
  }
}

/// API响应状态码枚举
/// 对应后端的ResultCode枚举
class ApiResultCode {
  static const int success = 200;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int internalServerError = 500;
  static const int serviceUnavailable = 503;

  // 业务错误码 1000-1999
  static const int businessError = 1000;
  static const int paramValidError = 1001;
  static const int dataNotExist = 1002;
  static const int dataExisted = 1003;
  static const int operationFailed = 1004;
  static const int permissionDenied = 1005;
  static const int verifyCodeError = 1006;
  static const int verifyCodeExpired = 1007;
  static const int accountPasswordError = 1008;
  static const int accountDisabled = 1009;
  static const int accountNotExist = 1010;

  // 代理相关错误码 2000-2999
  static const int proxyError = 2000;
  static const int proxyTimeout = 2001;
  static const int proxyTargetError = 2002;

  // 网络相关错误码 3000-3999
  static const int networkError = 3000;
  static const int networkTimeout = 3001;
  static const int dnsError = 3002;
  static const int sslError = 3003;

  // 自定义错误码
  static const int customError = 6666;
}
