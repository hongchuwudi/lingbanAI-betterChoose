import '../models/user.dart';
import '../models/api_response.dart';
import '../utils/http_interceptor.dart';

class FamilyService {
  static Future<ApiResponse<List<FamilyBinding>>> getMyRelations() async {
    final response = await HttpInterceptorManager().interceptor
        .get<List<dynamic>>(path: '/user/family-binding/my-relations');
    if (response.isSuccess && response.data != null) {
      return ApiResponse<List<FamilyBinding>>(
        code: response.code,
        message: response.message,
        data: response.data!.map((e) => FamilyBinding.fromJson(e)).toList(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      return ApiResponse<List<FamilyBinding>>(
        code: response.code,
        message: response.message,
        data: null,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  static Future<ApiResponse<List<FamilyBinding>>> getPendingBindings() async {
    final response = await HttpInterceptorManager().interceptor
        .get<List<dynamic>>(path: '/user/family-binding/pending');
    if (response.isSuccess && response.data != null) {
      return ApiResponse<List<FamilyBinding>>(
        code: response.code,
        message: response.message,
        data: response.data!.map((e) => FamilyBinding.fromJson(e)).toList(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      return ApiResponse<List<FamilyBinding>>(
        code: response.code,
        message: response.message,
        data: null,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  static Future<ApiResponse<FamilyBinding>> getBindingDetail(String id) async {
    final response = await HttpInterceptorManager().interceptor
        .get<Map<String, dynamic>>(path: '/user/family-binding/detail/$id');
    if (response.isSuccess && response.data != null) {
      return ApiResponse<FamilyBinding>(
        code: response.code,
        message: response.message,
        data: FamilyBinding.fromJson(response.data!),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      return ApiResponse<FamilyBinding>(
        code: response.code,
        message: response.message,
        data: null,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  static Future<ApiResponse<void>> addBinding({
    required String elderlyProfileId,
    required String childProfileId,
    required String relationType,
    String elderlyToChildRelation = '其他',
  }) async {
    final response = await HttpInterceptorManager().interceptor.post<String>(
      path: '/user/family-binding/add',
      data: {
        'elderlyProfileId': elderlyProfileId,
        'childProfileId': childProfileId,
        'relationType': relationType,
        'elderlyToChildRelation': elderlyToChildRelation,
      },
    );
    return ApiResponse<void>(
      code: response.code,
      message: response.data ?? response.message,
      data: null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<ApiResponse<void>> deleteBinding(String id) async {
    final response = await HttpInterceptorManager().interceptor.delete<String>(
      path: '/user/family-binding/delete/$id',
    );
    return ApiResponse<void>(
      code: response.code,
      message: response.data ?? response.message,
      data: null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<ApiResponse<void>> confirmBinding(String id) async {
    final response = await HttpInterceptorManager().interceptor.put<String>(
      path: '/user/family-binding/confirm/$id',
      data: {},
    );
    return ApiResponse<void>(
      code: response.code,
      message: response.data ?? response.message,
      data: null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<ApiResponse<void>> unbindBinding(String id) async {
    final response = await HttpInterceptorManager().interceptor.put<String>(
      path: '/user/family-binding/unbind/$id',
      data: {},
    );
    return ApiResponse<void>(
      code: response.code,
      message: response.data ?? response.message,
      data: null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<ApiResponse<void>> updateRelation(
    String id,
    String relationType,
  ) async {
    final response = await HttpInterceptorManager().interceptor.put<String>(
      path: '/user/family-binding/update/$id',
      data: {'relationType': relationType},
    );
    return ApiResponse<void>(
      code: response.code,
      message: response.data ?? response.message,
      data: null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<User?> searchUserByNickname(String nickname) async {
    final response = await HttpInterceptorManager().interceptor
        .get<Map<String, dynamic>>(
          path: '/auth/info-nick',
          queryParameters: {'nickname': nickname},
        );
    if (response.isSuccess && response.data != null) {
      return User.fromJson(response.data!);
    }
    return null;
  }

  static Future<User?> getCurrentUserInfo() async {
    final response = await HttpInterceptorManager().interceptor
        .get<Map<String, dynamic>>(path: '/auth/current');
    if (response.isSuccess && response.data != null) {
      return User.fromJson(response.data!);
    }
    return null;
  }
}
