import 'package:anttec_movil/data/services/api/v1/model/login/login_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login({
    required String email,
    required String password,
  });
}
