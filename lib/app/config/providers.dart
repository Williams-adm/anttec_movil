import 'package:flutter/foundation.dart'; // ✅ Necesario para debugPrint
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- SERVICIOS Y REPOSITORIOS (DATA LAYER) ---
import 'package:anttec_movil/data/services/api/v1/auth_service.dart';
import 'package:anttec_movil/data/repositories/auth/auth_repository.dart';
import 'package:anttec_movil/data/repositories/auth/auth_respository_remote.dart';

import 'package:anttec_movil/data/services/api/v1/category_service.dart';
import 'package:anttec_movil/data/repositories/category/category_repository.dart';
import 'package:anttec_movil/data/repositories/category/category_repository_remote.dart';

// Importar el nuevo Repositorio de Carrito
import 'package:anttec_movil/app/ui/cart/repositories/cart_repository.dart';

// --- VIEWMODELS Y PROVIDERS (UI LAYER) ---
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';
import 'package:anttec_movil/app/ui/layout/view_models/layout_home_viewmodel.dart';

List<SingleChildWidget> get providersRemote {
  return [
    // =============================================================
    // 0. CLIENTE HTTP (Dio)
    // =============================================================
    Provider<Dio>(
      create: (_) {
        final dio = Dio(BaseOptions(
          // ✅ URL DE PRODUCCIÓN (La que funciona en la nube)
          baseUrl: 'https://anttec-back-master-gicfjw.laravel.cloud/api/v1',

          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ));

        // 🔥 INTERCEPTOR
        dio.interceptors
            .add(InterceptorsWrapper(onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');

          // ✅ CORREGIDO: Usamos debugPrint en lugar de print
          if (kDebugMode) {
            debugPrint(
                "🔑 Token en interceptor: ${token != null ? 'Presente' : 'Nulo'}");
          }

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        }, onError: (DioException e, handler) {
          // ✅ CORREGIDO: Usamos debugPrint en lugar de print
          if (kDebugMode) {
            debugPrint(
                "❌ Error DIO Global: ${e.response?.statusCode} - ${e.message}");
          }
          return handler.next(e);
        }));

        return dio;
      },
    ),

    // =============================================================
    // 1. Servicios y Repositorios Base
    // =============================================================
    Provider<AuthService>(create: (_) => AuthService()),
    Provider<AuthRepository>(
      create: (context) => AuthRespositoryRemote(authService: context.read()),
    ),

    Provider<CategoryService>(create: (_) => CategoryService()),
    Provider<CategoryRepository>(
      create: (context) =>
          CategoryRepositoryRemote(categoryService: context.read()),
    ),

    // =============================================================
    // 2. Repositorio de Carrito
    // =============================================================
    Provider<CartRepository>(
      create: (context) => CartRepository(context.read<Dio>()),
    ),

    // =============================================================
    // 3. Providers de UI
    // =============================================================

    // ✅ Carrito
    ChangeNotifierProvider<CartProvider>(
      create: (context) => CartProvider(context.read<CartRepository>()),
    ),

    // ✅ ViewModel Global del Home
    ChangeNotifierProvider<LayoutHomeViewmodel>(
      create: (context) => LayoutHomeViewmodel(
        authRepository: context.read<AuthRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
      )
        ..loadProfile()
        ..loadCategories(),
    ),
  ];
}
