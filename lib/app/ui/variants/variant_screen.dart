import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:anttec_movil/app/ui/variants/controllers/variant_controller.dart';
// Importamos los widgets locales
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

  // Color principal (Morado Anttec)
  final Color _primaryColor = const Color(0xFF7E33A3);

  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/300';
    }
    // Ajuste para emuladores/local
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VariantController(
        productId: widget.productId,
        variantId: widget.initialVariantId,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<VariantController>(
          builder: (context, controller, _) {
            // --- 1. ESTADOS DE CARGA ---
            if (controller.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            // --- 2. MANEJO DE ERRORES ---
            if (controller.error != null) {
              return _buildErrorState(context, controller.error!);
            }
            if (controller.product == null) {
              return _buildErrorState(context, "Producto no encontrado");
            }

            // --- 3. DATOS ---
            final data = controller.product!;
            final variant = data.selectedVariant;

            // ✅ CORRECCIÓN 1: Eliminamos los '??' porque tus datos ya son no-nulos
            final String brandName = data.brand.toUpperCase();
            final String productName = data.name;
            final String sku = variant.sku;
            final String description = data.description;
            final double price = variant.price;

            // Lógica stock
            _updateQuantityLogic(variant);

            final int currentDisplayedStock = (variant.stock > 0)
                ? (variant.stock - _quantity)
                : 0;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // --- HEADER: IMAGEN GRANDE ---
                SliverAppBar(
                  expandedHeight: 400,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  pinned: true,
                  floating: false,
                  systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
                    statusBarColor: Colors.transparent,
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      // ✅ CORRECCIÓN 2: Uso de withValues en lugar de withOpacity
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black87,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: ProductImageGallery(
                      images: variant.images, // Eliminado el '?? []'
                      pageController: _pageController,
                      fixUrl: _fixImageUrl,
                    ),
                  ),
                ),

                // --- CONTENIDO: PANEL DESLIZANTE ---
                SliverToBoxAdapter(
                  child: Container(
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
                        ),
                      ],
                    ),
                    transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // A. MARCA Y SKU
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                // ✅ CORRECCIÓN 2: Uso de withValues
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
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // B. TÍTULO
                        Text(
                          productName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // C. PRECIO Y STOCK
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "S/. ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: price.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: _primaryColor,
                                    ),
                                  ),
                                ],
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),
                        const Divider(height: 1),
                        const SizedBox(height: 25),

                        // D. SELECCIÓN DE COLOR
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Color:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
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

                        // E. CANTIDAD Y BOTÓN AGREGAR
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Cantidad",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
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
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // F. DESCRIPCIÓN
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
                            height: 1.6,
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
    );
  }

  // --- Helpers ---

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
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
