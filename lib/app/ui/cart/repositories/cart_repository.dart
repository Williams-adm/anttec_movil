import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:anttec_movil/app/ui/cart/model/cart_item.dart';

class CartRepository {
  final Dio _dio;

  CartRepository(this._dio);

  // ===========================================================================
  // 🛒 GET: OBTENER CARRITO
  // ===========================================================================
  Future<List<CartItem>> getCart() async {
    try {
      final response = await _dio.get('/mobile/cart');

      if (kDebugMode) debugPrint("🛒 GET RESPUESTA: ${response.data}");

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
        } else if (rawData['detail_cart'] is List) {
          itemsList = rawData['detail_cart'];
        }
      }

      return itemsList.map((itemJson) {
        try {
          return CartItem.fromJson(itemJson);
        } catch (e) {
          return CartItem(
              id: 0,
              productId: 0,
              name: "Error",
              sku: "",
              image: "",
              colorName: "",
              price: 0,
              quantity: 0,
              maxStock: 0);
        }
      }).toList();
    } catch (e) {
      debugPrint("💥 Error GET Cart: $e");
      return [];
    }
  }

  // ===========================================================================
  // 🚀 POST: AGREGAR ÍTEM
  // ===========================================================================
  Future<void> addItem({
    required int productId,
    int? variantId,
    required int quantity,
  }) async {
    try {
      final body = {
        "product_id": productId,
        "branch_variant_id": variantId,
        "quantity": quantity,
      };
      if (kDebugMode) debugPrint("📤 ENVIANDO ADD: $body");
      await _dio.post('/mobile/cart/addItem', data: body);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al agregar');
    }
  }

  // ===========================================================================
  // 🔄 PUT: ACTUALIZAR CANTIDAD
  // ===========================================================================
  Future<void> updateItem(int itemId, int quantity) async {
    try {
      await _dio
          .put('/mobile/cart/updateItem/$itemId', data: {"quantity": quantity});
    } catch (e) {
      await _dio.post('/mobile/cart/updateItem/$itemId',
          data: {"quantity": quantity, "_method": "PUT"});
    }
  }

  // ===========================================================================
  // 🗑️ DELETE: ELIMINAR (SOLUCIÓN AL ERROR 405)
  // ===========================================================================
  Future<void> removeItem(int itemId) async {
    debugPrint("🗑️ Intentando eliminar ítem ID: $itemId");

    // INTENTO 1: La Solución al 405
    // Usamos DELETE (no POST) y enviamos el ID en el cuerpo (data)
    try {
      await _dio.delete('/mobile/cart/delete', data: {
        "item_id": itemId,
        "id": itemId // Enviamos ambas llaves por seguridad
      });
      debugPrint("✅ Eliminado con: DELETE /mobile/cart/delete (Body)");
      return;
    } catch (e) {
      debugPrint("⚠️ Falló DELETE con body: $e");
    }

    // INTENTO 2: Ruta 'remove' (a veces usada en Laravel)
    try {
      await _dio.post('/mobile/cart/remove', data: {"item_id": itemId});
      debugPrint("✅ Eliminado con: POST /mobile/cart/remove");
      return;
    } catch (e) {
      debugPrint("⚠️ Falló POST remove");
    }

    // INTENTO 3: GET (Truco sucio de algunos backends antiguos)
    try {
      await _dio.get('/mobile/cart/removeItem/$itemId');
      debugPrint("✅ Eliminado con: GET /mobile/cart/removeItem/$itemId");
      return;
    } catch (e) {
      debugPrint("❌ Fallaron todas las opciones de eliminación.");
      throw Exception('No se pudo eliminar. Revisa la ruta en el Backend.');
    }
  }

  // DELETE: Vaciar carrito
  Future<void> clearCart() async {
    try {
      await _dio.delete('/mobile/cart/delete');
    } catch (e) {
      try {
        await _dio.delete('/cart/delete');
      } catch (e2) {
        throw Exception('Error al vaciar carrito');
      }
    }
  }
}
