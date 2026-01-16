import 'package:flutter/material.dart';
import 'package:anttec_movil/data/services/api/v1/product_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_detail_response.dart';

class VariantController extends ChangeNotifier {
  final ProductService _api = ProductService();

  bool loading = true;
  String? error;
  ProductDetailData? product;

  // Variable interna para evitar errores si el widget se destruye mientras carga
  bool _isDisposed = false;

  // Constructor
  VariantController({required int productId, int variantId = 1}) {
    fetchProductDetail(productId, variantId);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> fetchProductDetail(int productId, int variantId) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _api.productDetail(
        productId: productId,
        variantId: variantId,
      );
      product = response.data;
    } catch (e) {
      error = "Error al cargar el producto: ${e.toString()}";
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Método para cambiar de variante (ej: al hacer click en otro color)
  void changeVariant(int newVariantId) {
    if (product != null) {
      // Usamos el ID del producto que ya tenemos cargado
      fetchProductDetail(product!.id, newVariantId);
    }
  }
}
