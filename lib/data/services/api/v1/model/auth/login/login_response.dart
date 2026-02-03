import 'package:anttec_movil/data/services/api/v1/model/auth/user_model.dart';

class LoginResponse {
  final bool success;
  final String message;
  final String token;
  final UserModel user;
  final List<String> roles; // ✅ NUEVO CAMPO

  LoginResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
    required this.roles,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Extraemos los roles de manera segura desde json['user']['roles']
    List<String> parsedRoles = [];
    if (json['user'] != null && json['user']['roles'] != null) {
      parsedRoles = List<String>.from(json['user']['roles']);
    }

    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      user: UserModel.fromJson(json['user']),
      roles: parsedRoles, // ✅ Asignamos los roles
    );
  }
}
