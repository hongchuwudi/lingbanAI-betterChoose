import '../models/wechat_article.dart';
import '../models/api_response.dart';
import '../utils/http_interceptor.dart';

class WechatArticleService {
  static Future<ApiResponse<List<WechatArticle>>> getArticleList({
    int page = 1,
    int size = 10,
  }) async {
    final response =
        await HttpInterceptorManager().interceptor.get<Map<String, dynamic>>(
      path: '/wechat-article/list',
      queryParameters: {'page': page, 'size': size},
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      List<dynamic> records = [];

      if (data.containsKey('records')) {
        records = data['records'] as List<dynamic>;
      }

      final list = records
          .map((e) => WechatArticle.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse<List<WechatArticle>>(
        code: response.code,
        message: response.message,
        data: list,
        timestamp: response.timestamp,
      );
    }
    return ApiResponse<List<WechatArticle>>(
      code: response.code,
      message: response.message,
      data: [],
      timestamp: response.timestamp,
    );
  }
}
