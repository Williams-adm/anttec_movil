import 'package:anttec_movil/data/services/api/v1/api_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/auth/login/login_request.dart';
import 'package:anttec_movil/data/services/api/v1/model/auth/login/login_response.dart';
import 'package:anttec_movil/data/services/api/v1/model/auth/logout/logout_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

      // 2. Convertimos el JSON a objetos (Aquí se llena UserModel con los roles)
      final loginResponse = LoginResponse.fromJson(response.data);

      //  3. VALIDACIÓN DE SEGURIDAD (EL CANDADO)
      // Verificamos si la lista de roles contiene "admin"
      if (!loginResponse.user.roles.contains('admin')) {
        //  Si NO es admin, lanzamos error y cortamos el flujo aquí.
        // El token NO se guardará.
        throw Exception(
            'Acceso denegado: Se requieren permisos de Administrador.');
      }

      //  4. Si es admin, procedemos a guardar las credenciales
      if (loginResponse.token.isNotEmpty) {
        await _secureStorage.write(
          key: 'auth_token',
          value: loginResponse.token,
        );

        await _secureStorage.write(
          key: 'profile_name',
          value: loginResponse.user.name,
        );
      }

      return loginResponse;
    } on DioException catch (e) {
      // Errores de red o credenciales incorrectas desde el servidor
      throw Exception(e.response?.data['message'] ?? 'Error de conexión');
    } catch (e) {
      // Capturamos nuestro error de "Acceso denegado" para mostrarlo en pantalla
      rethrow;
    }
  }

  Future<LogoutResponse> logout() async {
    try {
      final response = await dio.post('/auth/logout');
      final logoutResponse = LogoutResponse.fromJson(response.data);

      // Borramos todo al salir
      await _secureStorage.deleteAll();

      return logoutResponse;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}
