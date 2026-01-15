import 'package:flutter/material.dart';
import 'package:anttec_movil/data/services/api/v1/product_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_response.dart';

class ProductsController extends ChangeNotifier {
  final ProductService api;
  final String token;

  bool loading = true;
  String? error;
  List<Product> products = [];

  // Paginación
  int page = 1;
  int lastPage = 1;

  // Variables privadas para mantener el estado de los filtros
  int? _brand;
  double? _priceMin;
  double? _priceMax;
  int? _category;
  int? _subcategory;

  ProductsController({required this.token}) : api = ProductService() {
    fetchProducts();
  }

  /// Método principal para obtener productos
  Future<void> fetchProducts({int? newPage}) async {
    loading = true;
    error = null;
    notifyListeners();

    final int pageTarget = newPage ?? page;

    try {
      final ProductResponse resp = await api.productAll(
        page: pageTarget,
        brand: _brand,
        priceMin: _priceMin,
        priceMax: _priceMax,
        category: _category,
        subcategory: _subcategory,
      );

      products = resp.data;
      page = pageTarget;

      // Ahora esto funcionará porque 'meta' ya no es un Map, es una clase Meta
      lastPage = resp.meta?.lastPage ?? 1;

      error = null;
    } catch (e) {
      error = e.toString();
      products = [];
    }

    loading = false;
    notifyListeners();
  }

  /// Aplicar filtros desde la UI
  void applyFilters({
    int? brand,
    double? minPrice,
    double? maxPrice,
    int? category,
    int? subcategory,
  }) {
    _brand = brand;
    _priceMin = minPrice;
    _priceMax = maxPrice;
    _category = category;
    _subcategory = subcategory;

    page = 1; // Reiniciar paginación al filtrar
    fetchProducts(newPage: 1);
  }

  /// Limpiar filtros
  void clearFilters() {
    _brand = null;
    _priceMin = null;
    _priceMax = null;
    _category = null;
    _subcategory = null;

    page = 1;
    fetchProducts(newPage: 1);
  }

  /// Ir a página siguiente
  void nextPage() {
    if (page < lastPage) {
      fetchProducts(newPage: page + 1);
    }
  }

  /// Ir a página anterior
  void previousPage() {
    if (page > 1) {
      fetchProducts(newPage: page - 1);
    }
  }
}
