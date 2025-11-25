import 'package:anttec_movil/data/services/api/v1/api_service.dart';
import 'package:dio/dio.dart';

class BrandService extends ApiService {
  BrandService() : super();

  Future<List<Map<String, dynamic>>> getAllBrands() async {
    try {
      final response = await dio.get('/mobile/brands');
      // Asumimos que siempre vendrá la respuesta como un Map que tiene un campo 'data'
      if (response.data is Map && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      // Si el backend solo manda una lista
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      // Si no viene nada válido regresamos lista vacía
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}
