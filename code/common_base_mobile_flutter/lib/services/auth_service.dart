import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../utils/http_interceptor.dart';
import '../models/user.dart';

/// 认证服务类
/// 负责处理用户认证相关的所有业务逻辑
/// 使用单例模式
class AuthService {
  /// 单例模式实现
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal() {
    // 添加初始化标志，防止重复初始化
    if (!_initialized) {
      HttpInterceptorManager().initialize(
        baseUrl: AppConfig.apiBaseUrl,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );
      _initialized = true;
    }
  }

  static bool _initialized = false;

  /// 根据昵称模糊查找用户信息
  static Future<Map<String, dynamic>> getUserInfoByNick(String nickname) async {
    final response = await HttpInterceptorManager().interceptor
        .get<Map<String, dynamic>>(
          path: '/auth/info-nick',
          queryParameters: {'nickname': nickname},
        );

    return {
      'success': response.isSuccess,
      'data': response.data,
      'message': response.message,
    };
  }

  /// 根据参数查找用户信息
  static Future<Map<String, dynamic>> getUserInfo(String param) async {
    final response = await HttpInterceptorManager().interceptor
        .get<Map<String, dynamic>>(
          path: '/auth/info-un',
          queryParameters: {'param': param},
        );

    return {
      'success': response.isSuccess,
      'data': response.data,
      'message': response.message,
    };
  }

  /// 普通注册用户
  static Future<Map<String, dynamic>> register(
    String username,
    String password,
  ) async {
    final response = await HttpInterceptorManager().interceptor.post<String>(
      path: '/auth/register',
      data: {'username': username, 'password': password},
    );

    return {
      'success': response.isSuccess,
      'message': response.data ?? response.message,
    };
  }

  /// 邮箱注册
  static Future<Map<String, dynamic>> registerByEmail(
    String email,
    String password,
    String verifyCode,
  ) async {
    final response = await HttpInterceptorManager().interceptor.post<String>(
      path: '/auth/register-email',
      data: {'email': email, 'password': password, 'verifyCode': verifyCode},
    );

    return {
      'success': response.isSuccess,
      'message': response.data ?? response.message,
    };
  }

  /// 密码登录
  static Future<Map<String, dynamic>> loginByPassword(
    String param,
    String password,
  ) async {
    final response = await HttpInterceptorManager().interceptor
        .post<Map<String, dynamic>>(
          path: '/auth/login',
          data: {'param': param, 'password': password},
        );

    if (response.isSuccess && response.data != null) {
      final user = User.fromJson(response.data!);
      print('登录成功，用户信息: ${user.toJson()}');
      print('Token: ${user.token}');
      await _saveUser(user);
    }

    return {
      'success': response.isSuccess,
      'user': response.isSuccess && response.data != null
          ? User.fromJson(response.data!)
          : null,
      'message': response.message,
    };
  }

  /// 邮箱登录
  static Future<Map<String, dynamic>> loginByEmail(
    String email,
    String verifyCode,
  ) async {
    final response = await HttpInterceptorManager().interceptor
        .post<Map<String, dynamic>>(
          path: '/auth/login-email',
          data: {'email': email, 'verifyCode': verifyCode},
        );

    if (response.isSuccess && response.data != null) {
      await _saveUser(User.fromJson(response.data!));
    }

    return {
      'success': response.isSuccess,
      'user': response.isSuccess && response.data != null
          ? User.fromJson(response.data!)
          : null,
      'message': response.message,
    };
  }

  /// 手机验证码登录
  static Future<Map<String, dynamic>> loginByPhone(
    String phone,
    String verifyCode,
  ) async {
    final response = await HttpInterceptorManager().interceptor
        .post<Map<String, dynamic>>(
          path: '/auth/login-phone',
          data: {'phone': phone, 'verifyCode': verifyCode},
        );

    if (response.isSuccess && response.data != null) {
      await _saveUser(User.fromJson(response.data!));
    }

    return {
      'success': response.isSuccess,
      'user': response.isSuccess && response.data != null
          ? User.fromJson(response.data!)
          : null,
      'message': response.message,
    };
  }

  /// 手机号注册
  static Future<Map<String, dynamic>> registerByPhone(
    String phone,
    String password,
    String verifyCode,
  ) async {
    final response = await HttpInterceptorManager().interceptor.post<String>(
      path: '/auth/register-phone',
      data: {'phone': phone, 'password': password, 'verifyCode': verifyCode},
    );

    return {
      'success': response.isSuccess,
      'message': response.data ?? response.message,
    };
  }

