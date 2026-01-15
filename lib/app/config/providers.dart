import 'package:anttec_movil/data/repositories/auth/auth_repository.dart';
import 'package:anttec_movil/data/repositories/auth/auth_respository_remote.dart';
import 'package:anttec_movil/data/repositories/category/category_repository.dart';
import 'package:anttec_movil/data/repositories/category/category_repository_remote.dart';
import 'package:anttec_movil/data/services/api/v1/auth_service.dart';
import 'package:anttec_movil/data/services/api/v1/category_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// --- IMPORTAMOS EL PROVIDER DEL CARRITO ---
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';

List<SingleChildWidget> get providersRemote {
  return [
    // 1. Servicios Base
    Provider<AuthService>(create: (_) => AuthService()),
    Provider<AuthRepository>(
      create: (context) => AuthRespositoryRemote(authService: context.read()),
    ),

    Provider<CategoryService>(create: (_) => CategoryService()),
    Provider<CategoryRepository>(
      create: (context) =>
          CategoryRepositoryRemote(categoryService: context.read()),
    ),

    // 2. NUEVO: Provider Global del Carrito
    // Usamos ChangeNotifierProvider porque necesita redibujar la UI cuando cambia
    ChangeNotifierProvider(create: (_) => CartProvider()),
  ];
}
