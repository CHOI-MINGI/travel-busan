import 'package:dio/dio.dart';
import '../storage/auth_storage.dart';

class DioClient {
  static const String _laptopIp = '192.168.81.1';
  static const String _baseUrl = 'http://$_laptopIp:8080';

  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      contentType: 'application/json',
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('🚀 [DIO] Request: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        print('❌ [DIO] Error: Status ${e.response?.statusCode}');
        if (e.response?.statusCode == 401) {
          await AuthStorage.deleteToken();
        }
        return handler.next(e);
      },
    ));

    return dio;
  }

  static Dio get instance => _dio;
}