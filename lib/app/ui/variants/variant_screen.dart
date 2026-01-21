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
  final Color _primaryColor = const Color(0xFF7E33A3);

  String _fixImageUrl(String? url) {
    // ✅ Corrección 1: Agregadas llaves {}
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
            // ✅ Corrección 2: Agregadas llaves {} a los estados de carga
            if (controller.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.error != null) {
              return _buildErrorState(context, controller.error!);
            }
            if (controller.product == null) {
              return _buildErrorState(context, "Producto no encontrado");
            }

            // Datos listos
            final data = controller.product!;
            final variant = data.selectedVariant;

            _updateQuantityLogic(variant);

            final int currentDisplayedStock = (variant.stock > 0)
                ? (variant.stock - _quantity)
                : 0;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // --- BARRA SUPERIOR ---
                SliverAppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  pinned: false,
                  floating: true,
                  snap: true,
                  centerTitle: false,
                  systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
                    statusBarColor: Colors.transparent,
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: const Text(
                    "Detalle del producto",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                // --- CONTENIDO ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${data.brand.toUpperCase()} - ${data.name}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),

                        ProductImageGallery(
                          images: variant.images,
                          pageController: _pageController,
                          fixUrl: _fixImageUrl,
                        ),

                        const SizedBox(height: 20),
                        Text(
                          "SKU: ${variant.sku}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Selector de Color alineado
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Color:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 15),
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Stock: $currentDisplayedStock",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "S/. ${variant.price.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),
                        const Text(
                          "Cantidad",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        QuantitySelector(
                          quantity: _quantity,
                          stock: variant.stock,
                          primaryColor: _primaryColor,
                          onIncrement: () {
                            // ✅ Corrección 3: Agregadas llaves {}
                            if (_quantity < variant.stock) {
                              setState(() => _quantity++);
                            }
                          },
                          onDecrement: () {
                            // ✅ Corrección 4: Agregadas llaves {}
                            if (_quantity > 1) {
                              setState(() => _quantity--);
                            }
                          },
                          onAddToCart: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Agregado $_quantity de ${data.name}",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),
                        const Text(
                          "Descripción",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.5,
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

  Widget _buildErrorState(BuildContext context, String message) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        SliverFillRemaining(child: Center(child: Text(message))),
      ],
    );
  }

  void _updateQuantityLogic(dynamic variant) {
    if (variant.stock <= 0) {
      // ✅ Corrección 5: Agregadas llaves {}
      if (_quantity != 0) {
        _quantity = 0;
      }
    } else {
      // ✅ Corrección 6: Agregadas llaves {}
      if (_quantity == 0) {
        _quantity = 1;
      }
      if (_quantity > variant.stock) {
        _quantity = variant.stock;
      }
    }
  }
}
