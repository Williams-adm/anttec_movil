// app/ui/product/screen/products_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anttec_movil/app/ui/product/controllers/products_controller.dart';
import 'package:anttec_movil/app/ui/product/screen/products_grid.dart';

class ProductsScreen extends StatefulWidget {
  final String token;
  const ProductsScreen({super.key, required this.token});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Detectar cuando llegamos al final de la lista
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Usamos read porque estamos fuera del build
      final controller = context.read<ProductsController>();

      // Solo pedimos siguiente página si no está cargando ya y hay más páginas
      if (!controller.loading && controller.page < controller.lastPage) {
        controller.nextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductsController(token: widget.token),
      child: Consumer<ProductsController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Productos"),
              actions: [
                // Botón de Filtros
                IconButton(
                  icon: const Icon(Icons.tune), // Icono de filtros
                  onPressed: () => _showFiltersModal(context, controller),
                ),
              ],
            ),
            body: _buildBody(controller),
          );
        },
      ),
    );
  }

  Widget _buildBody(ProductsController controller) {
    // 1. Cargando inicial (pantalla completa)
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

    // 3. Lista vacía
    if (controller.products.isEmpty) {
      return const Center(child: Text('No hay productos disponibles.'));
    }

    // 4. Grid con Scroll Infinito
    return ProductGrid(
      products: controller.products,
      scrollController: _scrollController,
      // isLoadingMore es verdadero si está cargando pero YA tenemos productos visualizándose
      isLoadingMore: controller.loading && controller.products.isNotEmpty,
    );
  }

  // --- MODAL DE FILTROS ---
  void _showFiltersModal(BuildContext context, ProductsController controller) {
    // Controladores temporales para los inputs
    final minPriceCtrl = TextEditingController();
    final maxPriceCtrl = TextEditingController();
    // Aquí puedes agregar dropdowns para Marcas o Categorías

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que el modal suba con el teclado
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filtros",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),

              const Text(
                "Rango de Precios (S/.)",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Mínimo",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixText: "S/. ",
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: maxPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Máximo",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixText: "S/. ",
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Botones de Acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearFilters();
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text("Limpiar"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Aplicar lógica
                        controller.applyFilters(
                          minPrice: double.tryParse(minPriceCtrl.text),
                          maxPrice: double.tryParse(maxPriceCtrl.text),
                          // Agrega aquí brand o category si tienes dropdowns
                        );
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blueAccent, // Color de tu marca
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Aplicar Filtros"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
