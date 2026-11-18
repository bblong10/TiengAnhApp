import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // =====================================
  // XỬ LÝ THÔNG BÁO LỖI API
  // =====================================
  String _getErrorMessage(DioException e) {
    final responseData = e.response?.data;

    if (responseData is Map && responseData['message'] != null) {
      final message = responseData['message'];

      if (message is List) {
        return message.join('\n');
      }

      return message.toString();
    }

    return 'Không thể kết nối đến máy chủ. Vui lòng thử lại.';
  }

  // =====================================
  // ĐĂNG NHẬP
  // =====================================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'email': email.trim(), 'password': password},
      );

      final data = Map<String, dynamic>.from(response.data);

      final token = data['accessToken'];

      if (token == null || token.toString().isEmpty) {
        throw Exception('Backend không trả về Access Token');
      }

      await _storage.write(key: 'access_token', value: token.toString());

      return data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // =====================================
  // ĐĂNG KÝ TÀI KHOẢN
  // =====================================
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'fullName': fullName.trim(),
          'email': email.trim(),
          'password': password,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // =====================================
  // QUÊN MẬT KHẨU
  // =====================================
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email.trim()},
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // =====================================
  // ĐẶT LẠI MẬT KHẨU
  // =====================================
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/reset-password',
        data: {'token': token, 'newPassword': newPassword},
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // =====================================
  // LẤY ACCESS TOKEN
  // =====================================
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // =====================================
  // XÁC THỰC ACCESS TOKEN
  // =====================================
  Future<Map<String, dynamic>?> validateToken() async {
    final token = await getAccessToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await _apiClient.dio.get(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await logout();
        return null;
      }

      throw Exception(
        'Không thể xác thực tài khoản. Vui lòng kiểm tra kết nối.',
      );
    }
  }

  // =====================================
  // ĐĂNG XUẤT
  // =====================================
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }
}
