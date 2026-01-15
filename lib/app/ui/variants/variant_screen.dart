import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anttec_movil/app/ui/variants/controllers/variant_controller.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_detail_response.dart';

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

  void _incrementQuantity(int maxStock) {
    if (_quantity < maxStock) {
      setState(() => _quantity++);
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
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

            final data = controller.product!;
            final variant = data.selectedVariant;
            final List<String> images = variant.images.isNotEmpty
                ? variant.images
                : [''];

            if (_quantity > variant.stock && variant.stock > 0) {
              _quantity = variant.stock;
            } else if (variant.stock == 0) {
              _quantity = 0;
            } else if (_quantity == 0 && variant.stock > 0) {
              _quantity = 1;
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

                  SizedBox(
                    height: 280,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  _fixImageUrl(images[index]),
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.broken_image,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (images.length > 1)
                          Positioned.fill(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _navButton(Icons.arrow_back_ios_new, () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }),
                                _navButton(Icons.arrow_forward_ios, () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }),
                              ],
                            ),
                          ),
                      ],
                    ),
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

                  const Text(
                    "Color",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: data.variants.map((vOption) {
                      final colorFeature = vOption.features.firstWhere(
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
                      final colorHex = colorFeature.value.replaceAll(
                        '#',
                        '0xff',
                      );
                      final colorInt = int.tryParse(colorHex);

                      return GestureDetector(
                        onTap: () {
                          controller.changeVariant(vOption.id);
                          setState(() => _quantity = 1);
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorInt != null
                                ? Color(colorInt)
                                : Colors.grey,
                            border: Border.all(
                              color: isSelected
                                  ? _primaryColor
                                  : Colors.black12,
                              width: isSelected ? 3 : 1,
                            ),
                            // CORRECCIÓN: withValues en lugar de withOpacity
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _primaryColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 20,
                                  color: (colorInt == 0xffffffff)
                                      ? Colors.black
                                      : Colors.white,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
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
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _qtyBtn(
                              Icons.remove,
                              variant.stock > 0 ? _decrementQuantity : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Text(
                                "$_quantity",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _qtyBtn(
                              Icons.add,
                              variant.stock > 0
                                  ? () => _incrementQuantity(variant.stock)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: variant.stock > 0
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Agregado $_quantity de ${data.name}",
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              variant.stock > 0
                                  ? "Agregar al carrito"
                                  : "Agotado",
                            ),
                          ),
                        ),
                      ),
                    ],
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

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: CircleAvatar(
        // CORRECCIÓN: withValues en lugar de withOpacity
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        child: Icon(icon, size: 18, color: Colors.black),
      ),
      onPressed: onTap,
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback? onPressed) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 45, minHeight: 45),
    );
  }
}
