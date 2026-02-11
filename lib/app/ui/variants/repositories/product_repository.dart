import 'package:anttec_movil/data/services/api/v1/api_service.dart';

import 'package:anttec_movil/data/services/api/v1/model/product/product_detail_response.dart';

class ProductRepository {
  final ApiService _apiService = ApiService();

  Future<ProductDetailData?> getProductVariant(
      int productId, int variantId) async {
    try {
      // Llamada al endpoint: /mobile/products/{id}/variants/{variantId}
      final response = await _apiService.dio
          .get('/mobile/products/$productId/variants/$variantId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        //  CORREGIDO: Usamos ProductDetailData que es como se llama tu clase
        return ProductDetailData.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
