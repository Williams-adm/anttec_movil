// En lib/app/ui/variants/variant.screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anttec_movil/app/ui/variants/controllers/variant_controller.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_detail_response.dart';

class VariantScreen extends StatelessWidget {
  final int productId;
  final int initialVariantId;

  const VariantScreen({
    super.key,
    required this.productId,
    this.initialVariantId = 1,
  });

  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return 'https://via.placeholder.com/300';
    if (url.contains('anttec-back.test'))
      return url.replaceAll('anttec-back.test', '10.0.2.2:8000');
    if (url.contains('localhost'))
      return url.replaceAll('localhost', '10.0.2.2:8000');
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          VariantController(productId: productId, variantId: initialVariantId),
      child: Scaffold(
        backgroundColor: Colors.white,
        // AppBar sencillo
        appBar: AppBar(
          title: const Text(
            "Detalle",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<VariantController>(
          builder: (context, controller, _) {
            if (controller.loading)
              return const Center(child: CircularProgressIndicator());
            if (controller.error != null)
              return Center(child: Text(controller.error!));
            if (controller.product == null)
              return const Center(child: Text("Producto no encontrado"));

            final data = controller.product!;
            final variant = data.selectedVariant;
            final mainImage = variant.images.isNotEmpty
                ? variant.images.first
                : null;

            return Column(
              children: [
                // Usamos Expanded para que la info ocupe todo el espacio disponible
                // (respetando tu barra inferior original que aparecerá abajo)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 1. ZONA VISUAL (IMAGEN) ---
                        Container(
                          width: double.infinity,
                          height: 350,
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xffD9D9D9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Image.network(
                                    _fixImageUrl(mainImage),
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_not_supported,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 15,
                                right: 15,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "S/. ${variant.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- 2. INFORMACIÓN ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      data.brand.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      data.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 25),

                              // Colores
                              if (data.variants.isNotEmpty) ...[
                                const Text(
                                  "Colores disponibles:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: data.variants.map((vOption) {
                                    final colorFeature = vOption.features
                                        .firstWhere(
                                          (f) => f.type == 'color',
                                          orElse: () => Feature(
                                            id: 0,
                                            option: '',
                                            type: '',
                                            value: '#cccccc',
                                            description: '',
                                          ),
                                        );
                                    final isSelected = vOption.id == variant.id;
                                    final colorHex = colorFeature.value
                                        .replaceAll('#', '0xff');
                                    final colorInt = int.tryParse(colorHex);

                                    return GestureDetector(
                                      onTap: () =>
                                          controller.changeVariant(vOption.id),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colorInt != null
                                              ? Color(colorInt)
                                              : Colors.grey,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.blueAccent
                                                : Colors.transparent,
                                            width: isSelected ? 3 : 1,
                                          ),
                                          boxShadow: [
                                            if (isSelected)
                                              const BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 6,
                                                offset: Offset(0, 3),
                                              ),
                                          ],
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 20,
                                              )
                                            : null,
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 25),
                              ],

                              // Descripción
                              const Text(
                                "Descripción",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data.description,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  height: 1.5,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 40), // Espacio final
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // --- ❌ AQUÍ HE ELIMINADO LA BARRA INFERIOR FALSA ---
                // Al no haber nada aquí, Flutter mostrará el fondo del Scaffold
                // y tu barra de navegación principal (la morada) seguirá visible abajo.
              ],
            );
          },
        ),
      ),
    );
  }
}
