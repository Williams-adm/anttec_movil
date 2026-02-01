import 'package:dio/dio.dart';
import 'package:anttec_movil/app/ui/cart/model/cart_item.dart';
import 'package:flutter/foundation.dart';

class CartRepository {
  final Dio _dio;
  CartRepository(this._dio);

  // 📥 LISTAR (CON FILTRO DE LIMPIEZA)
  Future<List<CartItem>> getCart() async {
    try {
      final response = await _dio.get('/mobile/cart');

      if (response.data == null || response.data['data'] == null) return [];

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

      return itemsList
          .map((itemJson) => CartItem.fromJson(itemJson))
          // 🛑 FILTRO CLAVE: Solo dejamos pasar items con cantidad mayor a 0
          .where((item) => item.quantity > 0)
          .toList();
    } catch (e) {
      debugPrint("Error GetCart: $e");
      return [];
    }
  }

  // ➕ AGREGAR
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

  // 🔄 ACTUALIZAR
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

  // 🗑️ ELIMINAR (Mantenemos el Truco Ninja porque funciona para bajarlo a 0)
  Future<void> removeItem(int variantId) async {
    debugPrint("🔥 BORRANDO: Enviando cantidad 0 al VariantID: $variantId");
    // Al ponerlo en 0, el filtro de arriba (getCart) lo ocultará en la próxima carga
    await updateItem(variantId, 0);
  }

  Future<void> clearCart() async {
    try {
      await _dio.delete('/mobile/cart/delete');
    } catch (e) {
      await _dio.get('/mobile/cart/clear');
    }
  }
}
