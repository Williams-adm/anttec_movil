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

class _ProductsScreenState extends State<ProductsScreen> {
  // Controlador para el scroll infinito (se pasa al GridView)
  final ScrollController _scrollController = ScrollController();
  // Controlador para el buscador
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos del Layout (Perfil, Categorías, Marcas) que vienen del padre
    final layoutModel = context.watch<LayoutHomeViewmodel>();

    return ChangeNotifierProvider(
      create: (_) => ProductsController(token: widget.token),
      child: Consumer<ProductsController>(
        builder: (context, controller, _) {
          // USAMOS NotificationListener: Es la forma limpia de detectar el scroll
          // sin necesidad de agregar listeners manuales ni pelear con el contexto.
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              // Si estamos haciendo scroll y llegamos al final (menos 200 pixeles)
              if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200 &&
                  !controller.loading &&
                  controller.page < controller.lastPage) {
                // Pedimos la siguiente página
                controller.nextPage();
              }
              return false; // Dejamos que el scroll siga funcionando normal
            },
            child: Column(
              children: [
                // ---------------------------------------------------------
                // 1. ZONA DE CABECERA (Header, Buscador, Categorías)
                // ---------------------------------------------------------
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      // Header (Perfil + Logout)
                      HeaderHomeW(
                        profileName: layoutModel.profileName ?? '',
                        logout: () async {
                          final success = await layoutModel.logout();
                          if (success && context.mounted) {
                            context.goNamed('login');
                          }
                        },
                      ),

                      // Buscador
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SearchW(controller: _searchController),
                      ),

                      // Filtro de Categorías y Marcas
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: CategoryFilterW(
                          categories: layoutModel.categories,
                          // --- AQUÍ ESTABA EL ERROR ---
                          // Agregamos las marcas que vienen del layoutModel
                          brands: layoutModel.brands,
                        ),
                      ),

                      // Título de Sección "Productos"
                      const SectionTitleW(),
                    ],
                  ),
                ),

                // ---------------------------------------------------------
                // 2. LISTA DE PRODUCTOS (GRID)
                // ---------------------------------------------------------
                Expanded(child: _buildProductContent(controller)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductContent(ProductsController controller) {
    // 1. Cargando inicial
    if (controller.loading && controller.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error
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

    // 3. Vacío
    if (controller.products.isEmpty) {
      return const Center(child: Text('No hay productos disponibles.'));
    }

    // 4. Grid con Scroll Infinito
    return ProductGrid(
      products: controller.products,
      scrollController: _scrollController,
      isLoadingMore: controller.loading && controller.products.isNotEmpty,
    );
  }
}
