import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:anttec_movil/data/services/api/v1/api_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/auth/login/login_request.dart';
import 'package:anttec_movil/data/services/api/v1/model/auth/login/login_response.dart';
import 'package:anttec_movil/data/services/api/v1/model/auth/logout/logout_response.dart';

class AuthService extends ApiService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthService() : super();

  Future<LoginResponse> login(LoginRequest loginRequest) async {
    try {
      // 1. Enviamos petición al servidor
      final response = await dio.post(
        '/auth/login',
        data: loginRequest.toJson(),
      );

      // 2. Convertimos el JSON a objetos
      final loginResponse = LoginResponse.fromJson(response.data);

      // --- 🔍 ZONA DE DEPURACIÓN (MIRA TU CONSOLA) ---
      final List<String> userRoles =
          loginResponse.roles; // Usamos tu lista parseada
      debugPrint("--------------------------------------------------");
      debugPrint("👤 Usuario: ${loginResponse.user.name}");
      debugPrint("🔑 Roles detectados: $userRoles");
      debugPrint("--------------------------------------------------");

      // 3. VALIDACIÓN DE SEGURIDAD
      // Verificamos si tiene "admin" O "employee"
      final bool hasAccess =
          userRoles.contains('admin') || userRoles.contains('employee');

      if (!hasAccess) {
        // Si entra aquí, verás este mensaje NUEVO en la pantalla
        throw Exception(
            'Acceso denegado: Tu usuario no tiene rol de Admin ni Empleado. (Roles: $userRoles)');
      }

      // 4. Guardar credenciales
      if (loginResponse.token.isNotEmpty) {
        await _secureStorage.write(
            key: 'auth_token', value: loginResponse.token);
        await _secureStorage.write(
            key: 'profile_name', value: loginResponse.user.name);
      }

      return loginResponse;
    } on DioException catch (e) {
      // Si el error viene del BACKEND (ej: 401 Unauthorized), lo mostramos
      final msg =
          e.response?.data['message'] ?? 'Error de conexión con el servidor';
      debugPrint("❌ Error del servidor: $msg");
      throw Exception(msg);
    } catch (e) {
      // Si el error es nuestro (Acceso denegado), lo relanzamos
      rethrow;
    }
  }

  Future<LogoutResponse> logout() async {
    try {
      final response = await dio.post('/auth/logout');
      // Ajusta según tu modelo LogoutResponse
      final logoutResponse = LogoutResponse.fromJson(response.data);
      await _secureStorage.deleteAll();
      return logoutResponse;
    } catch (e) {
      // Limpiamos igual por seguridad aunque falle el endpoint
      await _secureStorage.deleteAll();
      throw Exception("Sesión cerrada localmente.");
    }
  }
}
