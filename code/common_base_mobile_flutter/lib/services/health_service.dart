import '../models/api_response.dart';
import '../models/parsed_health_indicator.dart';
import '../models/health_video.dart';
import '../utils/http_interceptor.dart';

class HealthService {
  static Future<ApiResponse<Map<String, dynamic>>> getDashboard() async {
    final response = await HttpInterceptorManager()
        .interceptor
        .get<Map<String, dynamic>>(path: '/health/dashboard');

    return response;
  }

  static Future<ApiResponse<Map<String, dynamic>>> getChildElderlyDashboard(
    String elderlyProfileId,
  ) async {
    final response =
        await HttpInterceptorManager().interceptor.get<Map<String, dynamic>>(
      path: '/health/child/elderly-dashboard',
      queryParameters: {'elderlyProfileId': elderlyProfileId},
    );

    return response;
  }

  static Future<ApiResponse<List<dynamic>>> getAlerts({int status = 0}) async {
    final response =
        await HttpInterceptorManager().interceptor.get<List<dynamic>>(
      path: '/health/alerts',
      queryParameters: {'status': status},
    );

    return response;
  }

  static Future<ApiResponse<List<dynamic>>> getMedicationToday() async {
    final response = await HttpInterceptorManager()
        .interceptor
        .get<List<dynamic>>(path: '/user/medication/today');

    return response;
  }

  static Future<ApiResponse<Map<String, dynamic>>> recordMedication(
    int recordId,
  ) async {
    final response =
        await HttpInterceptorManager().interceptor.post<Map<String, dynamic>>(
      path: '/user/medication/check-in/$recordId',
      data: {},
    );

    return response;
  }

  static Future<ApiResponse<String>> saveHealthRecord(
    Map<String, dynamic> data,
  ) async {
    final response = await HttpInterceptorManager().interceptor.post<String>(
      path: '/health/record',
      data: data,
      headers: {'Content-Type': 'application/json'},
    );

    return response;
  }

  static Future<ApiResponse<List<dynamic>>> getTrend(
    String indicatorCode, {
    int days = 7,
  }) async {
    final response =
        await HttpInterceptorManager().interceptor.get<List<dynamic>>(
      path: '/health/trend',
      queryParameters: {'indicatorCode': indicatorCode, 'days': days},
    );

    return response;
  }

  static Future<ApiResponse<HealthParseResponse>> uploadHealthDocument({
    required String filePath,
    required String fileName,
  }) async {
    final response = await HttpInterceptorManager()
        .interceptor
        .uploadMultipart<Map<String, dynamic>>(
          path: '/ai/parse-health-document',
          filePath: filePath,
          fileName: fileName,
          fieldName: 'file',
        );

    if (response.isSuccess && response.data != null) {
      return ApiResponse<HealthParseResponse>(
        code: response.code,
        message: response.message,
        data: HealthParseResponse.fromJson(response.data!),
        timestamp: response.timestamp,
      );
    }

    return ApiResponse<HealthParseResponse>(
      code: response.code,
      message: response.message,
      data: null,
      timestamp: response.timestamp,
    );
  }

  static Future<ApiResponse<HealthParseResponse>> uploadHealthDocumentBytes({
    required List<int> bytes,
    required String fileName,
  }) async {
    final response = await HttpInterceptorManager()
        .interceptor
        .uploadMultipartBytes<Map<String, dynamic>>(
          path: '/ai/parse-health-document',
          bytes: bytes,
          fileName: fileName,
          fieldName: 'file',
        );

    if (response.isSuccess && response.data != null) {
      return ApiResponse<HealthParseResponse>(
        code: response.code,
        message: response.message,
        data: HealthParseResponse.fromJson(response.data!),
        timestamp: response.timestamp,
      );
    }

    return ApiResponse<HealthParseResponse>(
      code: response.code,
      message: response.message,
      data: null,
      timestamp: response.timestamp,
    );
  }

  static Future<ApiResponse<HealthParseRecord>> getParseRecord(
    int recordId,
  ) async {
    final response = await HttpInterceptorManager()
        .interceptor
        .get<Map<String, dynamic>>(path: '/ai/parse-record/$recordId');

    if (response.isSuccess && response.data != null) {
      return ApiResponse<HealthParseRecord>(
        code: response.code,
        message: response.message,
        data: HealthParseRecord.fromJson(response.data!),
        timestamp: response.timestamp,
      );
    }

    return ApiResponse<HealthParseRecord>(
      code: response.code,
      message: response.message,
      data: null,
      timestamp: response.timestamp,
    );
  }

