import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:anttec_movil/routing/routes.dart';

// Imports de pantallas
import 'package:anttec_movil/app/ui/splash/screen/splash_screen.dart';
import 'package:anttec_movil/app/ui/auth/login/screen/login_screen.dart';
import 'package:anttec_movil/app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:anttec_movil/app/ui/home/screen/home_screen.dart';
import 'package:anttec_movil/app/ui/layout/screen/layout_screen.dart';
import 'package:anttec_movil/app/ui/layout/screen/layout_home_screen.dart';
import 'package:anttec_movil/app/ui/layout/screen/layout_pages_screen.dart';
import 'package:anttec_movil/app/ui/layout/view_models/layout_home_viewmodel.dart';
import 'package:anttec_movil/app/ui/scan/screen/scan_screen.dart';
import 'package:anttec_movil/app/ui/cart/screen/cart_screen.dart';
import 'package:anttec_movil/app/ui/sales/finalizar_venta_page.dart';

// ✅ CORRECCIÓN 1: Ruta ajustada (sin carpeta 'screens')
// Si esto sigue marcando error, escribe "import '" y deja que el autocompletado busque 'VariantScreen'
import 'package:anttec_movil/app/ui/variants/variant_screen.dart';

GoRouter router() => GoRouter(
  initialLocation: Routes.splash,
  debugLogDiagnostics: true,
  routes: [
    // 1. PANTALLAS INDEPENDIENTES (NIVEL RAÍZ)
    GoRoute(
      path: Routes.splash,
      name: 'splash',
      builder: (context, state) => SplashScreen(),
    ),

    GoRoute(
      path: Routes.login,
      name: 'login',
      builder: (context, state) => LoginScreen(
        viewModel: LoginViewModel(authRepository: context.read()),
      ),
    ),

    // 🔥 DETALLE DEL PRODUCTO (Raíz)
    GoRoute(
      path: '/producto/:sku',
      name: 'product_detail',
      builder: (context, state) {
        final Map<String, dynamic>? data = state.extra as Map<String, dynamic>?;

        // ✅ CORRECCIÓN 2: Agregadas las llaves { } al if
        if (data == null) {
          return const Scaffold(body: Center(child: Text("Error de datos")));
        }

        return VariantScreen(
          productId: data['id'],
          initialVariantId: data['selected_variant'] != null
              ? data['selected_variant']['id']
              : 0,
        );
      },
    ),

    // 2. SHELL PRINCIPAL
    ShellRoute(
      builder: (context, state, child) => LayoutScreen(content: child),
      routes: [
        // Home y Ventas
        ShellRoute(
          builder: (context, state, child) => LayoutHomeScreen(
            content: child,
            viewmodel: LayoutHomeViewmodel(
              authRepository: context.read(),
              categoryRepository: context.read(),
            ),
          ),
          routes: [
            GoRoute(
              path: Routes.home,
              name: 'home',
              builder: (context, state) => HomeScreen(),
            ),
            GoRoute(
              path: Routes.finalizarVenta,
              name: 'finalizar-venta',
              builder: (context, state) => const FinalizarVentaPage(),
            ),
          ],
        ),

        // Carrito
        GoRoute(
          path: Routes.cart,
          name: 'cart',
          builder: (context, state) => const CartScreen(),
        ),

        // Páginas internas
        ShellRoute(
          builder: (context, state, child) {
            String title = '';
            if (state.extra is Map<String, dynamic>) {
              title = (state.extra as Map<String, dynamic>)['title'] ?? '';
            }
            return LayoutPagesScreen(title: title, content: child);
          },
          routes: [
            GoRoute(
              path: Routes.scan,
              name: 'scan',
              builder: (context, state) => ScanScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
