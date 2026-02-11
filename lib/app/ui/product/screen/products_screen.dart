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
// ✅ IMPORTANTE: El widget para ver y borrar filtros activos
import 'package:anttec_movil/app/ui/layout/widgets/home/active_filters_w.dart';
import 'package:anttec_movil/app/ui/product/screen/products_grid.dart';

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
              // --- HEADER Y CONTROLES SUPERIORES ---
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    // 1. Header (Perfil / Logout)
                    HeaderHomeW(
                      profileName: layoutModel.profileName ?? '',
                      logout: () async {
                        final success = await layoutModel.logout();
                        if (success && context.mounted) {
                          context.goNamed('login');
                        }
                      },
                    ),

                    // 2. Buscador
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SearchW(
                        controller: _searchController,
                        onChanged: (value) => controller.onSearchChanged(value),
                        onClear: () => controller.clearSearch(),
                      ),
                    ),

                    // 3. Filtro Rápido de Categorías (Scroll horizontal)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CategoryFilterW(
                        categories: layoutModel.categories,
                        brands: layoutModel.brands,
                        onFilterChanged: (int? categoryId, int? brandId) {
                          controller.applyQuickFilter(
                            category: categoryId,
                            brand: brandId,
                          );
                        },
                      ),
                    ),

                    // 4. Título y Botón "Filtros" (Abre el Modal)
                    const SectionTitleW(),

                    // 5. ✅ CHIPS DE FILTROS ACTIVOS (La solución para "salir de filtros")
                    // Esto mostrará las pastillas con "X" cuando apliques precio, marca, etc.
                    const ActiveFiltersW(),
                  ],
                ),
              ),

              // --- GRID DE PRODUCTOS ---
              Expanded(
                child: _buildProductContent(controller),
              ),

              // --- PAGINACIÓN (1-2-3-4) ---
              // Solo se muestra si hay productos y no está cargando
              if (!controller.loading && controller.products.isNotEmpty)
                Container(
                  color: Colors.white,
                  child: PaginationControlsW(
                    currentPage: controller.page,
                    lastPage: controller.lastPage,
                    onPageChanged: (newPage) {
                      // Scroll al inicio suavemente
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
    // Caso: Cargando
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Caso: Error
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

    // Caso: Lista Vacía
    if (controller.products.isEmpty) {
      return const Center(child: Text('No hay productos disponibles.'));
    }

    // Caso: Lista con Datos
    return ProductGrid(
      products: controller.products,
      scrollController: _scrollController,
      isLoadingMore: false, // Paginación clásica no usa infinite scroll
    );
  }
}
