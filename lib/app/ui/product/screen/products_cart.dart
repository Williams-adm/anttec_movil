import 'package:flutter/material.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_response.dart';
// Importamos la pantalla de detalle
import 'package:anttec_movil/app/ui/variants/variant.screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  // --- FUNCIÓN PARA CORREGIR URLS LOCALES ---
  // Convierte 'anttec-back.test' o 'localhost' a la IP del emulador (10.0.2.2)
  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/150';
    }

    if (url.contains('anttec-back.test')) {
      return url.replaceAll('anttec-back.test', '10.0.2.2:8000');
    }
    if (url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2:8000');
    }

    return url;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _fixImageUrl(product.imageUrl);

    // Lógica para saber si hay descuento
    final hasDiscount =
        (product.oldPrice != null && product.oldPrice! > product.price);

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        // --- NAVEGACIÓN ---
        onTap: () {
          // Usamos push normal para mantener la barra inferior visible
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VariantScreen(
                productId: product.id,
                initialVariantId: 1, // Por defecto vamos a la variante 1
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- IMAGEN DEL PRODUCTO ---
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Si falla la carga (ej. servidor apagado)
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 80,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    );
                  },
                  // Loading mientras descarga
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 80,
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // --- MARCA ---
              Text(
                product.brand.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),

              // --- NOMBRE ---
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // --- STOCK ---
              Text(
                'Stock: ${product.stock}',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 2),

              // --- PRECIOS ---
              hasDiscount
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'S/. ${product.oldPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'S/. ${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'S/. ${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
