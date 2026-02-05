import 'package:anttec_movil/data/services/api/v1/api_service.dart';

class CustomerService {
  // Instanciamos ApiService para reutilizar la configuración base (URL, headers, etc.)
  final ApiService _apiService = ApiService();

  /// Consultar datos de DNI (RENIEC)
  /// Endpoint: /customers/dni/{dni}
  Future<Map<String, dynamic>?> consultarDni(String dni) async {
    try {
      final String path = '/customers/dni/$dni';
      final response = await _apiService.dio.get(path);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Verificamos la estructura: { "status": true, "data": { ... } }
        if (data['status'] == true && data['data'] != null) {
          return data['data'];
          // Retorna mapa con: name, last_name, document_number
        }
      }
      return null; // DNI no encontrado o status false
    } catch (e) {
      // Manejo silencioso de errores (retorna null para que la UI muestre el aviso)
      return null;
    }
  }

  /// Consultar datos de RUC (SUNAT)
  /// Endpoint: /customers/ruc/{ruc}
  Future<Map<String, dynamic>?> consultarRuc(String ruc) async {
    try {
      final String path = '/customers/ruc/$ruc';
      final response = await _apiService.dio.get(path);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Verificamos la estructura: { "status": true, "data": { ... } }
        if (data['status'] == true && data['data'] != null) {
          return data['data'];
          // Retorna mapa con: business_name, tax_address, document_number
        }
      }
      return null; // RUC no encontrado o status false
    } catch (e) {
      return null;
    }
  }
}
