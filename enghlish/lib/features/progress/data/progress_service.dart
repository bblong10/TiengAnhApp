import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class ProgressService {
  final ApiClient _apiClient = ApiClient();

  // LẤY TỔNG QUAN TIẾN ĐỘ
  Future<Map<String, dynamic>> getOverview() async {
    try {
      final response = await _apiClient.dio.get('/progress');

      if (response.data is! Map) {
        throw Exception('Dữ liệu tiến độ không hợp lệ.');
      }

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }

      throw Exception(e.message ?? 'Không thể tải tiến độ học tập.');
    }
  }

  // KIỂM TRA TRẠNG THÁI BÀI HỌC
  Future<Map<String, dynamic>> getLessonProgress(String lessonId) async {
    try {
      final response = await _apiClient.dio.get('/progress/lessons/$lessonId');

      if (response.data is! Map) {
        throw Exception('Dữ liệu trạng thái bài học không hợp lệ.');
      }

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }

      throw Exception(e.message ?? 'Không thể kiểm tra tiến độ bài học.');
    }
  }

  // ĐÁNH DẤU HOÀN THÀNH BÀI HỌC
  Future<Map<String, dynamic>> completeLesson(String lessonId) async {
    try {
      final response = await _apiClient.dio.post(
        '/progress/lessons/$lessonId/complete',
      );

      if (response.data is! Map) {
        throw Exception('Dữ liệu hoàn thành bài học không hợp lệ.');
      }

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }

      throw Exception(e.message ?? 'Không thể lưu tiến độ bài học.');
    }
  }
}
