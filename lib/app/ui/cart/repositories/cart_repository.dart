import 'package:dio/dio.dart';
import 'package:anttec_movil/app/ui/cart/model/cart_item.dart';
import 'package:flutter/foundation.dart';

class CartRepository {
  final Dio _dio;
  CartRepository(this._dio);

  Future<List<CartItem>> getCart() async {
    try {
      final response = await _dio.get('/mobile/cart');

      // ✅ VALIDACIÓN ANTI-CRASH: Si no es un mapa, abortamos con lista vacía
      if (response.data == null || response.data is! Map) {
        debugPrint("⚠️ Respuesta de API inválida: ${response.data}");
        return [];
      }

      final dynamic rawData = response.data['data'];
      List<dynamic> itemsList = [];

      if (rawData is List) {
        itemsList = rawData;
      } else if (rawData is Map) {
        if (rawData['cart'] != null && rawData['cart']['detail_cart'] is List) {
          itemsList = rawData['cart']['detail_cart'];
        } else if (rawData['items'] is List) {
          itemsList = rawData['items'];
        }
      }

      // ✅ MAPEADO SEGURO
      return itemsList
          .whereType<
              Map<String, dynamic>>() // Solo procesa si es un JSON válido
          .map((itemJson) => CartItem.fromJson(itemJson))
          .where((item) => item.quantity > 0)
          .toList();
    } catch (e) {
      debugPrint("❌ Error fatal en GetCart: $e");
      return [];
    }
  }

  Future<void> addItem(
      {required int productId, int? variantId, required int quantity}) async {
    try {
      await _dio.post('/mobile/cart/addItem', data: {
        "product_id": productId,
        "branch_variant_id": variantId,
        "quantity": quantity,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al agregar');
    }
  }

  Future<void> updateItem(int variantId, int quantity) async {
    try {
      await _dio.put(
        '/mobile/cart/updateItem/$variantId',
        data: {"quantity": quantity},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } catch (e) {
      throw Exception("Error al actualizar");
    }
  }

  Future<void> removeItem(int variantId) async {
    await updateItem(variantId, 0);
  }

  Future<void> clearCart() async {
    try {
      await _dio.delete('/mobile/cart/delete');
    } catch (e) {
      try {
        await _dio.get('/mobile/cart/clear');
      } catch (_) {}
    }
  }
}
