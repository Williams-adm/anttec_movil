import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// --- VIEW MODELS & CONTROLLERS ---
import 'package:anttec_movil/app/ui/layout/view_models/layout_home_viewmodel.dart';
import 'package:anttec_movil/app/ui/product/controllers/products_controller.dart';

// --- WIDGETS ---
import 'package:anttec_movil/app/ui/layout/widgets/home/header_home_w.dart';
import 'package:anttec_movil/app/ui/layout/widgets/home/search_w.dart';
import 'package:anttec_movil/app/ui/layout/widgets/home/pagination_controls_w.dart';
import 'package:anttec_movil/app/ui/layout/widgets/home/category_filter_w.dart';
import 'package:anttec_movil/app/ui/layout/widgets/home/section_title_w.dart';
import 'package:anttec_movil/app/ui/product/screen/products_grid.dart';
// Importar el nuevo widget de paginación

class ProductsScreen extends StatefulWidget {
  final String token;
  const ProductsScreen({super.key, required this.token});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

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
    super.build(context);

    final layoutModel = context.watch<LayoutHomeViewmodel>();

    return ChangeNotifierProvider(
      create: (_) => ProductsController(token: widget.token),
      child: Consumer<ProductsController>(
        builder: (context, controller, _) {
          return Column(
            children: [
              // --- HEADER Y FILTROS (Igual que antes) ---
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
                      child: SearchW(
                        controller: _searchController,
                        onChanged: (value) => controller.onSearchChanged(value),
                        onClear: () => controller.clearSearch(),
                      ),
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

              // --- CONTENIDO DE PRODUCTOS ---
              Expanded(
                child: _buildProductContent(controller),
              ),

              // 🔥 AQUÍ ESTÁN LOS BOTONES 1-2-3-4 🔥
              // Solo se muestran si no está cargando y hay productos
              if (!controller.loading && controller.products.isNotEmpty)
                Container(
                  color: Colors.white, // Fondo blanco para los botones
                  child: PaginationControlsW(
                    currentPage: controller.page,
                    lastPage: controller.lastPage,
                    onPageChanged: (newPage) {
                      // Al cambiar de página, subimos el scroll al inicio suavemente
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                      controller.changePage(newPage);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductContent(ProductsController controller) {
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
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

    // Grid Normal (sin loader al final porque ahora usamos paginación)
    return ProductGrid(
      products: controller.products,
      scrollController: _scrollController,
      isLoadingMore: false, // Ya no necesitamos loader de scroll infinito
    );
  }
}
