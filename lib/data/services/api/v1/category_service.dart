import 'package:anttec_movil/data/services/api/v1/api_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/category/category_response.dart';
import 'package:dio/dio.dart';

class CategoryService extends ApiService {
  CategoryService() : super();

  Future<CategoryResponse> categoryAll() async {
    try {
      final response = await dio.get('/admin/categories');

      final categoryResponse = CategoryResponse.fromJson(response.data);

      return categoryResponse;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}
