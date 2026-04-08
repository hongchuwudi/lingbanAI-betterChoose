import '../models/medication_record.dart';
import '../models/api_response.dart';
import '../utils/http_interceptor.dart';

class MedicationService {
  static Future<ApiResponse<List<MedicationRecord>>> getTodayRecords() async {
    final response = await HttpInterceptorManager().interceptor
        .get<List<dynamic>>(path: '/user/medication/today');
    if (response.isSuccess && response.data != null) {
      return ApiResponse<List<MedicationRecord>>(
        code: response.code,
        message: response.message,
        data: response.data!.map((e) => MedicationRecord.fromJson(e)).toList(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      return ApiResponse<List<MedicationRecord>>(
        code: response.code,
        message: response.message,
        data: null,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  static Future<ApiResponse<List<MedicationRecord>>> getRecordsByDate(
    DateTime date,
  ) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await HttpInterceptorManager().interceptor
        .get<List<dynamic>>(path: '/user/medication/date/$dateStr');
    if (response.isSuccess && response.data != null) {
      return ApiResponse<List<MedicationRecord>>(
        code: response.code,
        message: response.message,
        data: response.data!.map((e) => MedicationRecord.fromJson(e)).toList(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      return ApiResponse<List<MedicationRecord>>(
        code: response.code,
        message: response.message,
        data: null,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  static Future<ApiResponse<List<MedicationRecord>>> getElderlyRecordsByDate(
    String elderlyProfileId,
    DateTime date,
  ) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await HttpInterceptorManager().interceptor
        .get<List<dynamic>>(
          path: '/user/medication/elderly/$elderlyProfileId/date/$dateStr',
        );
    if (response.isSuccess && response.data != null) {
      return ApiResponse<List<MedicationRecord>>(
        code: response.code,
        message: response.message,
        data: response.data!.map((e) => MedicationRecord.fromJson(e)).toList(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      return ApiResponse<List<MedicationRecord>>(
        code: response.code,
        message: response.message,
        data: null,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  static Future<ApiResponse<MedicationRecord>> checkIn(String recordId) async {
    final response = await HttpInterceptorManager().interceptor
        .post<Map<String, dynamic>>(
          path: '/user/medication/check-in/$recordId',
          data: {},
        );
    if (response.isSuccess && response.data != null) {
      return ApiResponse<MedicationRecord>(
        code: response.code,
        message: response.message,
        data: MedicationRecord.fromJson(response.data!),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      return ApiResponse<MedicationRecord>(
        code: response.code,
        message: response.message,
        data: null,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  static Future<ApiResponse<MedicationRecord>> checkInByNotification(
    String notificationId,
  ) async {
    final response = await HttpInterceptorManager().interceptor
        .post<Map<String, dynamic>>(
          path: '/user/medication/check-in-by-notification/$notificationId',
          data: {},
        );
    if (response.isSuccess && response.data != null) {
      return ApiResponse<MedicationRecord>(
        code: response.code,
        message: response.message,
        data: MedicationRecord.fromJson(response.data!),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      return ApiResponse<MedicationRecord>(
        code: response.code,
        message: response.message,
        data: null,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  static Future<ApiResponse<String>> remindElderly(
    String elderlyProfileId,
  ) async {
    final response = await HttpInterceptorManager().interceptor.post<String>(
      path: '/user/medication/remind/$elderlyProfileId',
      data: {},
    );
    return ApiResponse<String>(
      code: response.code,
      message: response.message,
      data: response.data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getCheckInStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startStr =
        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endStr =
        '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    final response = await HttpInterceptorManager().interceptor
        .get<Map<String, dynamic>>(
          path: '/user/medication/stats?startDate=$startStr&endDate=$endStr',
        );
    return ApiResponse<Map<String, dynamic>>(
      code: response.code,
      message: response.message,
      data: response.data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
