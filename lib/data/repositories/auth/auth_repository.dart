import 'package:anttec_movil/data/services/api/v1/model/auth/login/login_response.dart';
import 'package:anttec_movil/data/services/api/v1/model/auth/logout/logout_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login({
    required String email,
    required String password,
  });

  Future<LogoutResponse> logout();
}
