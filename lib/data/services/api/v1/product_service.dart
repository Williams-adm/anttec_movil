import 'package:anttec_movil/data/services/api/v1/api_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_response.dart';
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
  }) async {
    try {
      // Construimos los parámetros de consulta
      final Map<String, dynamic> queryParams = {'page': page};

      if (brand != null) queryParams['brand'] = brand;
      if (priceMin != null) queryParams['priceMin'] = priceMin;
      if (priceMax != null) queryParams['priceMax'] = priceMax;
      if (category != null) queryParams['category'] = category;
      if (subcategory != null) queryParams['subcategory'] = subcategory;

      final response = await dio.get(
        '/mobile/products', // Asegúrate de que esta sea la ruta correcta
        queryParameters: queryParams,
      );

      final productResponse = ProductResponse.fromJson(response.data);
      return productResponse;
    } on DioException catch (e) {
      // Manejo de errores de Dio
      throw Exception(e.response?.data['message'] ?? e.message);
    } catch (e) {
      throw Exception("Error desconocido: $e");
    }
  }
}
