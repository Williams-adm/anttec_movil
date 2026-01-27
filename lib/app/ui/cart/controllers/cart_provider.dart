import 'package:flutter/material.dart';
import 'package:anttec_movil/app/ui/cart/model/cart_item.dart';
import 'package:anttec_movil/app/ui/cart/repositories/cart_repository.dart'; // Importa tu repo

class CartProvider extends ChangeNotifier {
  final CartRepository _cartRepository;

  CartProvider(this._cartRepository);

  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Calcular total
  double get totalAmount {
    var total = 0.0;
    for (var item in _items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  int get itemCount => _items.length;

  // --- OBTENER CARRITO (GET) ---
  Future<void> fetchCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _cartRepository.getCart();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- AGREGAR (POST) ---
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
      // Recargamos el carrito para traer los datos frescos con el ID generado por la BD
      await fetchCart();
      return true;
    } catch (e) {
      _errorMessage = "Error al agregar al carrito";
      notifyListeners();
      return false;
    }
  }

  // --- ACTUALIZAR CANTIDAD (PUT) ---
  Future<void> updateQuantity(int itemId, int newQuantity) async {
    // Optimistic UI: Actualizamos visualmente antes de llamar a la API
    // (Opcional, aquí lo haremos esperando la respuesta para asegurar consistencia)
    try {
      await _cartRepository.updateItem(itemId, newQuantity);
      await fetchCart();
    } catch (e) {
      // Manejar error
    }
  }

  // --- ELIMINAR ÍTEM (DELETE) ---
  Future<void> removeItem(int itemId) async {
    try {
      await _cartRepository.removeItem(itemId);
      _items.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      // Manejar error
    }
  }

  // --- VACIAR CARRITO (DELETE) ---
  Future<void> clearCart() async {
    try {
      await _cartRepository.clearCart();
      _items = [];
      notifyListeners();
    } catch (e) {
      // Manejar error
    }
  }
}
