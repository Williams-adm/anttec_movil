import 'package:dio/dio.dart';
// Asegúrate de importar tu ApiService correctamente
import 'package:anttec_movil/data/services/api/v1/api_service.dart'; // Ajusta la ruta si es distinta

class ScannerService {
  final ApiService _apiService;

  // Inyectamos ApiService para reutilizar la configuración (BaseURL, Tokens, Interceptors)
  ScannerService({required ApiService apiService}) : _apiService = apiService;

  Future<Map<String, dynamic>> getVariantByBarcode(String barcode) async {
    try {
      // ⚠️ IMPORTANTE: Como tu ApiService ya tiene el BaseURL terminando en '/api/v1',
      // aquí solo ponemos la ruta relativa restante.
      final response = await _apiService.dio.get('/mobile/variants/$barcode');

      // Gracias a tus interceptores, si llega aquí es porque la respuesta fue exitosa a nivel de red.
      // Ahora validamos la lógica de negocio del backend.
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? "El producto no está disponible.");
      }
    } on DioException catch (e) {
      // Tu ApiService ya procesó el mensaje de error en el interceptor (onError),
      // y lo guardó en e.error. Lo recuperamos para lanzarlo limpio a la UI.
      throw Exception(e.error ?? "Error al consultar el producto.");
    } catch (e) {
      rethrow;
    }
  }
}
