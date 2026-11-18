import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class QuizService {
  final Dio _dio = ApiClient().dio;

  /// Lấy danh sách câu hỏi của một bài học
  Future<List<Map<String, dynamic>>> getQuestions(String lessonId) async {
    try {
      final response = await _dio.get('/quiz/lessons/$lessonId/questions');

      final data = response.data;

      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }

      if (data is Map && data['questions'] is List) {
        return (data['questions'] as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is Map
            ? e.response?.data['message']?.toString() ??
                  'Không thể tải câu hỏi.'
            : 'Không thể kết nối đến máy chủ.',
      );
    }
  }

  /// Nộp bài kiểm tra và lưu kết quả
  Future<Map<String, dynamic>> submitQuiz(
    String lessonId,
    List<Map<String, dynamic>> answers,
  ) async {
    try {
      final response = await _dio.post(
        '/quiz/lessons/$lessonId/submit',
        data: {'answers': answers},
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is Map
            ? e.response?.data['message']?.toString() ??
                  'Không thể nộp bài kiểm tra.'
            : 'Không thể kết nối đến máy chủ.',
      );
    }
  }

  /// Lấy lịch sử làm bài
  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final response = await _dio.get('/quiz/history');

      final data = response.data;

      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }

      if (data is Map && data['history'] is List) {
        return (data['history'] as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is Map
            ? e.response?.data['message']?.toString() ??
                  'Không thể tải lịch sử làm bài.'
            : 'Không thể kết nối đến máy chủ.',
      );
    }
  }
}
