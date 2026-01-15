import 'package:flutter/material.dart';
import 'package:anttec_movil/data/services/api/v1/product_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_detail_response.dart';

class VariantController extends ChangeNotifier {
  final ProductService _api = ProductService();

  bool loading = true;
  String? error;
  ProductDetailData? product;

  // Constructor
  VariantController({required int productId, int variantId = 1}) {
    fetchProductDetail(productId, variantId);
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
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  // Método para cambiar de variante (ej: al hacer click en otro color)
  void changeVariant(int newVariantId) {
    if (product != null) {
      fetchProductDetail(product!.id, newVariantId);
    }
  }
}
