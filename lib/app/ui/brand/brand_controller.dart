import 'package:anttec_movil/data/services/api/v1/model/category/category_model.dart';
import 'package:flutter/material.dart';
import 'package:anttec_movil/data/services/api/v1/brand_service.dart';
import 'package:anttec_movil/data/services/api/v1/category_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/category/category_response.dart';

class BrandController extends ChangeNotifier {
  final BrandService _brandService = BrandService();
  final CategoryService _categoryService = CategoryService();

  List<dynamic> brands = [];
  List<CategoryModel> categories = [];

  bool isLoading = true;
  String? errorMessage;

  Map<int, bool> expandedCategories = {};

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _brandService.getAllBrands(),
        _categoryService.categoryAll(),
      ]);

      brands = results[0] as List<dynamic>;
      final categoryResponse = results[1] as CategoryResponse;

      // CORRECCIÓN: 'data' ya es una lista obligatoria, no necesitamos '?? []'
      categories = categoryResponse.data;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleCategory(int categoryId) {
    final isExpanded = expandedCategories[categoryId] ?? false;
    expandedCategories[categoryId] = !isExpanded;
    notifyListeners();
  }
}
