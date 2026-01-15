class CartItem {
  final String
  uniqueId; // Para diferenciar variantes (ej: IDProducto + IDVariante)
  final int productId;
  final int variantId;
  final String name;
  final String sku;
  final String image;
  final String colorName; // Ej: "Rojo"
  final double price;
  int quantity;
  final int maxStock; // Para no dejar aumentar más del stock real en el carrito

  CartItem({
    required this.uniqueId,
    required this.productId,
    required this.variantId,
    required this.name,
    required this.sku,
    required this.image,
    required this.colorName,
    required this.price,
    required this.quantity,
    required this.maxStock,
  });

  // Calcular subtotal de este ítem
  double get total => price * quantity;
}
