import 'dart:async';
import 'package:flutter/material.dart';
import 'package:anttec_movil/data/services/api/v1/product_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_response.dart';

class ProductsController extends ChangeNotifier {
  final ProductService api;
  final String token;

  // --- ESTADO DE LA UI ---
  bool loading = true;
  String? error;
  List<Product> products = [];

  // --- PAGINACIÓN ---
  int page = 1;
  int lastPage = 1;

  // --- FILTROS (Estado Privado) ---
  int? _brand;
  int? _category;
  int? _subcategory;
  double? _priceMin;
  double? _priceMax;

  // --- ORDENAMIENTO ---
  String? _orderBy; // Ej: 'price', 'name'
  String? _orderDir; // Ej: 'asc', 'desc'

  // --- BUSCADOR ---
  String? _searchQuery;
  Timer? _debounce;

  // ✅ GETTERS PÚBLICOS (Esto es lo que te faltaba)
  // Permiten que la UI (SectionTitleW) lea qué filtros están aplicados
  int? get currentBrand => _brand;
  int? get currentCategory => _category;
  int? get currentSubcategory => _subcategory;
  double? get currentMinPrice => _priceMin;
  double? get currentMaxPrice => _priceMax;
  String? get currentOrderBy => _orderBy;
  String? get currentOrderDir => _orderDir;

  ProductsController({required this.token}) : api = ProductService() {
    fetchProducts();
  }

  // ==========================================
  //  LÓGICA DEL BUSCADOR
  // ==========================================
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query;
      // Al buscar, forzamos carga directa a página 1
      fetchProducts(newPage: 1);
    });
  }

  void clearSearch() {
    _searchQuery = "";
    fetchProducts(newPage: 1);
  }

  // ==========================================
  //  CARGA DE PRODUCTOS (API)
  // ==========================================
  Future<void> fetchProducts({int newPage = 1}) async {
    loading = true;
    page = newPage;
    notifyListeners();

    try {
      // Llamamos al servicio pasando TODOS los filtros acumulados
      final ProductResponse resp = await api.productAll(
        page: page,
        brand: _brand,
        category: _category,
        subcategory: _subcategory,
        priceMin: _priceMin,
        priceMax: _priceMax,
        // Nota: Asegúrate de que tu ProductService acepte estos parámetros
        // Si no los acepta aún, agrégalos en product_service.dart
        // orderBy: _orderBy,
        // orderDir: _orderDir,
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

  // ==========================================
  //  MÉTODOS DE CONTROL DE FILTROS
  // ==========================================

  // ✅ MÉTODO FALTANTE (applyAdvancedFilters)
  // Recibe todos los datos del Modal y recarga la lista
  void applyAdvancedFilters({
    int? brand,
    int? category,
    int? subcategory,
    double? minPrice,
    double? maxPrice,
    String? orderBy,
    String? orderDir,
  }) {
    _brand = brand;
    _category = category;
    _subcategory = subcategory;
    _priceMin = minPrice;
    _priceMax = maxPrice;
    _orderBy = orderBy;
    _orderDir = orderDir;

    // Reiniciamos a la página 1 al aplicar filtros
    fetchProducts(newPage: 1);
  }

  /// Método para los botones de paginación (1, 2, 3...)
  void changePage(int newPage) {
    if (newPage >= 1 && newPage <= lastPage && newPage != page) {
      fetchProducts(newPage: newPage);
    }
  }

  /// Filtro rápido (si lo usas en otro lado)
  void applyQuickFilter({int? brand, int? category}) {
    if (_brand == brand && _category == category) return;
    _brand = brand;
    _category = category;
    fetchProducts(newPage: 1);
  }

  void clearFilters() {
    _brand = null;
    _category = null;
    _subcategory = null;
    _priceMin = null;
    _priceMax = null;
    _orderBy = null;
    _orderDir = null;

    fetchProducts(newPage: 1);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
