import 'package:dio/dio.dart';
import 'package:anttec_movil/data/services/api/v1/api_service.dart';

class PaymentService {
  final ApiService _apiService = ApiService();

  // METODO NUEVO: Obtener la imagen del QR (GET)
  Future<String?> obtenerInfoBilletera(String wallet) async {
    try {
      // wallet sera 'yape' o 'plin'
      final String path = '/mobile/method-payments/$wallet';

      final response = await _apiService.dio.get(path);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data['image'] != null) {
          return data['image'].toString();
        }
      }
      return null;
    } catch (e) {
      // Si falla, retornamos null para mostrar el icono por defecto
      return null;
    }
  }

  // Metodo existente para procesar el pago (POST)
  Future<Response> procesarPagoDigital({
    required String wallet,
    required String numeroOperacion,
    required double monto,
    required String nombreCliente,
    required String documento,
  }) async {
    try {
      final String path = '/mobile/method-payments/$wallet';

      final Map<String, dynamic> data = {
        'operation_number': numeroOperacion,
        'amount': monto,
        'customer_name': nombreCliente,
        'document': documento,
        'date': DateTime.now().toIso8601String(),
      };

      return await _apiService.dio.post(path, data: data);
    } catch (e) {
      rethrow;
    }
  }
}