  /// 忘记密码（手机号）
  static Future<Map<String, dynamic>> forgetPasswordByPhone(
    String phone,
    String password,
    String verifyCode,
  ) async {
    final response = await HttpInterceptorManager().interceptor.post<String>(
      path: '/auth/forget-password-phone',
      data: {'phone': phone, 'password': password, 'verifyCode': verifyCode},
    );

    return {
      'success': response.isSuccess,
      'message': response.data ?? response.message,
    };
  }

  /// 发送邮箱验证码
  static Future<Map<String, dynamic>> sendEmailCode(String email) async {
    final response = await HttpInterceptorManager().interceptor.post<String>(
      path: '/auth/send-email-code',
      data: {'email': email},
    );

    return {
      'success': response.isSuccess,
      'message': response.data ?? response.message,
    };
  }

  /// 发送手机验证码
  static Future<Map<String, dynamic>> sendPhoneCode(String phone) async {
    final response = await HttpInterceptorManager().interceptor.post<String>(
      path: '/auth/send-phone-code',
      data: {'phone': phone},
    );

    return {
      'success': response.isSuccess,
      'message': response.data ?? response.message,
    };
  }

  /// 重置密码
  static Future<Map<String, dynamic>> resetPassword(
    String username,
    String oldPassword,
    String newPassword,
  ) async {
    final response = await HttpInterceptorManager().interceptor.post<String>(
      path: '/auth/reset',
      data: {
        'username': username,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );

    return {
      'success': response.isSuccess,
      'message': response.data ?? response.message,
    };
  }

  /// 修改用户名
  static Future<Map<String, dynamic>> updateUsername(
    String username,
    String password,
    String verifyCode,
  ) async {
    final response = await HttpInterceptorManager().interceptor.post<String>(
      path: '/auth/username',
      data: {
        'username': username,
        'password': password,
        'verifyCode': verifyCode,
      },
      headers: {'Content-Type': 'application/json'},
    );

    return {
      'success': response.isSuccess,
      'message': response.data ?? response.message,
    };
  }

  /// 忘记密码（邮箱）
  static Future<Map<String, dynamic>> forgetPassword(
    String email,
    String password,
    String verifyCode,
  ) async {
    final response = await HttpInterceptorManager().interceptor.post<String>(
      path: '/auth/forget-password',
      data: {'email': email, 'password': password, 'verifyCode': verifyCode},
    );

    return {
      'success': response.isSuccess,
      'message': response.data ?? response.message,
    };
  }

  /// 注销用户
  static Future<Map<String, dynamic>> deleteUser(int id) async {
    final response = await HttpInterceptorManager().interceptor.delete<String>(
      path: '/auth/$id',
    );

    return {
      'success': response.isSuccess,
      'message': response.data ?? response.message,
    };
  }

  /// 修改用户信息
  static Future<Map<String, dynamic>> updateUserInfo(
    Map<String, dynamic> userData,
  ) async {
    final response = await HttpInterceptorManager().interceptor
        .put<Map<String, dynamic>>(
          path: '/auth',
          data: userData,
          headers: {'Content-Type': 'application/json'},
        );

    final user = response.isSuccess && response.data != null
        ? User.fromJson(response.data!)
        : null;

    if (user != null) {
      await _saveUser(user);
    }

    return {
      'success': response.isSuccess,
      'user': user,
      'message': response.message,
    };
  }

  /// 保存用户到本地
  static Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();

    // 读取本地存储的旧用户信息，保留 token
    final oldUserStr = prefs.getString('user');
    String? oldToken;
    String? oldRefreshToken;

    if (oldUserStr != null && oldUserStr.isNotEmpty) {
      try {
        final oldUser = User.fromJson(jsonDecode(oldUserStr));
        oldToken = oldUser.token;
        oldRefreshToken = oldUser.refreshToken;
      } catch (e) {
        print('解析旧用户信息失败: $e');
      }
    }

    // 如果新用户没有 token，使用旧 token
    final userToSave = User(
      id: user.id,
      nickname: user.nickname,
      username: user.username,
      email: user.email,
      phone: user.phone,
      avatar: user.avatar,
      birthday: user.birthday,
      gender: user.gender,
      bio: user.bio,
      updateUnTimes: user.updateUnTimes,
      isVip: user.isVip,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      roleCode: user.roleCode,
      roleName: user.roleName,
      roleCategory: user.roleCategory,
      roleDescription: user.roleDescription,
      isActive: user.isActive,
      token: user.token ?? oldToken,
      refreshToken: user.refreshToken ?? oldRefreshToken,
      elderlyProfile: user.elderlyProfile,
      childProfile: user.childProfile,
    );

    final userJson = jsonEncode(userToSave.toJson());
    print('保存用户信息到本地: $userJson');
    await prefs.setString('user', userJson);
    print('用户信息已保存');
  }

