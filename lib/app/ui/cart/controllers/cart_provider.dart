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

  // Calculamos el total sumando (precio * cantidad) de cada ítem
  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  // Total de artículos (suma de cantidades) para el badge del ícono
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // ===========================================================================
  // 📥 OBTENER CARRITO
  // ===========================================================================
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _cartRepository.getCart();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
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
      await fetchCart(); // Recargamos para actualizar el badge y la lista
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ===========================================================================
  // 🔄 ACTUALIZAR CANTIDAD (¡ESTA ES LA QUE FALTABA!)
  // ===========================================================================
  Future<void> updateItem(int itemId, int quantity) async {
    try {
      // 1. Llamamos al repositorio para que hable con la API
      await _cartRepository.updateItem(itemId, quantity);

      // 2. Recargamos la lista para ver el nuevo total y cantidad
      await fetchCart();
    } catch (e) {
      debugPrint("Error actualizando item: $e");
      errorMessage = "No se pudo actualizar la cantidad";
      notifyListeners();
    }
  }

  // ===========================================================================
  // 🗑️ ELIMINAR ITEM
  // ===========================================================================
  Future<void> removeItem(int itemId) async {
    try {
      await _cartRepository.removeItem(itemId);
      await fetchCart(); // Recargamos la lista tras borrar
    } catch (e) {
      debugPrint("Error eliminando item: $e");
      errorMessage = "No se pudo eliminar el producto";
      notifyListeners();
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
      errorMessage = "Error al vaciar el carrito";
      notifyListeners();
    }
  }
}
