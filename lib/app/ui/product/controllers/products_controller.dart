import 'dart:async';
import 'package:flutter/material.dart';
import 'package:anttec_movil/data/services/api/v1/product_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_response.dart';

class ProductsController extends ChangeNotifier {
  final ProductService api;
  final String token;

  bool loading = true;
  String? error;
  List<Product> products = [];

  int page = 1;
  int lastPage = 1;

  // Filtros
  int? _brand;
  int? _category;
  int? _subcategory;
  double? _priceMin;
  double? _priceMax;

  // Buscador
  String? _searchQuery;
  Timer? _debounce;

  ProductsController({required this.token}) : api = ProductService() {
    fetchProducts();
  }

  // ==========================================
  //  CORRECCIÓN EN EL BUSCADOR
  // ==========================================
  void onSearchChanged(String query) {
    // ✅ CORREGIDO: Se agregaron llaves {}
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query;
      // Forzamos la carga directa a la página 1
      fetchProducts(newPage: 1);
    });
  }

  void clearSearch() {
    _searchQuery = "";
    fetchProducts(newPage: 1);
  }

  // ==========================================
  //  CARGA Y PAGINACIÓN
  // ==========================================
  Future<void> fetchProducts({int newPage = 1}) async {
    loading = true;
    page = newPage;
    notifyListeners();

    try {
      final ProductResponse resp = await api.productAll(
        page: page,
        brand: _brand,
        category: _category,
        subcategory: _subcategory,
        priceMin: _priceMin,
        priceMax: _priceMax,
        search: _searchQuery,
      );

      products = resp.data;
      lastPage = resp.meta?.lastPage ?? 1;
      error = null;
    } catch (e) {
      error = e.toString();
      products = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Método para los botones de abajo (1, 2, 3...)
  void changePage(int newPage) {
    if (newPage >= 1 && newPage <= lastPage && newPage != page) {
      fetchProducts(newPage: newPage);
    }
  }

  // Filtros
  void applyFilters({
    int? brand,
    int? category,
    int? subcategory,
    double? minPrice,
    double? maxPrice,
  }) {
    // ✅ CORREGIDO: Se agregaron llaves {} al if de validación
    if (_brand == brand &&
        _category == category &&
        _subcategory == subcategory &&
        _priceMin == minPrice &&
        _priceMax == maxPrice) {
      return;
    }

    _brand = brand;
    _category = category;
    _subcategory = subcategory;
    _priceMin = minPrice;
    _priceMax = maxPrice;

    // Al filtrar, forzamos la carga directa
    fetchProducts(newPage: 1);
  }

  void clearFilters() {
    _brand = null;
    _category = null;
    _subcategory = null;
    _priceMin = null;
    _priceMax = null;
    fetchProducts(newPage: 1);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
