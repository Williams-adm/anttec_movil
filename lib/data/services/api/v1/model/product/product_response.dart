// lib/data/services/api/v1/model/product/product_response.dart

class ProductResponse {
  final bool success;
  final String message;
  final List<Product> data;
  final Map<String, dynamic> links;
  final Map<String, dynamic> meta;

  ProductResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.links,
    required this.meta,
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
      meta: (json['meta'] as Map?)?.cast<String, dynamic>() ?? {},
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

  // Puedes agregar los extras para el grid aquí:
  final int stock;
  final double price;
  final double? oldPrice;
  final String? imageUrl;

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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return false;
    }

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
      stock: json['stock'] ?? 0,
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '') ?? 0,
      oldPrice: json['old_price'] != null
          ? ((json['old_price'] is num)
                ? (json['old_price'] as num).toDouble()
                : double.tryParse(json['old_price'].toString()))
          : null,
      imageUrl: json['image_url']?.toString(),
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
