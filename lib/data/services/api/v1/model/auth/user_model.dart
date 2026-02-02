class UserModel {
  final int id;
  final String name;
  final String email;
  final List<String> roles; //  Campo nuevo para guardar los roles

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      //  Convertimos la lista del JSON a una lista de Dart segura
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
    );
  }
}
