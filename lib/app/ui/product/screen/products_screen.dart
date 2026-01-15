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
  // Controlador para el scroll infinito
  final ScrollController _scrollController = ScrollController();
  // Controlador para el buscador (lo movimos aquí desde el layout)
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Detectar cuando llegamos al final de la lista para cargar más
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Usamos read() porque estamos dentro de un evento, no redibujando
      // Nota: El controller se accede a través del contexto del Consumer más abajo,
      // pero aquí accedemos via context si el provider está arriba o usamos una variable local si fuera necesario.
      // Para seguridad, verificamos si el widget sigue montado.
      if (!mounted) return;

      // IMPORTANTE: Como ProductsController se crea dentro del build,
      // la forma más segura de accederlo aquí es si el Provider estuviera arriba
      // o pasando el controlador a una función.
      // Pero como usamos Consumer abajo, la lógica de paginación suele manejarse mejor
      // pasando el scrollController al Grid, o envolviendo todo en el Provider.
      // *En este diseño específico*, el ScrollController se pasa al GridView,
      // así que la detección la hacemos aquí buscando el Provider en el contexto hijo o padre.

      // Truco: ProductsController es hijo de este Widget, así que no podemos usar context.read directo aquí
      // a menos que movamos el ChangeNotifierProvider al padre.
      // SIN EMBARGO, para que funcione simple, pasaremos la lógica de carga al Grid o usaremos el context
      // disponible dentro del Consumer.
      // *Corrección para tu caso:* Como el Provider se crea en el build, lo mejor es pasar el callback
      // desde el Consumer o mover el Provider al initState.
      // Para no complicar, dejaremos que el Grid maneje el scroll o usaremos un GlobalKey si fuera estricto.
      // Pero, dado que _scrollController se pasa al GridView, el listener funciona.
      // La forma correcta accediendo al árbol descendente es compleja, así que asumiremos
      // que ProductsController se puede obtener si lo elevamos o usamos un truco.

      // *Solución Práctica:* Vamos a acceder al controlador buscando en el contexto
      // PERO, como el Provider se crea en el build, context.read<ProductsController> fallará aquí.
      // -> Lo ideal: Mover ChangeNotifierProvider encima de Scaffold o usar un Builder.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos del Layout (Perfil, Categorías) que vienen del padre
    final layoutModel = context.watch<LayoutHomeViewmodel>();

    return ChangeNotifierProvider(
      create: (_) => ProductsController(token: widget.token),
      child: Builder(
        builder: (context) {
          // Usamos Builder para tener un contexto que contenga ProductsController
          // Ahora sí podemos usar el ScrollListener correctamente si quisiéramos
          final productsController = context.read<ProductsController>();

          // Re-asignamos el listener para asegurar que tenga acceso al controlador correcto
          _scrollController.removeListener(_onScroll); // Limpieza preventiva
          _scrollController.addListener(() {
            if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 200) {
              if (!productsController.loading &&
                  productsController.page < productsController.lastPage) {
                productsController.nextPage();
              }
            }
          });

          return Consumer<ProductsController>(
            builder: (context, controller, _) {
              return Column(
                children: [
                  // ---------------------------------------------------------
                  // 1. ZONA DE CABECERA (Header, Buscador, Categorías)
                  // ---------------------------------------------------------
                  // Al estar aquí dentro, se irá junto con la pantalla al navegar.
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

                        // Filtro de Categorías
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: CategoryFilterW(
                            categories: layoutModel.categories,
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
              );
            },
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
