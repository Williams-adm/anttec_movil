// products_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anttec_movil/app/ui/product/controllers/products_controller.dart';
import 'package:anttec_movil/app/ui/product/screen/products_grid.dart';

class ProductsScreen extends StatelessWidget {
  final String token;
  const ProductsScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductsController(token: token),
      child: Consumer<ProductsController>(
        builder: (context, controller, _) {
          if (controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error != null) {
            return Center(child: Text(controller.error!));
          }
          if (controller.products.isEmpty) {
            return const Center(child: Text('No hay productos disponibles.'));
          }
          return ProductGrid(products: controller.products);
        },
      ),
    );
  }
}
