class ProductResponse {
  final bool success;
  final String message;
  final List<Product> data;
  final Map<String, dynamic> links;
  final Meta? meta;

  ProductResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.links,
    this.meta,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return false;
    }

    return ProductResponse(
      success: parseBool(json['success']),
      message: json['message']?.toString() ?? '',
      data:
          (json['data'] as List?)
              ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      links: (json['links'] as Map?)?.cast<String, dynamic>() ?? {},
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }
}

class Meta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  Meta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
    );
  }
}

class Product {
  final int id;
  final String name;
  final String? description;
  final bool status;
  final String category;
  final String subcategory;
  final String brand;
  final List<Specification> specifications;
  final int stock;
  final double price;
  final double? oldPrice;
  final String? imageUrl;
  final int? defaultVariantId; // El ID de la variante para navegar

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.category,
    required this.subcategory,
    required this.brand,
    required this.specifications,
    this.stock = 0,
    required this.price,
    this.oldPrice,
    this.imageUrl,
    this.defaultVariantId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return false;
    }

    // --- LÓGICA DE EXTRACCIÓN DEL OBJETO VARIANT ---
    // Según tu JSON, la info importante está dentro de "variant": {...}
    final variantObj = json['variant'] as Map<String, dynamic>?;

    // 1. Extraer ID de la variante (Soluciona el error 404)
    final int? variantIdVal = variantObj != null
        ? int.tryParse(variantObj['id']?.toString() ?? '')
        : null;

    // 2. Extraer Precio (priorizamos 'selling_price' de la variante)
    final double priceVal = variantObj != null
        ? double.tryParse(variantObj['selling_price']?.toString() ?? '0') ?? 0.0
        : (json['price'] != null
              ? double.tryParse(json['price'].toString()) ?? 0.0
              : 0.0);

    // 3. Extraer Stock
    final int stockVal = variantObj != null
        ? int.tryParse(variantObj['stock']?.toString() ?? '0') ?? 0
        : (json['stock'] != null
              ? int.tryParse(json['stock'].toString()) ?? 0
              : 0);

    // 4. Extraer Imagen
    final String? imageVal = variantObj != null
        ? variantObj['image']?.toString()
        : json['image_url']?.toString();

    return Product(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      status: parseBool(json['status']),
      category: json['category']?.toString() ?? '',
      subcategory: json['subcategory']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      specifications:
          (json['specifications'] as List?)
              ?.map(
                (spec) => Specification.fromJson(spec as Map<String, dynamic>),
              )
              .toList() ??
          [],

      // Asignamos los valores procesados arriba
      stock: stockVal,
      price: priceVal,
      imageUrl: imageVal,
      defaultVariantId: variantIdVal, // <--- AQUÍ ESTÁ LA SOLUCIÓN

      oldPrice: json['old_price'] != null
          ? ((json['old_price'] is num)
                ? (json['old_price'] as num).toDouble()
                : double.tryParse(json['old_price'].toString()))
          : null,
    );
  }
}

class Specification {
  final int id;
  final String name;
  final String value;

  Specification({required this.id, required this.name, required this.value});

  factory Specification.fromJson(Map<String, dynamic> json) {
    return Specification(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }
}
