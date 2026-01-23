import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// --- VIEW MODELS & CONTROLLERS ---
import 'package:anttec_movil/app/ui/layout/view_models/layout_home_viewmodel.dart';
import 'package:anttec_movil/app/ui/product/controllers/products_controller.dart';

// --- WIDGETS ---
import 'package:anttec_movil/app/ui/layout/widgets/home/header_home_w.dart';
import 'package:anttec_movil/app/ui/layout/widgets/home/search_w.dart';
import 'package:anttec_movil/app/ui/layout/widgets/home/category_filter_w.dart';
import 'package:anttec_movil/app/ui/layout/widgets/home/section_title_w.dart';
import 'package:anttec_movil/app/ui/product/screen/products_grid.dart';

class ProductsScreen extends StatefulWidget {
  final String token;
  const ProductsScreen({super.key, required this.token});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

// 🔥 1. AGREGAMOS EL MIXIN AQUÍ
class _ProductsScreenState extends State<ProductsScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // 🔥 2. ACTIVAMOS EL "MANTENER VIVO"
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 3. OBLIGATORIO LLAMAR A SUPER.BUILD
    super.build(context);

    final layoutModel = context.watch<LayoutHomeViewmodel>();

    return ChangeNotifierProvider(
      create: (_) => ProductsController(token: widget.token),
      child: Consumer<ProductsController>(
        builder: (context, controller, _) {
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200 &&
                  !controller.loading &&
                  controller.page < controller.lastPage) {
                controller.nextPage();
              }
              return false;
            },
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      HeaderHomeW(
                        profileName: layoutModel.profileName ?? '',
                        logout: () async {
                          final success = await layoutModel.logout();
                          if (success && context.mounted) {
                            context.goNamed('login');
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SearchW(controller: _searchController),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: CategoryFilterW(
                          categories: layoutModel.categories,
                          brands: layoutModel.brands,
                          onFilterChanged: (int? categoryId, int? brandId) {
                            controller.applyFilters(
                              category: categoryId,
                              brand: brandId,
                            );
                          },
                        ),
                      ),
                      const SectionTitleW(),
                    ],
                  ),
                ),
                Expanded(child: _buildProductContent(controller)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductContent(ProductsController controller) {
    if (controller.loading && controller.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null && controller.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(controller.error!, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => controller.fetchProducts(newPage: 1),
              child: const Text("Reintentar"),
            ),
          ],
        ),
      );
    }

    if (controller.products.isEmpty) {
      return const Center(child: Text('No hay productos disponibles.'));
    }

    return ProductGrid(
      products: controller.products,
      scrollController: _scrollController,
      isLoadingMore: controller.loading && controller.products.isNotEmpty,
    );
  }
}
