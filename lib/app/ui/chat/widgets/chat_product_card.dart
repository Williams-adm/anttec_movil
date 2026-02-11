import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:anttec_movil/app/ui/variants/repositories/product_repository.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_detail_response.dart';

class ChatProductCard extends StatelessWidget {
  final dynamic product;

  const ChatProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final int productId = product['id'];
    final String name = product['name'] ?? 'Producto';
    final String brand = product['brand'] ?? 'ANTTEC';
    // Usamos la descripción corta del JSON del chat, o una por defecto
    final String description = product['description'] ??
        'Excelente rendimiento para gaming y productividad.';
    final int matchScore = product['match_score'] ?? 0;

    // Extracción de datos
    double price = 0.0;
    String sku = "000";
    int variantId = 0;
    String featureInfo = "";

    if (product['variants'] != null &&
        (product['variants'] as List).isNotEmpty) {
      final firstVariant = product['variants'][0];
      variantId = firstVariant['id'];
      sku = firstVariant['sku'] ?? "000";
      price = double.tryParse(firstVariant['price'].toString()) ?? 0.0;

      if (product['specifications'] != null &&
          (product['specifications'] as List).isNotEmpty) {
        final spec = product['specifications'][0];
        featureInfo = "${spec['name']}: ${spec['value']}";
      }
    }

    final ProductRepository repo = ProductRepository();

    return Container(
      width: 250, // Un poco más ancho para el nuevo diseño
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
          border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. HEADER: Nombre y Match Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      // Color azulado para el título como en el ejemplo
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1.2,
                          color: Color(0xFF1A237E)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      brand,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (matchScore > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9), // Fondo verde claro
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    "$matchScore% match",
                    style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // 2. Feature Pill (DPI)
          if (featureInfo.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(featureInfo,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500)),
            ),

          const SizedBox(height: 12),

          // 3. Imagen (Altura fija para consistencia)
          SizedBox(
            height: 100,
            width: double.infinity,
            child: FutureBuilder<ProductDetailData?>(
              future: repo.getProductVariant(
                  productId, variantId > 0 ? variantId : 1),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data?.selectedVariant.images.isNotEmpty == true) {
                  return CachedNetworkImage(
                    imageUrl: snapshot.data!.selectedVariant.images.first,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    errorWidget: (_, __, ___) =>
                        Icon(Symbols.broken_image, color: Colors.grey[300]),
                  );
                }
                return Center(
                    child:
                        Icon(Symbols.mouse, size: 40, color: Colors.grey[200]));
              },
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.grey[100], height: 1),
          const SizedBox(height: 12),

          // 4. Precio y Botón de Gradiente
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Desde",
                      style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  Text(
                    "S/. ${price.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A237E), // Azul oscuro
                        fontSize: 18),
                  ),
                ],
              ),

              // Botón con Gradiente
              Container(
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4A90E2),
                        Color(0xFF9C27B0)
                      ], // Azul a Morado
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ]),
                child: ElevatedButton(
                  onPressed: () {
                    context.pushNamed('product_detail', pathParameters: {
                      'sku': sku
                    }, extra: {
                      'id': productId,
                      'selected_variant': {'id': variantId}
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .transparent, // Importante para ver el gradiente
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10)),
                  child: const Text("Ver producto",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 5. Descripción final (Cursiva)
          Text(
            description,
            maxLines: 2, // Limitamos a 2 líneas para evitar overflow
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                height: 1.3),
          ),
        ],
      ),
    );
  }
}
