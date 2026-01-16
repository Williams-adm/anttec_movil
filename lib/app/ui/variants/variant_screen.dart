import 'package:flutter/material.dart';
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
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
              icon: const Icon(Icons.close, color: Colors.black, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Consumer<VariantController>(
          builder: (context, controller, _) {
            if (controller.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.error != null) {
              return Center(child: Text(controller.error!));
            }
            if (controller.product == null) {
              return const Center(child: Text("Producto no encontrado"));
            }

            // Usamos '!' para indicar que estamos seguros que no son nulos tras las validaciones
            final data = controller.product!;
            final variant = data.selectedVariant;

            // Sincronización de cantidad con el stock de la variante seleccionada
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

            final int currentDisplayedStock = (variant.stock > 0)
                ? (variant.stock - _quantity)
                : 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

                  // Galería de Imágenes (Widget separado)
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

                  // Selector de Color (Widget separado)
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Selector de Cantidad y Botón (Widget separado)
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
                          content: Text("Agregado $_quantity de ${data.name}"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Descripción",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
