import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VariantUtils {
  static const Color _primaryColor = Color(0xFF7E33A3);

  // Corregir URL de imágenes (localhost)
  static String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/300';
    }
    if (url.contains('127.0.0.1') || url.contains('localhost')) {
      return url.replaceAll('http://localhost', 'http://10.0.2.2');
    }
    return url;
  }

  // Mostrar SnackBar de Error
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Mostrar SnackBar de Éxito (Diseño Profesional)
  static void showSuccess(BuildContext context,
      {required dynamic variant,
      required String productName,
      required int quantity}) {
    String? imageUrl;
    try {
      if (variant.images != null && variant.images.isNotEmpty) {
        final firstImage = variant.images[0];
        if (firstImage is String) {
          imageUrl = fixImageUrl(firstImage);
        } else {
          imageUrl = fixImageUrl((firstImage as dynamic).url);
        }
      }
    } catch (e) {
      debugPrint("⚠️ Error imagen SnackBar: $e");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl), fit: BoxFit.contain)
                    : null,
              ),
              child: imageUrl == null
                  ? const Icon(Icons.check_circle,
                      color: _primaryColor, size: 24)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Agregado al carrito",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Text("$quantity x $productName",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                // Verificamos si el widget sigue montado antes de navegar
                if (context.mounted) {
                  context.goNamed('cart');
                }
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: _primaryColor.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("VER",
                  style: TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            )
          ],
        ),
      ),
    );
  }
}
