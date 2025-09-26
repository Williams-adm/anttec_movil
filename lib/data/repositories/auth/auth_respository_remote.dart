import 'package:anttec_movil/data/repositories/auth/auth_repository.dart';
import 'package:anttec_movil/data/services/api/v1/auth_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/auth/login/login_request.dart';
import 'package:anttec_movil/data/services/api/v1/model/auth/login/login_response.dart';
import 'package:anttec_movil/data/services/api/v1/model/auth/logout/logout_response.dart';

class AuthRespositoryRemote extends AuthRepository {
  final AuthService _authService;

  AuthRespositoryRemote({required AuthService authService})
    : _authService = authService;

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    return await _authService.login(
      LoginRequest(email: email, password: password),
    );
  }

  @override
  Future<LogoutResponse> logout() async {
    return await _authService.logout();
  }
}
