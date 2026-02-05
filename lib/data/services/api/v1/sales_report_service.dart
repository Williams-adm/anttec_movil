import 'dart:developer' as dev;
import 'package:anttec_movil/data/services/api/v1/api_service.dart';

class SalesReportService {
  final ApiService _apiService = ApiService();

  // 1. OBTENER LISTA DE VENTAS
  Future<Map<String, dynamic>?> getOrders({
    int page = 1,
    String? date,
    int perPage = 15,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'per_page': perPage,
        'order_dir': 'desc',
        if (date != null) 'date': date,
      };

      final response = await _apiService.dio.get(
        '/mobile/orders',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      return null;
    } catch (e) {
      dev.log("Error getOrders: $e", name: 'SalesReportService');
      return null;
    }
  }

  // 2. OBTENER DETALLE DE ORDEN (¡ESTA ES LA FUNCIÓN QUE TE FALTABA!)
  Future<List<dynamic>?> getOrderDetails(int orderId) async {
    try {
      dev.log("Consultando detalle Orden ID: $orderId",
          name: 'SalesReportService');

      // Llamamos al endpoint de ordenes por ID
      final response = await _apiService.dio.get('/mobile/orders/$orderId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        if (data is Map) {
          // Buscamos donde están los items
          if (data.containsKey('items')) return data['items'] as List;
          if (data.containsKey('details')) return data['details'] as List;
          if (data.containsKey('products')) return data['products'] as List;
        }
      }
      return null;
    } catch (e) {
      dev.log("Error getOrderDetails: $e", name: 'SalesReportService');
      return null;
    }
  }
}
