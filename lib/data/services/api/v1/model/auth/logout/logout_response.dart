class LogoutResponse {
  final bool success;

  final String message;
  LogoutResponse({required this.success, required this.message});

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(success: json['success'], message: json['message']);
  }
}
