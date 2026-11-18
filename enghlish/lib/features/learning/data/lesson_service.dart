import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class LessonService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> getLessons(String courseId) async {
    try {
      final response = await _apiClient.dio.get('/courses/$courseId/lessons');

      if (response.data is! List) {
        throw Exception('Dữ liệu bài học không hợp lệ.');
      }

      return List<Map<String, dynamic>>.from(
        response.data.map((item) => Map<String, dynamic>.from(item)),
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }

      throw Exception(e.message ?? 'Không thể tải danh sách bài học.');
    }
  }
}
