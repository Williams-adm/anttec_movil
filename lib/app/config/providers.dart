import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ✅ Cambiado de SharedPreferences

// Repositorios
import 'package:anttec_movil/data/services/api/v1/auth_service.dart';
import 'package:anttec_movil/data/repositories/auth/auth_repository.dart';
import 'package:anttec_movil/data/repositories/auth/auth_respository_remote.dart';
import 'package:anttec_movil/data/services/api/v1/category_service.dart';
import 'package:anttec_movil/data/repositories/category/category_repository.dart';
import 'package:anttec_movil/data/repositories/category/category_repository_remote.dart';
import 'package:anttec_movil/app/ui/cart/repositories/cart_repository.dart';

// ViewModels
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';
import 'package:anttec_movil/app/ui/layout/view_models/layout_home_viewmodel.dart';
import 'package:anttec_movil/app/ui/sales_report/viewmodel/sales_report_viewmodel.dart';
import 'package:anttec_movil/app/ui/auth/login/view_models/login_viewmodel.dart';

List<SingleChildWidget> get providersRemote {
  return [
    // =============================================================
    // 0. CLIENTE HTTP (Dio) con SecureStorage
    // =============================================================
    Provider<Dio>(
      create: (_) {
        final dio = Dio(BaseOptions(
          baseUrl: 'https://anttec-back-master-gicfjw.laravel.cloud/api/v1',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ));

        dio.interceptors
            .add(InterceptorsWrapper(onRequest: (options, handler) async {
          // ✅ USAMOS SECURE STORAGE PARA QUE COINCIDA CON EL LOGIN
          const storage = FlutterSecureStorage();
          final token = await storage.read(key: 'auth_token');

          if (kDebugMode) {
            debugPrint(
                "🔑 Interceptor: Token ${token != null ? 'encontrado' : 'NULO'}");
          }

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        }, onError: (DioException e, handler) {
          if (kDebugMode) {
            debugPrint(
                "❌ Error DIO [${e.response?.statusCode}]: ${e.requestOptions.path}");
          }
          return handler.next(e);
        }));

        return dio;
      },
    ),

    // =============================================================
    // 1. Servicios y Repositorios
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
    Provider<CartRepository>(
      create: (context) => CartRepository(context.read<Dio>()),
    ),

    // =============================================================
    // 2. ViewModels / Providers de UI
    // =============================================================

    // Login (Agregado para que sea global)
    ChangeNotifierProvider<LoginViewModel>(
      create: (context) =>
          LoginViewModel(authRepository: context.read<AuthRepository>()),
    ),

    // Carrito
    ChangeNotifierProvider<CartProvider>(
      create: (context) => CartProvider(context.read<CartRepository>()),
    ),

    // Home
    ChangeNotifierProvider<LayoutHomeViewmodel>(
      create: (context) => LayoutHomeViewmodel(
        authRepository: context.read<AuthRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
      )
        ..loadProfile()
        ..loadCategories(),
    ),

    ChangeNotifierProvider<SalesReportViewmodel>(
      create: (_) => SalesReportViewmodel(),
    ),
  ];
}
