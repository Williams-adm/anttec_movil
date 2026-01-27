import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Controllers y Providers
import 'package:anttec_movil/app/ui/variants/controllers/variant_controller.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';

// Widgets Refactorizados
import 'package:anttec_movil/app/ui/variants/widgets/product_image_gallery.dart';
import 'package:anttec_movil/app/ui/variants/widgets/variant_info_body.dart';
import 'package:anttec_movil/app/ui/variants/widgets/variant_utils.dart';

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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _safeExit() {
    FocusScope.of(context).unfocus();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  // --- Lógica de Negocio (Agregar al carrito) ---
  Future<void> _handleAddToCart(dynamic variant, String productName) async {
    if (_quantity <= 0 || _isAddingToCart) {
      return;
    }

    setState(() => _isAddingToCart = true);

    try {
      final success = await context.read<CartProvider>().addItem(
            productId: widget.productId,
            variantId: variant.id,
            quantity: _quantity,
          );

      if (!mounted) {
        return;
      }

      if (success) {
        // Usamos la utilidad separada para mostrar éxito
        VariantUtils.showSuccess(context,
            variant: variant, productName: productName, quantity: _quantity);
      } else {
        final errorMsg =
            context.read<CartProvider>().errorMessage ?? "Error al agregar";
        VariantUtils.showError(context, errorMsg);
      }
    } catch (e) {
      debugPrint("💥 ERROR UI ADD: $e");
      if (mounted) {
        VariantUtils.showError(context, "Ocurrió un error inesperado.");
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
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
            if (didPop) {
              return;
            }
            _safeExit();
          },
          child: Consumer<VariantController>(
            builder: (context, controller, _) {
              // 1. Manejo de Estados de Carga/Error
              if (controller.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.error != null) {
                return _buildErrorState(context, controller.error!);
              }
              if (controller.product == null) {
                return _buildErrorState(context, "Producto no encontrado");
              }

              // 2. Preparación de Datos
              final data = controller.product!;
              final variant = data.selectedVariant;

              _updateQuantityLogic(variant);
              final int currentDisplayedStock =
                  (variant.stock > 0) ? (variant.stock - _quantity) : 0;

              // 3. UI Principal
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar con Galería
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
                      _buildCartIconWithBadge(),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: ProductImageGallery(
                        images: variant.images,
                        pageController: _pageController,
                        fixUrl: VariantUtils.fixImageUrl, // Usamos la utilidad
                      ),
                    ),
                  ),

                  // Cuerpo con Detalles (Refactorizado)
                  SliverToBoxAdapter(
                    child: VariantInfoBody(
                      brandName: data.brand.toUpperCase(),
                      sku: variant.sku,
                      productName: data.name,
                      price: variant.price,
                      currentDisplayedStock: currentDisplayedStock,
                      description: data.description,
                      data: data,
                      variant: variant,
                      onVariantSelected: (id) {
                        controller.changeVariant(id);
                        setState(() => _quantity = 1);
                      },
                      quantity: _quantity,
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
                      onAddToCart: () => _handleAddToCart(variant, data.name),
                      isAddingToCart: _isAddingToCart,
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

  // Widget auxiliar para el ícono del carrito
  Widget _buildCartIconWithBadge() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
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
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  )
                : const SizedBox(),
          ),
        )
      ],
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
}
