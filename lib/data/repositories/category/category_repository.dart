import 'package:anttec_movil/data/services/api/v1/model/category/category_response.dart';

abstract class CategoryRepository {
  Future<CategoryResponse> categoryAll();
}
