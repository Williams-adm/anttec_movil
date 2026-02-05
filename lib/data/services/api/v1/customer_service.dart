// lib/data/services/api/v1/customer_service.dart
import 'package:dio/dio.dart';
import 'package:anttec_movil/data/services/api/v1/api_service.dart';

class CustomerService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>?> consultarDni(String dni) async {
    try {
      final String path = '/customers/dni/$dni';
      final response = await _apiService.dio.get(path);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        // La API devuelve "status": true/false
        if (data['status'] == true && data['data'] != null) {
          return data['data']; // Retorna {name, last_name, document_number}
        }
      }
      return null; // DNI no encontrado o error en status
    } catch (e) {
      return null; // Error de red
    }
  }
}
