class LoginRequest {
  LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  // Método para convertir la instancia en JSON (para enviar al backend)
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