  /// 获取本地用户
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    print('从本地读取用户信息: $userStr');
    if (userStr != null && userStr.isNotEmpty) {
      return User.fromJson(jsonDecode(userStr));
    }
    return null;
  }

  /// 检查是否已登录
  static Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user != null;
  }

  /// 获取token
  static Future<String?> getToken() async {
    final user = await getUser();
    print('获取 token: ${user?.token}');
    return user?.token;
  }

  /// 退出登录
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  /// 检查是否是第一次启动
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConfig.isFirstLaunchKey) ?? true;
  }

  /// 设置已启动过
  static Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.isFirstLaunchKey, false);
  }

  /// 获取当前用户信息
  ///
  /// 调用后端接口 /auth/current 获取用户信息
  /// 包含 elderlyProfile 和 childProfile 信息
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await HttpInterceptorManager().interceptor
        .get<Map<String, dynamic>>(path: '/auth/current');

    final user = response.isSuccess && response.data != null
        ? User.fromJson(response.data!)
        : null;

    if (user != null) {
      await _saveUser(user);
    }

    return {
      'success': response.isSuccess,
      'user': user,
      'message': response.message,
    };
  }

  /// 创建老人档案
  ///
  /// 请求体：{
  ///   "nickname": "张爷爷",
  ///   "birthday": "1945-05-15",
  ///   "gender": 1,
  ///   "chronicDiseases": "[\"高血压\",\"糖尿病\"]",
  ///   "allergies": "[\"青霉素\"]",
  ///   "livingStatus": "alone",
  ///   "address": "北京市朝阳区xxx",
  ///   "emergencyContact": "{\"name\":\"张先生\",\"phone\":\"138****0000\",\"relation\":\"儿子\"}",
  ///   "dietRestrictions": "[\"低盐\",\"低糖\"]"
  /// }
  static Future<Map<String, dynamic>> createElderlyProfile(
    Map<String, dynamic> profileData,
  ) async {
    final response = await HttpInterceptorManager().interceptor
        .post<Map<String, dynamic>>(
          path: '/user/elderly-profile/add',
          data: profileData,
          headers: {'Content-Type': 'application/json'},
        );

    if (response.isSuccess) {
      final userResponse = await getCurrentUser();
      return userResponse;
    }

    return {'success': response.isSuccess, 'message': response.message};
  }

  /// 获取当前用户的老人档案
  static Future<Map<String, dynamic>> getElderlyProfile() async {
    final response = await HttpInterceptorManager().interceptor
        .get<Map<String, dynamic>>(path: '/user/elderly-profile/get');

    return {
      'success': response.isSuccess,
      'data': response.data,
      'message': response.message,
    };
  }

  /// 更新当前用户的老人档案
  static Future<Map<String, dynamic>> updateElderlyProfile(
    Map<String, dynamic> profileData,
  ) async {
    final response = await HttpInterceptorManager().interceptor
        .put<Map<String, dynamic>>(
          path: '/user/elderly-profile/update',
          data: profileData,
          headers: {'Content-Type': 'application/json'},
        );

    return {
      'success': response.isSuccess,
      'data': response.data,
      'message': response.message,
    };
  }

  /// 创建子女档案
  ///
  /// 请求体：{
  ///   "nickname": "张先生",
  ///   "guardianSettings": "{\"receive_sos\":true,\"receive_alert\":true,\"receive_health_report\":true,\"receive_daily_check_in\":true}",
  ///   "checkinSettings": "{}"
  /// }
  static Future<Map<String, dynamic>> createChildProfile(
    Map<String, dynamic> profileData,
  ) async {
    final response = await HttpInterceptorManager().interceptor
        .post<Map<String, dynamic>>(
          path: '/user/child-profile/add',
          data: profileData,
          headers: {'Content-Type': 'application/json'},
        );

    if (response.isSuccess) {
      final userResponse = await getCurrentUser();
      return userResponse;
    }

    return {'success': response.isSuccess, 'message': response.message};
  }

  /// 获取当前用户的所有关系
  static Future<Map<String, dynamic>> getMyRelations() async {
    final response = await HttpInterceptorManager().interceptor
        .get<List<dynamic>>(path: '/user/family-binding/my-relations');

    return {
      'success': response.isSuccess,
      'data': response.data,
      'message': response.message,
    };
  }

  /// 获取老人的所有子女
  static Future<Map<String, dynamic>> getElderlyRelations(
    String elderlyProfileId,
  ) async {
    final response = await HttpInterceptorManager().interceptor
        .get<List<dynamic>>(
          path: '/user/family-binding/elderly/$elderlyProfileId',
        );

    return {
      'success': response.isSuccess,
      'data': response.data,
      'message': response.message,
    };
  }

  /// 获取子女的所有老人
  static Future<Map<String, dynamic>> getChildRelations(
    String childProfileId,
  ) async {
    final response = await HttpInterceptorManager().interceptor
        .get<List<dynamic>>(path: '/user/family-binding/child/$childProfileId');

    return {
      'success': response.isSuccess,
      'data': response.data,
      'message': response.message,
    };
  }

  /// 添加家人关系
  static Future<Map<String, dynamic>> addBinding(
    String elderlyProfileId,
    String childProfileId,
    String relationType,
  ) async {
    final response = await HttpInterceptorManager().interceptor.post<String>(
      path: '/user/family-binding/add',
      data: {
        'elderlyProfileId': elderlyProfileId,
        'childProfileId': childProfileId,
        'relationType': relationType,
      },
    );

    return {
      'success': response.isSuccess,
      'message': response.data ?? response.message,
    };
  }

  /// 删除家人关系
  static Future<Map<String, dynamic>> deleteBinding(String id) async {
    final response = await HttpInterceptorManager().interceptor.delete<String>(
      path: '/user/family-binding/delete/$id',
    );

    return {
      'success': response.isSuccess,
      'message': response.data ?? response.message,
    };
  }

  /// 确认绑定
  static Future<Map<String, dynamic>> confirmBinding(String id) async {
    final response = await HttpInterceptorManager().interceptor.put<String>(
      path: '/user/family-binding/confirm/$id',
      data: {},
    );

    return {
      'success': response.isSuccess,
      'message': response.data ?? response.message,
    };
  }

  /// 解绑
  static Future<Map<String, dynamic>> unbindBinding(String id) async {
    final response = await HttpInterceptorManager().interceptor.put<String>(
      path: '/user/family-binding/unbind/$id',
      data: {},
    );

    return {
      'success': response.isSuccess,
      'message': response.data ?? response.message,
    };
  }

  /// 上传文件到 OSS
  ///
  /// @param file 要上传的文件（XFile）
  /// @param bizType 业务类型，默认为 'avatar'
  /// @return 上传结果，包含文件 URL
  static Future<Map<String, dynamic>> uploadFile(
    XFile file, {
    String bizType = 'avatar',
  }) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': '未登录'};
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          headers: {'Authorization': 'Bearer $token'},
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      MultipartFile multipartFile;

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        multipartFile = MultipartFile.fromBytes(bytes, filename: file.name);
      } else if (Platform.isAndroid || Platform.isIOS) {
        multipartFile = MultipartFile.fromFileSync(
          file.path,
          filename: file.name,
        );
      } else {
        final bytes = await file.readAsBytes();
        multipartFile = MultipartFile.fromBytes(bytes, filename: file.name);
      }

      final formData = FormData.fromMap({
        'file': multipartFile,
        'bizType': bizType,
      });

      final response = await dio.post('/file/upload', data: formData);

      if (response.statusCode == 200 && response.data['code'] == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': '上传成功',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? '上传失败',
        };
      }
    } catch (e) {
      print('上传文件失败: $e');
      return {'success': false, 'message': '网络错误，请重试'};
    }
  }

  /// 更新用户头像
  ///
  /// @param avatarUrl 头像 URL
  /// @return 更新结果
  static Future<Map<String, dynamic>> updateAvatar(String avatarUrl) async {
    final currentUser = await getUser();

    if (currentUser == null) {
      return {'success': false, 'message': '用户信息不存在'};
    }

    final response = await HttpInterceptorManager().interceptor
        .put<Map<String, dynamic>>(
          path: '/auth',
          data: {'id': currentUser.id, 'avatar': avatarUrl},
          headers: {'Content-Type': 'application/json'},
        );

    final user = response.isSuccess && response.data != null
        ? User.fromJson(response.data!)
        : null;

    if (user != null) {
      await _saveUser(user);
    }

    return {
      'success': response.isSuccess,
      'user': user,
      'message': response.message,
    };
  }

  /// 切换用户角色
  /// @param roleCode 角色代码 (oldMan/young)
  /// @param roleName 角色名称 (老人/子女)
  static Future<Map<String, dynamic>> switchRole({
    required String roleCode,
    required String roleName,
  }) async {
    final response = await HttpInterceptorManager().interceptor.post<String>(
      path: '/user/role/assign',
      data: {
        'roleCode': roleCode,
        'roleName': roleName,
        'roleCategory': 'BUSINESS',
      },
      headers: {'Content-Type': 'application/json'},
    );

    return {
      'success': response.isSuccess,
      'message': response.data ?? response.message,
    };
  }

  /// 检查用户档案信息
  /// 返回用户是否有老人档案和子女档案
  static Future<Map<String, bool>> checkProfiles() async {
    final user = await getUser();
    if (user == null) {
      return {'hasElderly': false, 'hasChild': false};
    }
    return {
      'hasElderly': user.elderlyProfile != null,
      'hasChild': user.childProfile != null,
    };
  }
}
