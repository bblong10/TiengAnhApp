import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class CourseService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await _apiClient.dio.get('/courses');

      final data = response.data;

      if (data is! List) {
        throw Exception('Dữ liệu khóa học không hợp lệ.');
      }

      return data.map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']
          : null;

      if (message is String) {
        throw Exception(message);
      }

      throw Exception(
        e.response == null
            ? 'Không thể kết nối máy chủ. Hãy kiểm tra Backend.'
            : 'Không thể tải danh sách khóa học.',
      );
    }
  }
}
