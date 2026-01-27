class CartItem {
  final int? id; // ID del ítem en el carrito (item_id)
  final int productId;
  final int? variantId; // branch_variant_id
  final String name;
  final String sku;
  final String image;
  final String colorName;
  final double price;
  int quantity;
  final int maxStock;

  CartItem({
    this.id,
    required this.productId,
    this.variantId,
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
    // 1. OBTENER EL OBJETO DE DATOS DEL PRODUCTO
    // En tu JSON de 'addItem', los detalles están dentro de 'variant'
    final productData = json['variant'] ?? {};

    // 2. ID DEL CARRITO (Tu JSON dice 'item_id')
    // A veces en getCart puede venir como 'id', así que buscamos ambos.
    final cartItemId = json['item_id'] ?? json['id'];

    // 3. ID DE LA VARIANTE (El campo clave 'branch_variant_id')
    final vId = json['branch_variant_id'];

    // 4. PRECIO (Tu JSON dice 'unit_price')
    final priceRaw = json['unit_price'] ?? json['price'];

    // 5. COLOR
    // Tu JSON tiene: variant -> features -> [ { description: "Negro" } ]
    String color = '';
    if (productData['features'] != null && productData['features'] is List) {
      final features = productData['features'] as List;
      if (features.isNotEmpty) {
        // Buscamos la descripción del primer feature
        color = features.first['description']?.toString() ?? '';
      }
    }
    // Si no está en features, intentamos buscarlo directo por si acaso
    if (color.isEmpty) {
      color = json['color']?.toString() ?? '';
    }

    return CartItem(
      id: int.tryParse(cartItemId?.toString() ?? '0'),

      // productId está dentro de 'variant' -> 'product_id'
      productId:
          int.tryParse(productData['product_id']?.toString() ?? '0') ?? 0,

      variantId: int.tryParse(vId?.toString() ?? '0'),

      // Datos dentro de 'variant'
      name: productData['name']?.toString() ?? 'Producto',
      sku: productData['model']?.toString() ??
          '', // Tu JSON usa 'model' como SKU visual

      // Imagen
      image:
          productData['image']?.toString() ?? 'https://via.placeholder.com/150',

      colorName: color,

      price: double.tryParse(priceRaw?.toString() ?? '0') ?? 0.0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      maxStock: int.tryParse(productData['stock']?.toString() ?? '10') ?? 10,
    );
  }
}
