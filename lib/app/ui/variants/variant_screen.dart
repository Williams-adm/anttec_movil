import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:anttec_movil/app/ui/variants/controllers/variant_controller.dart';
import 'widgets/product_image_gallery.dart';
import 'widgets/color_selector.dart';
import 'widgets/quantity_selector.dart';

class VariantScreen extends StatefulWidget {
  final int productId;
  final int initialVariantId;

  const VariantScreen({
    super.key,
    required this.productId,
    required this.initialVariantId,
  });

  @override
  State<VariantScreen> createState() => _VariantScreenState();
}

class _VariantScreenState extends State<VariantScreen> {
  int _quantity = 1;
  final PageController _pageController = PageController();
  final Color _primaryColor = const Color(0xFF7E33A3);

  // Corrección de URLs para desarrollo local vs producción
  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/300';
    }
    if (url.contains('192.168.1.4') ||
        url.contains('localhost') ||
        url.contains('anttec-back.test')) {
      return url.replaceAll(
        RegExp(r'http://[^/]+'),
        'https://anttec-back-master-gicfjw.laravel.cloud',
      );
    }
    return url;
  }

  // 🔥 LA SOLUCIÓN AL PROBLEMA DE "HOME VACÍO"
  void _safeExit() {
    // 1. Ocultamos teclado si estaba abierto
    FocusScope.of(context).unfocus();

    // 2. Lógica inteligente
    if (context.canPop()) {
      // ✅ Si hay historial (viniste del Home), volvemos suavemente.
      // Esto NO recarga el Home, solo quita esta pantalla de encima.
      context.pop();
    } else {
      // ⚠️ Si no hay historial (ej. notificación push), forzamos ir al inicio.
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VariantController(
        productId: widget.productId,
        variantId: widget.initialVariantId,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,

        // Interceptamos el botón "Atrás" físico de Android/Gestos de iOS
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _safeExit(); // Usamos nuestra lógica segura
          },
          child: Consumer<VariantController>(
            builder: (context, controller, _) {
              // 1. Estados de Carga y Error
              if (controller.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.error != null) {
                return _buildErrorState(context, controller.error!);
              }
              if (controller.product == null) {
                return _buildErrorState(context, "Producto no encontrado");
              }

              // 2. Datos del Producto
              final data = controller.product!;
              final variant = data.selectedVariant;

              final String brandName = data.brand.toUpperCase();
              final String productName = data.name;
              final String sku = variant.sku;
              final String description = data.description;
              final double price = variant.price;

              // Lógica de stock visual
              _updateQuantityLogic(variant);
              final int currentDisplayedStock =
                  (variant.stock > 0) ? (variant.stock - _quantity) : 0;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // --- IMAGEN Y CABECERA ---
                  SliverAppBar(
                    expandedHeight: 400,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    pinned: true,
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                          ),
                          onPressed: _safeExit, // 👈 Botón corregido
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: ProductImageGallery(
                        images: variant.images,
                        pageController: _pageController,
                        fixUrl: _fixImageUrl,
                      ),
                    ),
                  ),

                  // --- DETALLES DEL PRODUCTO ---
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Marca y SKU
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  brandName.isEmpty ? "ANTTEC" : brandName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryColor,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "SKU: $sku",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Nombre
                          Text(
                            productName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Precio y Stock
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "S/. ${price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: _primaryColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "$currentDisplayedStock disponibles",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: currentDisplayedStock < 5
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          // Selector de Color
                          Row(
                            children: [
                              const Text(
                                "Color:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: ColorSelector(
                                  variants: data.variants,
                                  selectedId: variant.id,
                                  primaryColor: _primaryColor,
                                  onVariantSelected: (id) {
                                    controller.changeVariant(id);
                                    setState(() {
                                      _quantity = 1;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          // Selector de Cantidad
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Cantidad",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              QuantitySelector(
                                quantity: _quantity,
                                stock: variant.stock,
                                primaryColor: _primaryColor,
                                onIncrement: () {
                                  if (_quantity < variant.stock) {
                                    setState(() => _quantity++);
                                  }
                                },
                                onDecrement: () {
                                  if (_quantity > 1) {
                                    setState(() => _quantity--);
                                  }
                                },
                                onAddToCart: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Agregado $_quantity de $productName",
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Descripción
                          const Text(
                            "Descripción",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Pantalla de error simple con botón de salida segura
  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _safeExit,
        ),
      ),
      body: Center(child: Text(message)),
    );
  }

  // Lógica para que la cantidad no supere el stock al cambiar variantes
  void _updateQuantityLogic(dynamic variant) {
    if (variant.stock <= 0) {
      if (_quantity != 0) {
        _quantity = 0;
      }
    } else {
      if (_quantity == 0) {
        _quantity = 1;
      }
      if (_quantity > variant.stock) {
        _quantity = variant.stock;
      }
    }
  }
}
