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

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> fetchCart({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final newItems = await _cartRepository.getCart();
      if (newItems.isNotEmpty || _items.isEmpty) {
        _items = newItems;
      }
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      if (!silent) _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addItem(
      {required int productId, int? variantId, required int quantity}) async {
    try {
      await _cartRepository.addItem(
          productId: productId, variantId: variantId, quantity: quantity);
      await fetchCart(silent: false);
      return true;
    } catch (e) {
      notifyListeners();
      return false;
    }
  }

  // ✅ REMOVE ITEM: Ahora usa variantId
  Future<void> removeItem(CartItem item) async {
    final backup = List<CartItem>.from(_items);
    _items.removeWhere((i) => i.id == item.id); // Borrado visual
    notifyListeners();

    try {
      // Pasamos variantId para el truco ninja
      await _cartRepository.removeItem(item.variantId);
      await fetchCart(silent: true);
    } catch (e) {
      debugPrint("❌ Error eliminando: $e");
      _items = backup; // Restaurar si falla
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    final backup = List<CartItem>.from(_items);
    _items = [];
    notifyListeners();
    try {
      await _cartRepository.clearCart();
    } catch (e) {
      _items = backup;
      notifyListeners();
    }
  }

  Future<void> updateItem(int variantId, int quantity) async {
    try {
      await _cartRepository.updateItem(variantId, quantity);
      await fetchCart(silent: true);
    } catch (e) {
      await fetchCart(silent: true);
    }
  }
}
