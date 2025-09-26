import 'package:anttec_movil/data/repositories/category/category_repository.dart';
import 'package:anttec_movil/data/services/api/v1/category_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/category/category_response.dart';

class CategoryRepositoryRemote extends CategoryRepository {
  final CategoryService _categoryService;

  CategoryRepositoryRemote({required CategoryService categoryService})
    : _categoryService = categoryService;

  @override
  Future<CategoryResponse> categoryAll() async {
    return await _categoryService.categoryAll();
  }
}
