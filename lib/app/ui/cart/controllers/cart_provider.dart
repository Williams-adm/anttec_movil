import 'package:flutter/material.dart';
import 'package:anttec_movil/app/ui/cart/model/cart_item.dart';
import 'package:anttec_movil/app/ui/cart/repositories/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository _cartRepository;

  CartProvider(this._cartRepository);

  List<CartItem> _items = [];
  List<CartItem> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? errorMessage;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // ===========================================================================
  // 📥 OBTENER CARRITO (MODIFICADO: MODO SILENCIOSO)
  // ===========================================================================
  // Agregamos 'silent' para no bloquear la pantalla al actualizar
  Future<void> fetchCart({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _items = await _cartRepository.getCart();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      _items = [];
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners(); // Siempre notificamos al final para actualizar precios
    }
  }

  // ===========================================================================
  // ➕ AGREGAR ITEM
  // ===========================================================================
  Future<bool> addItem({
    required int productId,
    int? variantId,
    required int quantity,
  }) async {
    try {
      await _cartRepository.addItem(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
      );
      // Aquí sí queremos loading porque el usuario viene de otra pantalla
      await fetchCart(silent: false);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ===========================================================================
  // 🔄 ACTUALIZAR CANTIDAD (CORREGIDO PARA NO PARPADEAR)
  // ===========================================================================
  Future<void> updateItem(int variantId, int quantity) async {
    try {
      // 1. Llamada a la API
      await _cartRepository.updateItem(variantId, quantity);

      // 2. Refrescamos la lista en MODO SILENCIOSO (silent: true)
      // Esto actualiza los totales sin poner la pantalla en blanco.
      await fetchCart(silent: true);
    } catch (e) {
      debugPrint("Error actualizando item: $e");
      // Si falla, recargamos normal para revertir visualmente
      await fetchCart(silent: true);
    }
  }

  // ===========================================================================
  // 🗑️ ELIMINAR ITEM
  // ===========================================================================
  Future<void> removeItem(int itemId) async {
    try {
      await _cartRepository.removeItem(itemId);
      await fetchCart(); // Al eliminar sí está bien que cargue un momento
    } catch (e) {
      debugPrint("Error eliminando item: $e");
    }
  }

  // ===========================================================================
  // 🧹 VACIAR CARRITO
  // ===========================================================================
  Future<void> clearCart() async {
    try {
      await _cartRepository.clearCart();
      _items = [];
      notifyListeners();
    } catch (e) {
      debugPrint("Error vaciando carrito: $e");
    }
  }
}
