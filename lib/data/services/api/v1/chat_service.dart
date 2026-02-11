import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:anttec_movil/data/services/api/v1/api_service.dart';

class ChatService {
  // Usamos tu ApiService que ya tiene la BaseURL y los Interceptores
  final ApiService _apiService = ApiService();

  /// Envía el mensaje del usuario a la IA y retorna la respuesta procesada.
  /// [query]: El texto que escribe el usuario.
  /// [conversationId]: (Opcional) El ID para mantener el hilo de la charla.
  Future<Map<String, dynamic>> sendMessage(String query,
      {String? conversationId}) async {
    try {
      final Map<String, dynamic> body = {
        "query": query,
      };

      // Si tenemos un ID de conversación previo, lo enviamos para mantener el contexto
      if (conversationId != null) {
        body["conversation_id"] = conversationId;
      }

      // Hacemos el POST usando la instancia de Dio configurada en ApiService
      final response = await _apiService.dio.post(
        '/ia/recommend',
        data: body,
      );

      // Validamos la respuesta del Backend
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
        // Retorna el mapa con: { message, products, conversation_id }
      } else {
        throw Exception(
            response.data['message'] ?? 'Error desconocido del servidor');
      }
    } on DioException catch (e) {
      // Usamos tu manejador de errores centralizado
      final errorMsg = _apiService.handleDioError(e);
      debugPrint("❌ Error ChatService: $errorMsg");
      throw Exception(errorMsg);
    } catch (e) {
      debugPrint("❌ Error Genérico Chat: $e");
      throw Exception("Ocurrió un error inesperado al conectar con la IA.");
    }
  }
}
