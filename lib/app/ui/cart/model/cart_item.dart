class CartItem {
  final int id; // ID para ELIMINAR (item_id: 9)
  final int productId;
  final int variantId; // ✅ ID para ACTUALIZAR (branch_variant_id: 1)
  final String name;
  final String sku;
  final String image;
  final String colorName;
  final double price;
  int quantity;
  final int maxStock;

  CartItem({
    required this.id,
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

  double get total => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productData = json['variant'] ?? {};

    // ID DEL CARRITO (Para borrar)
    final cartItemId = json['item_id'] ?? json['id'];

    // ✅ ID DE VARIANTE (Para actualizar) - Lógica Robusta
    // Primero buscamos 'branch_variant_id', si no, 'variant' -> 'id'
    final vId = json['branch_variant_id'] ?? productData['id'];

    // PRECIO
    final priceRaw = json['unit_price'] ?? json['price'];

    // COLOR
    String color = '';
    if (productData['features'] != null && productData['features'] is List) {
      final features = productData['features'] as List;
      if (features.isNotEmpty) {
        color = features.first['description']?.toString() ?? '';
      }
    }
    if (color.isEmpty) {
      color = json['color']?.toString() ?? '';
    }

    return CartItem(
      id: int.tryParse(cartItemId?.toString() ?? '0') ?? 0,
      productId:
          int.tryParse(productData['product_id']?.toString() ?? '0') ?? 0,

      // Aseguramos que variantId nunca sea null (0 por defecto)
      variantId: int.tryParse(vId?.toString() ?? '0') ?? 0,

      name: productData['name']?.toString() ?? 'Producto',
      sku: productData['model']?.toString() ?? '',
      image:
          productData['image']?.toString() ?? 'https://via.placeholder.com/150',
      colorName: color,
      price: double.tryParse(priceRaw?.toString() ?? '0') ?? 0.0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      maxStock: int.tryParse(productData['stock']?.toString() ?? '10') ?? 10,
    );
  }
}
