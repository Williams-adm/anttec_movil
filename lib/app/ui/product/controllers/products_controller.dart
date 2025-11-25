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

  ProductsController({required this.token}) : api = ProductService() {
    fetchProducts();
  }

  Future<void> fetchProducts({int? newPage}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final ProductResponse resp = await api.productAll(page: newPage ?? page);
      products = resp.data;
      page = newPage ?? page;
      error = null;
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  void nextPage() {
    fetchProducts(newPage: page + 1);
  }

  void previousPage() {
    if (page > 1) fetchProducts(newPage: page - 1);
  }
}
