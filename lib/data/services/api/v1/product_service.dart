import 'package:anttec_movil/data/services/api/v1/api_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_response.dart';
// Asegúrate de haber creado este archivo con el modelo que te pasé en el paso anterior
import 'package:anttec_movil/data/services/api/v1/model/product/product_detail_response.dart';
import 'package:dio/dio.dart';

class ProductService extends ApiService {
  ProductService() : super();

  /// Obtener lista de productos con paginación y filtros
  Future<ProductResponse> productAll({
    int page = 1,
    int? brand,
    double? priceMin,
    double? priceMax,
    int? category,
    int? subcategory,
  }) async {
    try {
      // 1. Construimos el mapa de parámetros dinámicamente
      final Map<String, dynamic> queryParams = {'page': page};

      if (brand != null) queryParams['brand'] = brand;
      if (priceMin != null) queryParams['priceMin'] = priceMin;
      if (priceMax != null) queryParams['priceMax'] = priceMax;
      if (category != null) queryParams['category'] = category;
      if (subcategory != null) queryParams['subcategory'] = subcategory;

      final response = await dio.get(
        '/mobile/products',
        queryParameters: queryParams,
      );

      return ProductResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }

  /// Obtener el detalle de un producto y una variante específica
  /// Endpoint: /mobile/products/{id}/variants/{variantId}
  Future<ProductDetailResponse> productDetail({
    required int productId,
    required int variantId,
  }) async {
    try {
      final response = await dio.get(
        '/mobile/products/$productId/variants/$variantId',
      );

      return ProductDetailResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Manejo de error si el producto o la variante no existen
      throw Exception(e.response?.data['message'] ?? e.message);
    } catch (e) {
      throw Exception("Error inesperado al cargar detalle: $e");
    }
  }
}
