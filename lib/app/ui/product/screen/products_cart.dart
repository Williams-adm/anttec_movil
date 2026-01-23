import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_response.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  // Corrección de URLs para que se vean las imágenes en el emulador/celular
  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    // Si la URL viene de localhost o IP local, la cambiamos por la nube o IP accesible
    if (url.contains('anttec-back.test') ||
        url.contains('localhost') ||
        url.contains('127.0.0.1') ||
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
    const accentColor = Color(0xFF7E33A3); // Morado Anttec

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
                // -------------------------------------------------------
                // 🔥 AQUÍ ESTÁ LA MAGIA DE LA NAVEGACIÓN
                // -------------------------------------------------------
                onTap: () {
                  if (product.defaultVariantId == null) return;

                  // Preparamos los datos mínimos para la siguiente pantalla
                  final Map<String, dynamic> productData = {
                    'id': product.id,
                    'selected_variant': {'id': product.defaultVariantId},
                  };

                  // ✅ USAMOS pushNamed (NO 'go')
                  // Esto apila la pantalla, manteniendo el Home vivo debajo.
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
                      // --- 1. IMAGEN DEL PRODUCTO ---
                      Expanded(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          // Si la imagen falla, mostramos un icono gris
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // --- 2. MARCA ---
                      Text(
                        product.brand.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // --- 3. NOMBRE DEL PRODUCTO ---
                      Text(
                        product.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow:
                            TextOverflow.ellipsis, // Pone "..." si es muy largo
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // --- 4. PRECIO O AVISO DE AGOTADO ---
                      if (isOutOfStock)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "AGOTADO",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
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
