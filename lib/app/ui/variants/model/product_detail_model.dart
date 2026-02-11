class ProductDetail {
  final int id;
  final String name;
  final String description;
  final String brand;
  final SelectedVariant selectedVariant;
  final List<Specification> specifications; //  Nuevo
  final List<VariantSummary> allVariants; //  Nuevo (para el selector de color)

  ProductDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.brand,
    required this.selectedVariant,
    required this.specifications,
    required this.allVariants,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      brand: json['brand'] ?? '',
      selectedVariant: SelectedVariant.fromJson(json['selected_variant']),
      // Mapeo de especificaciones
      specifications: (json['specifications'] as List?)
              ?.map((e) => Specification.fromJson(e))
              .toList() ??
          [],
      // Mapeo de otras variantes disponibles
      allVariants: (json['variants'] as List?)
              ?.map((e) => VariantSummary.fromJson(e))
              .toList() ??
          [],
    );
  }
}

// Clase para las especificaciones (Tabla técnica)
class Specification {
  final String name;
  final String value;

  Specification({required this.name, required this.value});

  factory Specification.fromJson(Map<String, dynamic> json) {
    return Specification(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
    );
  }
}

// Clase resumida para la lista de variantes (Selector de color)
class VariantSummary {
  final int id;
  final String colorHex;
  final String colorName;

  VariantSummary(
      {required this.id, required this.colorHex, required this.colorName});

  factory VariantSummary.fromJson(Map<String, dynamic> json) {
    String hex = "#000000";
    String name = "";

    // Buscamos la característica de tipo "color"
    if (json['features'] != null) {
      final features = json['features'] as List;
      final colorFeature =
          features.firstWhere((f) => f['type'] == 'color', orElse: () => null);

      if (colorFeature != null) {
        hex = colorFeature['value'] ?? "#000000";
        name = colorFeature['description'] ?? "";
      }
    }

    return VariantSummary(
      id: json['id'],
      colorHex: hex,
      colorName: name,
    );
  }
}

// ... (La clase SelectedVariant que ya tenías sigue igual)
class SelectedVariant {
  final int id;
  final String sku;
  final double price;
  final int stock;
  final List<String> images;

  SelectedVariant({
    required this.id,
    required this.sku,
    required this.price,
    required this.stock,
    required this.images,
  });

  factory SelectedVariant.fromJson(Map<String, dynamic> json) {
    List<String> imgs = [];
    if (json['images'] != null) {
      imgs =
          (json['images'] as List).map((img) => img['url'].toString()).toList();
    }
    return SelectedVariant(
      id: json['id'],
      sku: json['sku'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      stock: json['stock'] ?? 0,
      images: imgs,
    );
  }
}
