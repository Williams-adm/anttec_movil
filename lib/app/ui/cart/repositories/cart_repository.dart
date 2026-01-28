import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:anttec_movil/app/ui/cart/model/cart_item.dart';

class CartRepository {
  final Dio _dio;
  CartRepository(this._dio);

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
      return itemsList.map((itemJson) => CartItem.fromJson(itemJson)).toList();
    } catch (e) {
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

  // ✅ UPDATE CORRECTO
  // Recibe variantId (ej: 1) y usa PUT UrlEncoded
  Future<void> updateItem(int variantId, int quantity) async {
    debugPrint("🔄 Update VariantID: $variantId | Qty: $quantity");
    try {
      await _dio.put(
        '/mobile/cart/updateItem/$variantId',
        data: {"quantity": quantity},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      debugPrint("✅ Actualizado OK");
    } catch (e) {
      debugPrint("❌ Error Update: $e");
      throw Exception("Error al actualizar");
    }
  }

  Future<void> removeItem(int itemId) async {
    try {
      await _dio.get('/mobile/cart/removeItem/$itemId');
    } catch (e) {
      await _dio.delete('/mobile/cart/delete', data: {"item_id": itemId});
    }
  }

  Future<void> clearCart() async {
    try {
      await _dio.delete('/mobile/cart/delete');
    } catch (e) {
      await _dio.get('/mobile/cart/clear');
    }
  }
}
