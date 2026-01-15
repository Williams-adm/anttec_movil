import 'package:flutter/material.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_response.dart';

// 1. IMPORTANTE: Asegúrate de que esta ruta apunte a TU archivo (que dijiste que se llama products_cart.dart)
import 'package:anttec_movil/app/ui/product/screen/products_cart.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final ScrollController? scrollController;
  final bool isLoadingMore;

  const ProductGrid({
    super.key,
    required this.products,
    this.scrollController,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final product = products[index];

        // 2. CORRECCIÓN: Aquí debes usar 'ProductCard' (con D), no 'ProductCart'
        return ProductCard(product: product);
      },
    );
  }
}
