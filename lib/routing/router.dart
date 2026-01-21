// lib/routing/router.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Rutas constantes
import 'package:anttec_movil/routing/routes.dart';

// Importaciones de Auth y Splash
import 'package:anttec_movil/app/ui/splash/screen/splash_screen.dart';
import 'package:anttec_movil/app/ui/auth/login/screen/login_screen.dart';
import 'package:anttec_movil/app/ui/auth/login/view_models/login_viewmodel.dart';

// Importaciones de Home y Layouts
import 'package:anttec_movil/app/ui/home/screen/home_screen.dart';
import 'package:anttec_movil/app/ui/layout/screen/layout_screen.dart';
import 'package:anttec_movil/app/ui/layout/screen/layout_home_screen.dart';
import 'package:anttec_movil/app/ui/layout/screen/layout_pages_screen.dart';
import 'package:anttec_movil/app/ui/layout/view_models/layout_home_viewmodel.dart';

// Importaciones de otras pantallas
import 'package:anttec_movil/app/ui/scan/screen/scan_screen.dart';
import 'package:anttec_movil/app/ui/cart/screen/cart_screen.dart';
import 'package:anttec_movil/app/ui/sales/finalizar_venta_page.dart';

// ✅ IMPORTACIÓN DE TU NUEVA PANTALLA DE VARIANTE
// (Asegúrate de que este archivo esté en esta ruta o ajústala)
import 'package:anttec_movil/app/ui/variants/variant_screen.dart';

GoRouter router() => GoRouter(
  initialLocation: Routes.splash,
  routes: [
    // --- SPLASH ---
    GoRoute(
      path: Routes.splash,
      name: 'splash',
      builder: (BuildContext context, GoRouterState state) => SplashScreen(),
    ),

    // --- LOGIN ---
    GoRoute(
      path: Routes.login,
      name: 'login',
      builder: (BuildContext context, GoRouterState state) => LoginScreen(
        viewModel: LoginViewModel(authRepository: context.read()),
      ),
    ),

    // --- SHELL PRINCIPAL (Layout General) ---
    ShellRoute(
      builder: (context, state, child) => LayoutScreen(content: child),
      routes: [
        // --- SUB-SHELL: HOME (Barra de navegación inferior visible) ---
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

        // --- PÁGINAS INDEPENDIENTES (Dentro del Shell Principal pero sin NavBar) ---
        GoRoute(
          path: Routes.cart,
          name: 'cart',
          builder: (context, state) => const CartScreen(),
        ),

        // --- SUB-SHELL: PÁGINAS INTERNAS (Con botón "Atrás" en la AppBar) ---
        ShellRoute(
          builder: (context, state, child) {
            // Lógica para título dinámico
            String title = '';

            // Si el objeto extra tiene un campo 'title', úsalo.
            // Si no, verificamos si es el JSON del producto para poner su nombre.
            if (state.extra is Map<String, dynamic>) {
              final extraMap = state.extra as Map<String, dynamic>;
              title = extraMap['title'] ?? extraMap['name'] ?? '';
            }
            return LayoutPagesScreen(title: title, content: child);
          },
          routes: [
            // Escáner
            GoRoute(
              path: Routes.scan,
              name: 'scan',
              builder: (context, state) => ScanScreen(),
            ),

            // ✅ DETALLE DE PRODUCTO (VariantScreen)
            GoRoute(
              path: '/producto/:sku',
              name: 'product_detail',
              builder: (context, state) {
                // 1. Recibimos el JSON completo desde el ScanScreen
                final Map<String, dynamic>? data =
                    state.extra as Map<String, dynamic>?;

                // Validación de seguridad
                if (data == null) {
                  return const Scaffold(
                    body: Center(
                      child: Text(
                        "Error: No se cargaron los datos del producto.",
                      ),
                    ),
                  );
                }

                // 2. Extraemos los IDs necesarios para VariantScreen
                // Estructura JSON API: { "id": 1, "selected_variant": { "id": 2 }, ... }
                final int productId = data['id'];
                final int initialVariantId = data['selected_variant']['id'];

                // 3. Retornamos la pantalla configurada
                return VariantScreen(
                  productId: productId,
                  initialVariantId: initialVariantId,
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
