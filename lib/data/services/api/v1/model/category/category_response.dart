import 'package:anttec_movil/data/services/api/v1/model/category/category_model.dart';
import 'package:anttec_movil/data/services/api/v1/model/paginate/links_model.dart';
import 'package:anttec_movil/data/services/api/v1/model/paginate/meta_model.dart';

class CategoryResponse {
  final bool success;
  final String message;
  final List<CategoryModel> data;
  final LinksModel? links; // Opcional, para casos donde no venga en el backend
  final MetaModel? meta; // Opcional, para casos donde no venga en el backend

  CategoryResponse({
    required this.success,
    required this.message,
    required this.data,
    this.links,
    this.meta,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
      // Si el backend no envía estos campos, se asigna null
      links: json['links'] != null ? LinksModel.fromJson(json['links']) : null,
      meta: json['meta'] != null ? MetaModel.fromJson(json['meta']) : null,
    );
  }
}
