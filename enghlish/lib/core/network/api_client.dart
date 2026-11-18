import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late final Dio dio;

  // Phải dùng cùng key với AuthService.
  static const String tokenKey = 'access_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:3000',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Tự động đính kèm Access Token vào mọi request.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _storage.read(key: tokenKey);

            if (token != null && token.trim().isNotEmpty) {
              options.headers['Authorization'] = 'Bearer ${token.trim()}';
            }

            handler.next(options);
          } catch (e) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: 'Không thể đọc Access Token: $e',
              ),
            );
          }
        },
      ),
    );
  }
}
