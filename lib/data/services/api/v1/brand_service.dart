import 'package:anttec_movil/data/services/api/v1/api_service.dart';
import 'package:dio/dio.dart';

class BrandService extends ApiService {
  BrandService() : super();

  Future<List<dynamic>> getAllBrands() async {
    try {
      final response = await dio.get('/admin/brands/list');
      if (response.data is Map && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        return [];
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}
