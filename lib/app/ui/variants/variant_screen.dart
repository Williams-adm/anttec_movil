import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:anttec_movil/app/ui/variants/controllers/variant_controller.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';
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
  bool _isAddingToCart = false;

  final PageController _pageController = PageController();
  final Color _primaryColor = const Color(0xFF7E33A3);

  @override
  void dispose() {
    // ✅ CORRECCIÓN FINAL: Solo limpiamos el controller.
    // Quitamos la línea de ScaffoldMessenger que causaba el crash al salir.
    _pageController.dispose();
    super.dispose();
  }

  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/300';
    }
    if (url.contains('127.0.0.1') || url.contains('localhost')) {
      return url.replaceAll('http://localhost', 'http://10.0.2.2');
    }
    return url;
  }

  void _safeExit() {
    FocusScope.of(context).unfocus();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _handleAddToCart(dynamic variant, String productName) async {
    if (_quantity <= 0) return;
    if (_isAddingToCart) return;

    setState(() => _isAddingToCart = true);

    try {
      final success = await context.read<CartProvider>().addItem(
            productId: widget.productId,
            variantId: variant.id,
            quantity: _quantity,
          );

      if (!mounted) return;

      if (success) {
        _showSuccessSnackBar(variant, productName);
      } else {
        final errorMsg =
            context.read<CartProvider>().errorMessage ?? "Error al agregar";
        _showErrorSnackBar(errorMsg);
      }
    } catch (e) {
      debugPrint("💥 ERROR UI ADD: $e");
      _showErrorSnackBar("Ocurrió un error inesperado.");
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  void _showSuccessSnackBar(dynamic variant, String productName) {
    String? imageUrl;
    try {
      if (variant.images != null && variant.images.isNotEmpty) {
        final firstImage = variant.images[0];
        if (firstImage is String) {
          imageUrl = _fixImageUrl(firstImage);
        } else {
          imageUrl = _fixImageUrl((firstImage as dynamic).url);
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.contain,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? Icon(Icons.check_circle, color: _primaryColor, size: 24)
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
                  Text("$_quantity x $productName",
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
                if (mounted) {
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
              child: Text("VER",
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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
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
              final String brandName = data.brand.toUpperCase();
              final String productName = data.name;
              final String sku = variant.sku;
              final String description = data.description;
              final double price = variant.price;

              _updateQuantityLogic(variant);
              final int currentDisplayedStock =
                  (variant.stock > 0) ? (variant.stock - _quantity) : 0;

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
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.black87),
                          onPressed: _safeExit,
                        ),
                      ),
                    ),
                    actions: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined,
                                color: Colors.black),
                            onPressed: () => context.goNamed('cart'),
                          ),
                          Positioned(
                            right: 5,
                            top: 5,
                            child: Consumer<CartProvider>(
                              builder: (_, cart, __) => cart.itemCount > 0
                                  ? Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${cart.itemCount}',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 10),
                                      ),
                                    )
                                  : const SizedBox(),
                            ),
                          )
                        ],
                      )
                    ],
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
                          horizontal: 24, vertical: 30),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(30)),
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
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
                                    fontSize: 12, color: Colors.grey),
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
                          const Text("Color:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          ColorSelector(
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
                          const SizedBox(height: 25),
                          const Text("Cantidad",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
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
                            onAddToCart: _isAddingToCart
                                ? () {}
                                : () => _handleAddToCart(variant, productName),
                          ),
                          if (_isAddingToCart)
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Center(child: LinearProgressIndicator()),
                            ),
                          const SizedBox(height: 30),
                          const Text("Descripción",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(
                            description,
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700]),
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
      if (_quantity != 0) _quantity = 0;
    } else {
      if (_quantity == 0) _quantity = 1;
      if (_quantity > variant.stock) _quantity = variant.stock;
    }
  }
}