  static Future<ApiResponse<List<ParsedHealthIndicator>>> parseHealthDocument({
    required String filePath,
    required String fileName,
  }) async {
    final response = await HttpInterceptorManager()
        .interceptor
        .uploadMultipart<List<dynamic>>(
          path: '/ai/parse-health-document',
          filePath: filePath,
          fileName: fileName,
          fieldName: 'file',
          receiveTimeout: const Duration(seconds: 60),
        );

    if (response.isSuccess && response.data != null) {
      final indicators = ParsedHealthIndicator.fromJsonList(response.data!);
      return ApiResponse<List<ParsedHealthIndicator>>(
        code: response.code,
        message: response.message,
        data: indicators,
        timestamp: response.timestamp,
      );
    }

    return ApiResponse<List<ParsedHealthIndicator>>(
      code: response.code,
      message: response.message,
      data: null,
      timestamp: response.timestamp,
    );
  }

  static Future<ApiResponse<List<ParsedHealthIndicator>>>
      parseHealthDocumentBytes({
    required List<int> bytes,
    required String fileName,
  }) async {
    final response = await HttpInterceptorManager()
        .interceptor
        .uploadMultipartBytes<List<dynamic>>(
          path: '/ai/parse-health-document',
          bytes: bytes,
          fileName: fileName,
          fieldName: 'file',
          receiveTimeout: const Duration(seconds: 60),
        );

    if (response.isSuccess && response.data != null) {
      final indicators = ParsedHealthIndicator.fromJsonList(response.data!);
      return ApiResponse<List<ParsedHealthIndicator>>(
        code: response.code,
        message: response.message,
        data: indicators,
        timestamp: response.timestamp,
      );
    }

    return ApiResponse<List<ParsedHealthIndicator>>(
      code: response.code,
      message: response.message,
      data: null,
      timestamp: response.timestamp,
    );
  }

  static Future<ApiResponse<HealthAnalysisResponse>> analyzeHealth(
    int parseRecordId,
  ) async {
    final response =
        await HttpInterceptorManager().interceptor.post<Map<String, dynamic>>(
              path: '/ai/analyze-health/$parseRecordId',
              data: {},
              connectTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 60),
            );

    if (response.isSuccess && response.data != null) {
      return ApiResponse<HealthAnalysisResponse>(
        code: response.code,
        message: response.message,
        data: HealthAnalysisResponse.fromJson(response.data!),
        timestamp: response.timestamp,
      );
    }

