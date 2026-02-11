import 'package:anttec_movil/data/services/api/v1/api_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_response.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_detail_response.dart';
import 'package:dio/dio.dart';

class ProductService extends ApiService {
  ProductService() : super();

  Future<ProductResponse> productAll({
    int page = 1,
    int? brand,
    double? priceMin,
    double? priceMax,
    int? category,
    int? subcategory,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'per_page': 16,
      };

      if (brand != null) queryParams['brand'] = brand;
      if (priceMin != null) queryParams['priceMin'] = priceMin;
      if (priceMax != null) queryParams['priceMax'] = priceMax;
      if (category != null) queryParams['category'] = category;
      if (subcategory != null) queryParams['subcategory'] = subcategory;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

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

  /// Obtener el detalle.
  /// ✅ CORRECCIÓN: Si variantId es 0, llamamos al producto base.
  Future<ProductDetailResponse> productDetail({
    required int productId,
    required int variantId,
  }) async {
    try {
      String endpoint;

      // SI NO HAY VARIANTE (ID 0), LLAMAMOS AL PRODUCTO BASE
      if (variantId == 0) {
        endpoint = '/mobile/products/$productId';
      } else {
        // SI HAY VARIANTE, LLAMAMOS AL ENDPOINT ESPECÍFICO
        endpoint = '/mobile/products/$productId/variants/$variantId';
      }

      final response = await dio.get(endpoint);

      return ProductDetailResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Manejo de errores más detallado para debug
      final msg = e.response?.data['message'] ??
          "Error de conexión con el servidor (${e.response?.statusCode})";
      throw Exception(msg);
    } catch (e) {
      throw Exception("Error inesperado al cargar detalle: $e");
    }
  }
}
