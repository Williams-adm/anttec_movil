import 'package:flutter/material.dart';
import 'package:anttec_movil/data/services/api/v1/brand_service.dart';

class BrandController extends ChangeNotifier {
  final BrandService _brandService = BrandService();
  List<dynamic> brands = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> loadBrands() async {
    try {
      final data = await _brandService.getAllBrands();
      brands = data;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
