import 'package:flutter/material.dart';
import 'package:anttec_movil/app/ui/cart/model/cart_item.dart';

class CartProvider extends ChangeNotifier {
  // Lista privada de ítems
  final Map<String, CartItem> _items = {};

  // Getter para obtener la lista como un array
  Map<String, CartItem> get items {
    return {..._items};
  }

  // Cantidad total de elementos (para el globito del icono)
  int get itemCount {
    return _items.length;
  }

  // Monto total a pagar
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // --- FUNCIÓN AGREGAR AL CARRITO ---
  void addItem({
    required int productId,
    required int variantId,
    required String name,
    required String sku,
    required String image,
    required String colorName,
    required double price,
    required int quantity,
    required int maxStock,
  }) {
    // Generamos un ID único combinando producto y variante
    // Así, el "Teclado Rojo" es distinto al "Teclado Azul"
    final uniqueId = '$productId-$variantId';

    if (_items.containsKey(uniqueId)) {
      // Si ya existe, solo aumentamos la cantidad
      _items.update(
        uniqueId,
        (existingItem) => CartItem(
          uniqueId: existingItem.uniqueId,
          productId: existingItem.productId,
          variantId: existingItem.variantId,
          name: existingItem.name,
          sku: existingItem.sku,
          image: existingItem.image,
          colorName: existingItem.colorName,
          price: existingItem.price,
          maxStock: existingItem.maxStock,
          quantity: existingItem.quantity + quantity, // Sumamos lo nuevo
        ),
      );
    } else {
      // Si no existe, lo creamos
      _items.putIfAbsent(
        uniqueId,
        () => CartItem(
          uniqueId: uniqueId,
          productId: productId,
          variantId: variantId,
          name: name,
          sku: sku,
          image: image,
          colorName: colorName,
          price: price,
          quantity: quantity,
          maxStock: maxStock,
        ),
      );
    }
    notifyListeners(); // Avisamos a la app que el carrito cambió
  }

  // Eliminar un ítem por completo
  void removeItem(String uniqueId) {
    _items.remove(uniqueId);
    notifyListeners();
  }

  // Limpiar todo el carrito
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
