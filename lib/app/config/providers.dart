import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// --- SERVICIOS Y REPOSITORIOS (DATA LAYER) ---
import 'package:anttec_movil/data/services/api/v1/auth_service.dart';
import 'package:anttec_movil/data/repositories/auth/auth_repository.dart';
import 'package:anttec_movil/data/repositories/auth/auth_respository_remote.dart';

import 'package:anttec_movil/data/services/api/v1/category_service.dart';
import 'package:anttec_movil/data/repositories/category/category_repository.dart';
import 'package:anttec_movil/data/repositories/category/category_repository_remote.dart';

// --- VIEWMODELS Y PROVIDERS (UI LAYER) ---
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';
import 'package:anttec_movil/app/ui/layout/view_models/layout_home_viewmodel.dart';

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

    // 2. Carrito
    ChangeNotifierProvider(create: (_) => CartProvider()),

    // 3. ViewModel Global del Home (CORREGIDO) ✅
    ChangeNotifierProvider<LayoutHomeViewmodel>(
      create: (context) => LayoutHomeViewmodel(
        authRepository: context.read<AuthRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
      )
        // 🔥 AQUÍ ESTÁ EL CAMBIO: Llamamos a tus métodos existentes
        ..loadProfile()
        ..loadCategories(),
    ),
  ];
}
