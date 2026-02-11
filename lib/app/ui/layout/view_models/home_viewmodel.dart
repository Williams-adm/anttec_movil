import 'dart:async';
import 'package:flutter/material.dart';
import 'package:anttec_movil/data/services/api/v1/product_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_response.dart';

class HomeViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  bool _isLoading = false;
  Timer? _debounce; // ✅ Timer para el buscador

  // ❌ Se eliminó _currentSearch porque no se estaba usando

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  // --- LÓGICA DEL BUSCADOR ---
  void onSearchChanged(String query) {
    // Si el usuario sigue escribiendo, cancelamos el timer anterior
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Esperamos 500ms (medio segundo) a que termine de escribir
    _debounce = Timer(const Duration(milliseconds: 500), () {
      loadProducts(search: query);
    });
  }

  // --- CARGA DE PRODUCTOS ---
  Future<void> loadProducts({String? search}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Llamamos al servicio con el parámetro search
      final response = await _productService.productAll(search: search);

      _products = response.data; // Actualizamos la lista
    } catch (e) {
      debugPrint("❌ Error cargando productos: $e");
      _products = []; // Limpiamos si hay error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para limpiar búsqueda manualmente
  void clearSearch() {
    loadProducts(search: "");
  }
}
