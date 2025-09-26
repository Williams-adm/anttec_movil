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
      final response = await dio.post(
        '/auth/login',
        data: loginRequest.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(response.data);

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
      throw Exception(e.error);
    }
  }

  Future<LogoutResponse> logout() async {
    try {
      final response = await dio.post('/auth/logout');

      final logoutResponse = LogoutResponse.fromJson(response.data);

      await _secureStorage.deleteAll();

      return logoutResponse;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}
