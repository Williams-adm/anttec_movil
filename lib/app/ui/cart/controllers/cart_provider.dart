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
      _items = await _cartRepository.getCart();
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
      await fetchCart(silent: true);
      return true;
    } catch (e) {
      debugPrint("❌ Error addItem: $e");
      return false;
    }
  }

  Future<void> updateItem(int variantId, int quantity) async {
    try {
      await _cartRepository.updateItem(variantId, quantity);
      await fetchCart(silent: true);
    } catch (e) {
      debugPrint("❌ Error updateItem: $e");
      await fetchCart(silent: true);
    }
  }

  Future<void> removeItem(CartItem item) async {
    final backup = List<CartItem>.from(_items);
    _items.removeWhere((i) => i.variantId == item.variantId);
    notifyListeners();

    try {
      await _cartRepository.removeItem(item.variantId);
      await fetchCart(silent: true);
    } catch (e) {
      _items = backup;
      notifyListeners();
    }
  }

  // ✅ MÉTODO AÑADIDO PARA SOLUCIONAR EL ERROR
  Future<void> clearCart() async {
    final backup = List<CartItem>.from(_items);
    _items = [];
    notifyListeners();
    try {
      await _cartRepository.clearCart();
      errorMessage = null;
    } catch (e) {
      _items = backup;
      notifyListeners();
    }
  }

  void resetLocalData() {
    _items = [];
    errorMessage = null;
    notifyListeners();
  }
}
