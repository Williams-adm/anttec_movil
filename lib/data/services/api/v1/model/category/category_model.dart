class CategoryModel {
  final int id;
  final String name;
  final bool status;

  CategoryModel({required this.id, required this.name, required this.status});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // Si el backend no envía "status", asigna true por defecto
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      status: json['status'] ?? true, // Aquí está la corrección
    );
  }
}
