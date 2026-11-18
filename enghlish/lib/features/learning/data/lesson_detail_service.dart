import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class LessonDetailService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getLessonDetail(String lessonId) async {
    try {
      final response = await _apiClient.dio.get('/lessons/$lessonId');

      if (response.data is! Map) {
        throw Exception('Dữ liệu bài học không hợp lệ.');
      }

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }

      throw Exception(e.message ?? 'Không thể tải nội dung bài học.');
    }
  }
}
