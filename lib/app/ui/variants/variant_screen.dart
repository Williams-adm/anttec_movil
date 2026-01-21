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

  // 🔥 SALIDA SEGURA Y LIMPIA
  void _safeExit() {
    // 1. Mensaje visual para confirmar acción
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🔄 Volviendo al inicio..."),
        duration: Duration(milliseconds: 500),
        backgroundColor: Colors.black87,
      ),
    );

    // 2. Navegación segura
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        try {
          context.go('/home');
        } catch (e) {
          // Si falla, intentamos login como respaldo
          context.go('/login');
        }
      }
    });
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

        // Bloqueamos la salida nativa
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            _safeExit();
          },
          child: Consumer<VariantController>(
            builder: (context, controller, _) {
              if (controller.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.error != null) {
                return _buildErrorState(context, controller.error!);
              }
              if (controller.product == null) {
                return _buildErrorState(context, "Producto no encontrado");
              }

              final data = controller.product!;
              final variant = data.selectedVariant;

              // ✅ CORREGIDO: Sin signos '??' innecesarios
              final String brandName = data.brand.toUpperCase();
              final String productName = data.name;
              final String sku = variant.sku;
              final String description = data.description;
              final double price = variant.price;

              _updateQuantityLogic(variant);
              final int currentDisplayedStock = (variant.stock > 0)
                  ? (variant.stock - _quantity)
                  : 0;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
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
                          onPressed: _safeExit,
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
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          Text(
                            productName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
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
