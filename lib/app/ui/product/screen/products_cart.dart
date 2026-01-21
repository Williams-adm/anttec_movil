import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_response.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return 'https://via.placeholder.com/150';
    if (url.contains('anttec-back.test') ||
        url.contains('localhost') ||
        url.contains('10.0.2.2')) {
      return url.replaceAll(
        RegExp(r'http://[^/]+'),
        'https://anttec-back-master-gicfjw.laravel.cloud',
      );
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _fixImageUrl(product.imageUrl);
    final isOutOfStock = product.stock <= 0;
    const accentColor = Color(0xFF7E33A3);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (product.defaultVariantId == null) return;

                  // Datos para el Router
                  final Map<String, dynamic> productData = {
                    'id': product.id,
                    'selected_variant': {'id': product.defaultVariantId},
                  };

                  context.pushNamed(
                    'product_detail',
                    pathParameters: {'sku': product.id.toString()},
                    extra: productData,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // IMAGEN
                      Expanded(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // MARCA (Corregido: sin ??)
                      Text(
                        product.brand.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // NOMBRE
                      Text(
                        product.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // PRECIO
                      if (isOutOfStock)
                        const Text(
                          "AGOTADO",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        )
                      else
                        Text(
                          'S/. ${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
