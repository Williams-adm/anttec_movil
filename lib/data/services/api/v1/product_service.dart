import 'package:anttec_movil/data/services/api/v1/api_service.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_response.dart';
import 'package:dio/dio.dart';

class ProductService extends ApiService {
  ProductService() : super();

  Future<ProductResponse> productAll({int page = 1}) async {
    try {
      final response = await dio.get(
        '/admin/products',
        queryParameters: {'page': page},
      );
      final productResponse = ProductResponse.fromJson(response.data);
      return productResponse;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}