    return ApiResponse<HealthAnalysisResponse>(
      code: response.code,
      message: response.message,
      data: null,
      timestamp: response.timestamp,
    );
  }

  static Future<ApiResponse<HealthAnalysisResponse>> getAnalysisRecord(
    int analysisId,
  ) async {
    final response = await HttpInterceptorManager()
        .interceptor
        .get<Map<String, dynamic>>(path: '/ai/analysis-record/$analysisId');

    if (response.isSuccess && response.data != null) {
      return ApiResponse<HealthAnalysisResponse>(
        code: response.code,
        message: response.message,
        data: HealthAnalysisResponse.fromJson(response.data!),
        timestamp: response.timestamp,
      );
    }

    return ApiResponse<HealthAnalysisResponse>(
      code: response.code,
      message: response.message,
      data: null,
      timestamp: response.timestamp,
    );
  }

  static Future<ApiResponse<List<HealthParseRecord>>> getParseRecordList({
    int page = 1,
    int size = 10,
  }) async {
    final response =
        await HttpInterceptorManager().interceptor.get<Map<String, dynamic>>(
      path: '/ai/parse-record-list',
      queryParameters: {'page': page, 'size': size},
    );

    if (response.isSuccess && response.data != null) {
      final records = (response.data!['records'] as List<dynamic>?)
              ?.map(
                (json) =>
                    HealthParseRecord.fromJson(json as Map<String, dynamic>),
              )
              .toList() ??
          [];
      return ApiResponse<List<HealthParseRecord>>(
        code: response.code,
        message: response.message,
        data: records,
        timestamp: response.timestamp,
      );
    }

    return ApiResponse<List<HealthParseRecord>>(
      code: response.code,
      message: response.message,
      data: [],
      timestamp: response.timestamp,
    );
  }

  static Future<ApiResponse<List<HealthAnalysisResponse>>>
      getAnalysisRecordList({int page = 1, int size = 10}) async {
    final response =
        await HttpInterceptorManager().interceptor.get<Map<String, dynamic>>(
      path: '/ai/analysis-record-list',
      queryParameters: {'page': page, 'size': size},
    );

    if (response.isSuccess && response.data != null) {
      final records = (response.data!['records'] as List<dynamic>?)
              ?.map(
                (json) => HealthAnalysisResponse.fromJson(
                  json as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [];
      return ApiResponse<List<HealthAnalysisResponse>>(
        code: response.code,
        message: response.message,
        data: records,
        timestamp: response.timestamp,
      );
    }

    return ApiResponse<List<HealthAnalysisResponse>>(
      code: response.code,
      message: response.message,
      data: [],
      timestamp: response.timestamp,
    );
  }

  static Future<ApiResponse<HealthAnalysisResponse>> getAnalysisByParseRecordId(
    int parseRecordId,
  ) async {
    final response =
        await HttpInterceptorManager().interceptor.get<Map<String, dynamic>>(
              path: '/ai/analysis-by-parse/$parseRecordId',
            );

    if (response.isSuccess && response.data != null) {
      return ApiResponse<HealthAnalysisResponse>(
        code: response.code,
        message: response.message,
        data: HealthAnalysisResponse.fromJson(response.data!),
        timestamp: response.timestamp,
      );
    }

    return ApiResponse<HealthAnalysisResponse>(
      code: response.code,
      message: response.message,
      data: null,
      timestamp: response.timestamp,
    );
  }
}

class HealthParseResponse {
  final int recordId;
  final String status;
  final String? fileUrl;
  final String? fileName;
  final String? createdAt;

  HealthParseResponse({
    required this.recordId,
    required this.status,
    this.fileUrl,
    this.fileName,
    this.createdAt,
  });

  factory HealthParseResponse.fromJson(Map<String, dynamic> json) {
    return HealthParseResponse(
      recordId: json['recordId'] ?? 0,
      status: json['status'] ?? '',
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      createdAt: json['createdAt'],
    );
  }
}

class HealthParseRecord {
  final int id;
  final int userId;
  final String fileName;
  final String? fileUrl;
  final String? contentType;
  final int? fileSize;
  final String status;
  final int? indicatorCount;
  final String? errorMessage;
  final String? parseStartTime;
  final String? parseEndTime;
  final String? createdAt;
  final String? updatedAt;

  HealthParseRecord({
    required this.id,
    required this.userId,
    required this.fileName,
    this.fileUrl,
    this.contentType,
    this.fileSize,
    required this.status,
    this.indicatorCount,
    this.errorMessage,
    this.parseStartTime,
    this.parseEndTime,
    this.createdAt,
    this.updatedAt,
  });

  factory HealthParseRecord.fromJson(Map<String, dynamic> json) {
    return HealthParseRecord(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'],
      contentType: json['contentType'],
      fileSize: json['fileSize'],
      status: json['status'] ?? '',
      indicatorCount: json['indicatorCount'],
      errorMessage: json['errorMessage'],
      parseStartTime: json['parseStartTime'],
      parseEndTime: json['parseEndTime'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class HealthAnalysisResponse {
  final int analysisId;
  final int? parseRecordId;
  final String status;
  final String? healthConclusion;
  final String? medicationRecommendation;
  final String? currentStatus;
  final String? improvementPoints;
  final String? recheckReminders;
  final String? suggestedIndicators;
  final String? createdAt;

  HealthAnalysisResponse({
    required this.analysisId,
    this.parseRecordId,
    required this.status,
    this.healthConclusion,
    this.medicationRecommendation,
    this.currentStatus,
    this.improvementPoints,
    this.recheckReminders,
    this.suggestedIndicators,
    this.createdAt,
  });

  factory HealthAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return HealthAnalysisResponse(
      analysisId: json['analysisId'] ?? json['id'] ?? 0,
      parseRecordId: json['parseRecordId'],
      status: json['status'] ?? '',
      healthConclusion: json['healthConclusion'],
      medicationRecommendation: json['medicationRecommendation'],
      currentStatus: json['currentStatus'],
      improvementPoints: json['improvementPoints'],
      recheckReminders: json['recheckReminders'],
      suggestedIndicators: json['suggestedIndicators'],
      createdAt: json['createdAt'],
    );
  }
}

class HealthVideoService {
  static Future<ApiResponse<List<HealthVideo>>> getVideoList({
    int page = 1,
    int size = 10,
  }) async {
    final response = await HttpInterceptorManager()
        .interceptor
        .get<List<dynamic>>(path: '/health-video/list?page=$page&size=$size');

    if (response.isSuccess && response.data != null) {
      final videos = response.data!
          .map((json) => HealthVideo.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse<List<HealthVideo>>(
        code: response.code,
        message: response.message,
        data: videos,
        timestamp: response.timestamp,
      );
    }

    return ApiResponse<List<HealthVideo>>(
      code: response.code,
      message: response.message,
      data: [],
      timestamp: response.timestamp,
    );
  }

  static Future<ApiResponse<HealthVideo>> getVideoById(int id) async {
    final response = await HttpInterceptorManager()
        .interceptor
        .get<Map<String, dynamic>>(path: '/health-video/$id');

    if (response.isSuccess && response.data != null) {
      return ApiResponse<HealthVideo>(
        code: response.code,
        message: response.message,
        data: HealthVideo.fromJson(response.data!),
        timestamp: response.timestamp,
      );
    }

    return ApiResponse<HealthVideo>(
      code: response.code,
      message: response.message,
      data: null,
      timestamp: response.timestamp,
    );
  }
}
