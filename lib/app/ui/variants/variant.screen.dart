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

  // Función para corregir URLs locales (Emulador)
  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return 'https://via.placeholder.com/300';
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
    return ChangeNotifierProvider(
      create: (_) =>
          VariantController(productId: productId, variantId: initialVariantId),
      child: Scaffold(
        backgroundColor: Colors.white,
        // AppBar sencillo con botón de atrás
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
            // 1. Estado de Carga
            if (controller.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            // 2. Estado de Error
            if (controller.error != null) {
              return Center(child: Text(controller.error!));
            }
            // 3. Estado Vacío
            if (controller.product == null) {
              return const Center(child: Text("Producto no encontrado"));
            }

            final data = controller.product!;
            final variant = data.selectedVariant;
            final mainImage = variant.images.isNotEmpty
                ? variant.images.first
                : null;

            return Column(
              children: [
                // ---------------------------------------------------------
                // A. CONTENIDO SCROLLABLE (Imagen + Info)
                // ---------------------------------------------------------
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
                              // Imagen Centrada
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
                              // Precio Flotante
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
                              // Marca y Nombre
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

                              // Selector de Colores (Variantes)
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
                                    // Buscamos la característica de tipo "color"
                                    final colorFeature = vOption.features
                                        .firstWhere(
                                          (f) => f.type == 'color',
                                          orElse: () => Feature(
                                            id: 0,
                                            option: '',
                                            type: '',
                                            value: '#cccccc', // Default gris
                                            description: '',
                                          ),
                                        );

                                    final isSelected = vOption.id == variant.id;
                                    // Convertimos hex string (#ff0000) a int (0xff0000)
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

                              const SizedBox(
                                height: 40,
                              ), // Espacio extra al final
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---------------------------------------------------------
                // B. BOTÓN AGREGAR AL CARRITO (Fijo abajo)
                // ---------------------------------------------------------
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      // Solo habilitado si hay stock
                      onPressed: variant.stock > 0
                          ? () {
                              // AQUÍ VA LA LÓGICA DE AGREGAR AL CARRITO
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Agregado: ${data.name} - S/. ${variant.price}",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // Color principal
                        foregroundColor: Colors.white, // Color texto/icono
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text(
                        variant.stock > 0 ? "Agregar al Carrito" : "Agotado",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
