class ProductDetailResponse {
  final bool success;
  final String message;
  final ProductDetailData data;

  ProductDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ProductDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

class ProductDetailData {
  final int id;
  final String name;
  final String model;
  final String description;
  final String brand;
  final List<Spec> specifications;
  final SelectedVariant selectedVariant;
  final List<VariantOption> variants; // Lista de otras variantes disponibles

  ProductDetailData({
    required this.id,
    required this.name,
    required this.model,
    required this.description,
    required this.brand,
    required this.specifications,
    required this.selectedVariant,
    required this.variants,
  });

  factory ProductDetailData.fromJson(Map<String, dynamic> json) {
    return ProductDetailData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      model: json['model'] ?? '',
      description: json['description'] ?? '',
      brand: json['brand'] ?? '',
      specifications:
          (json['specifications'] as List?)
              ?.map((x) => Spec.fromJson(x))
              .toList() ??
          [],
      selectedVariant: SelectedVariant.fromJson(json['selected_variant'] ?? {}),
      variants:
          (json['variants'] as List?)
              ?.map((x) => VariantOption.fromJson(x))
              .toList() ??
          [],
    );
  }
}

class SelectedVariant {
  final int id;
  final String sku;
  final double price;
  final int stock;
  final List<String> images; // Solo guardaremos las URLs
  final List<Feature> features;

  SelectedVariant({
    required this.id,
    required this.sku,
    required this.price,
    required this.stock,
    required this.images,
    required this.features,
  });

  factory SelectedVariant.fromJson(Map<String, dynamic> json) {
    return SelectedVariant(
      id: json['id'] ?? 0,
      sku: json['sku'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      stock: json['stock'] ?? 0,
      // Mapeamos images: [{"url": "..."}] -> ["..."]
      images:
          (json['images'] as List?)
              ?.map((img) => img['url'].toString())
              .toList() ??
          [],
      features:
          (json['features'] as List?)
              ?.map((x) => Feature.fromJson(x))
              .toList() ??
          [],
    );
  }
}

class Feature {
  final int id;
  final String option; // Ej: Color
  final String type; // Ej: color
  final String value; // Ej: #ffffff
  final String description;

  Feature({
    required this.id,
    required this.option,
    required this.type,
    required this.value,
    required this.description,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id'] ?? 0,
      option: json['option'] ?? '',
      type: json['type'] ?? '',
      value: json['value'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

// Para la lista de variantes (las bolitas de colores)
class VariantOption {
  final int id;
  final List<Feature> features;

  VariantOption({required this.id, required this.features});

  factory VariantOption.fromJson(Map<String, dynamic> json) {
    return VariantOption(
      id: json['id'] ?? 0,
      features:
          (json['features'] as List?)
              ?.map((x) => Feature.fromJson(x))
              .toList() ??
          [],
    );
  }
}

class Spec {
  final String name;
  final String value;
  Spec({required this.name, required this.value});

  factory Spec.fromJson(Map<String, dynamic> json) {
    return Spec(name: json['name'] ?? '', value: json['value'] ?? '');
  }
}
