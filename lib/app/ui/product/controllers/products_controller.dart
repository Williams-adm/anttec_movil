import 'dart:async'; // ✅ Necesario para el Timer
import 'package:flutter/material.dart';
import 'package:anttec_movil/data/services/api/v1/product_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_response.dart';

class ProductsController extends ChangeNotifier {
  final ProductService api;
  final String token;

  // Estado de la UI
  bool loading = true;
  String? error;
  List<Product> products = [];

  // Paginación
  int page = 1;
  int lastPage = 1;

  // Variables privadas para filtros
  int? _brand;
  int? _category;
  int? _subcategory;
  double? _priceMin;
  double? _priceMax;

  // ✅ VARIABLES PARA EL BUSCADOR
  String? _searchQuery;
  Timer? _debounce;

  ProductsController({required this.token}) : api = ProductService() {
    fetchProducts();
  }

  // --- LÓGICA DE BÚSQUEDA (Con Debounce) ---

  /// Se llama cada vez que el usuario escribe una letra en SearchW
  void onSearchChanged(String query) {
    // Si el usuario sigue escribiendo, cancelamos el timer anterior
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Esperamos 500ms a que termine de escribir antes de llamar a la API
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query;
      // Al buscar, siempre reseteamos a la página 1
      page = 1;
      fetchProducts(newPage: 1);
    });
  }

  /// Limpia la búsqueda manualmente (botón X)
  void clearSearch() {
    _searchQuery = "";
    page = 1;
    fetchProducts(newPage: 1);
  }

  // ------------------------------------------

  /// Método principal para obtener productos
  Future<void> fetchProducts({int? newPage}) async {
    final int pageTarget = newPage ?? page;

    if (pageTarget == 1) {
      loading = true;
      notifyListeners();
    }

    try {
      // ✅ Enviamos el parámetro 'search' junto con los filtros
      final ProductResponse resp = await api.productAll(
        page: pageTarget,
        brand: _brand,
        category: _category,
        subcategory: _subcategory,
        priceMin: _priceMin,
        priceMax: _priceMax,
        search: _searchQuery, // ✅ AQUÍ SE ENVÍA LA BÚSQUEDA
      );

      if (pageTarget == 1) {
        // Filtro nuevo o búsqueda nueva: Reemplazamos lista
        products = resp.data;
      } else {
        // Scroll infinito: Agregamos al final
        products.addAll(resp.data);
      }

      page = pageTarget;
      lastPage = resp.meta?.lastPage ?? 1;
      error = null;
    } catch (e) {
      error = e.toString();
      if (pageTarget == 1) {
        products = [];
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Recibe los filtros desde la UI
  void applyFilters({
    int? brand,
    int? category,
    int? subcategory,
    double? minPrice,
    double? maxPrice,
  }) {
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

    page = 1;
    fetchProducts(newPage: 1);
  }

  /// Limpia todos los filtros (incluyendo búsqueda si lo deseas, o solo filtros)
  void clearFilters() {
    _brand = null;
    _category = null;
    _subcategory = null;
    _priceMin = null;
    _priceMax = null;
    // _searchQuery = null; // Opcional: ¿Quieres borrar la búsqueda también?

    page = 1;
    fetchProducts(newPage: 1);
  }

  void nextPage() {
    if (page < lastPage && !loading) {
      fetchProducts(newPage: page + 1);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Limpiamos el timer al salir
    super.dispose();
  }
}
