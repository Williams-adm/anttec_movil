import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  final Dio dio = Dio(BaseOptions(
    baseUrl:
        'https://tu-api.com/api', // 👈 ASEGÚRATE DE QUE ESTA URL SEA CORRECTA
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  DioClient() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        const storage = FlutterSecureStorage();
        // LEEMOS EL TOKEN EN CADA PETICIÓN
        final token = await storage.read(key: 'auth_token');

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          // Para debug:
          debugPrint(
              "🔑 Interceptor: Token inyectado (...${token.substring(token.length - 10)})");
        } else {
          debugPrint("🔑 Token en interceptor: Nulo");
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          debugPrint("❌ Error 401: No autorizado");
        }
        return handler.next(e);
      },
    ));
  }
}
