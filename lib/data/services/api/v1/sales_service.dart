import 'package:dio/dio.dart';
import 'package:anttec_movil/data/services/api/v1/api_service.dart';

class SalesService {
  final ApiService _apiService = ApiService();

  Future<Response> createOrder(Map<String, dynamic> orderData) async {
    try {
      // Endpoint para crear la orden
      const String path = '/mobile/orders';

      // Realizamos el POST con la data estructurada
      return await _apiService.dio.post(path, data: orderData);
    } catch (e) {
      rethrow;
    }
  }
}
