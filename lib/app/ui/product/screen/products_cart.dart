import 'package:flutter/material.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_response.dart';
import 'package:anttec_movil/app/ui/variants/variant_screen.dart';

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VariantScreen(
                        productId: product.id,
                        initialVariantId: product.defaultVariantId!,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // IMAGEN
                      Expanded(
                        child: ColorFiltered(
                          colorFilter: isOutOfStock
                              ? const ColorFilter.mode(
                                  Colors.grey,
                                  BlendMode.saturation,
                                )
                              : const ColorFilter.mode(
                                  Colors.transparent,
                                  BlendMode.multiply,
                                ),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // INFO
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

                      // PRECIO O ESTADO
                      if (isOutOfStock)
                        const Text(
                          "AGOTADO",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
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

            // --- ESTILO: PÍLDORA FLOTANTE INFERIOR ---
            if (isOutOfStock)
              Positioned(
                bottom: 40, // Flota justo encima del nombre/precio
                left: 15,
                right: 15,
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.layers_outlined,
                        color: Colors.blue.shade700,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Variantes disponibles",
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
