import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService({String? baseUrl})
    : dio = Dio(
        BaseOptions(
          baseUrl: 'http://192.168.1.4/anttec-back/public/api/v1',
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (RequestOptions options, RequestInterceptorHandler handler) async {
              if (!options.path.contains('/auth/login')) {
                final token = await _secureStorage.read(key: 'auth_token');
                if (token != null) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
              }
              return handler.next(options);
            },
        onError: (DioException error, ErrorInterceptorHandler handler) {
          final message = handleDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: message,
              type: error.type,
              response: error.response,
            ),
          );
        },
      ),
    );
  }

  String handleDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      try {
        final data = e.response?.data;

        // Si data es un Map (es decir, JSON decodificado)
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return data['message'];
        }

        return 'Error del servidor';
      } catch (_) {
        return 'Error al procesar la respuesta del servidor';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Tiempo de conexión agotado';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de respuesta agotado';
    } else {
      return 'Error de red';
    }
  }
}
