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

  // Variables privadas para filtros (Persisten mientras navegas páginas)
  int? _brand;
  int? _category;
  int? _subcategory;
  double? _priceMin;
  double? _priceMax;

  ProductsController({required this.token}) : api = ProductService() {
    fetchProducts();
  }

  /// Método principal para obtener productos
  Future<void> fetchProducts({int? newPage}) async {
    final int pageTarget = newPage ?? page;

    // Solo mostramos loading global si es la primera página (o un filtro nuevo)
    // Para scroll infinito, no queremos bloquear toda la pantalla.
    if (pageTarget == 1) {
      loading = true;
      notifyListeners();
    }

    try {
      // Llamada a la API enviando todos los filtros actuales
      final ProductResponse resp = await api.productAll(
        page: pageTarget,
        brand: _brand,
        category: _category,
        subcategory: _subcategory,
        priceMin: _priceMin,
        priceMax: _priceMax,
      );

      // 🔥 LÓGICA CRÍTICA PARA SCROLL VS FILTRO 🔥
      if (pageTarget == 1) {
        // Si es página 1, es un filtro nuevo o recarga: BORRAMOS lo anterior
        products = resp.data;
      } else {
        // Si es página > 1, es scroll: AGREGAMOS al final
        products.addAll(resp.data);
      }

      // Actualizamos paginación
      page = pageTarget;
      lastPage = resp.meta?.lastPage ?? 1;
      error = null;
    } catch (e) {
      error = e.toString();
      // Si falló la carga inicial, dejamos la lista vacía.
      // Si falló el scroll, mantenemos los productos que ya teníamos.
      if (pageTarget == 1) {
        products = [];
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Recibe los filtros desde la UI (CategoryFilterW) y recarga
  void applyFilters({
    int? brand,
    int? category,
    int? subcategory,
    double? minPrice,
    double? maxPrice,
  }) {
    // Verificamos si realmente cambió algo para no recargar en vano
    if (_brand == brand &&
        _category == category &&
        _subcategory == subcategory &&
        _priceMin == minPrice &&
        _priceMax == maxPrice) {
      return;
    }

    // Actualizamos las variables privadas
    _brand = brand;
    _category = category;
    _subcategory = subcategory;
    _priceMin = minPrice;
    _priceMax = maxPrice;

    // Reiniciamos a la página 1 siempre que se filtra
    page = 1;
    fetchProducts(newPage: 1);
  }

  /// Limpia todos los filtros y vuelve al estado inicial
  void clearFilters() {
    _brand = null;
    _category = null;
    _subcategory = null;
    _priceMin = null;
    _priceMax = null;

    page = 1;
    fetchProducts(newPage: 1);
  }

  /// Carga la siguiente página (Scroll Infinito)
  void nextPage() {
    // Solo cargamos si no estamos en la última página Y no estamos cargando ya
    if (page < lastPage && !loading) {
      fetchProducts(newPage: page + 1);
    }
  }
}
