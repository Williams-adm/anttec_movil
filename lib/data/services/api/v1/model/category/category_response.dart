import 'package:anttec_movil/data/services/api/v1/model/category/category_model.dart';
import 'package:anttec_movil/data/services/api/v1/model/paginate/links_model.dart';
import 'package:anttec_movil/data/services/api/v1/model/paginate/meta_model.dart';

class CategoryResponse {
  final bool success;
  final String message;
  final List<CategoryModel> data;
  final LinksModel links;
  final MetaModel meta;

  CategoryResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.links,
    required this.meta,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
      links: LinksModel.fromJson(json['links']),
      meta: MetaModel.fromJson(json['meta']),
    );
  }
}
