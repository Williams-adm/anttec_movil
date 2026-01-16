// lib/routing/router.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:anttec_movil/routing/routes.dart';

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

// Finalizar venta (tu nueva vista)
import 'package:anttec_movil/app/ui/sales/finalizar_venta_page.dart';

GoRouter router() => GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      name: 'splash',
      builder: (BuildContext context, GoRouterState state) => SplashScreen(),
    ),
    GoRoute(
      path: Routes.login,
      name: 'login',
      builder: (BuildContext context, GoRouterState state) => LoginScreen(
        viewModel: LoginViewModel(authRepository: context.read()),
      ),
    ),

    // Shell principal con LayoutScreen
    ShellRoute(
      builder: (context, state, child) => LayoutScreen(content: child),
      routes: [
        // HOME + hijos (envueltos en LayoutHomeScreen)
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

            // Nueva ruta: Finalizar venta
            GoRoute(
              path: Routes.finalizarVenta,
              name: 'finalizar-venta',
              builder: (context, state) => const FinalizarVentaPage(),
            ),
          ],
        ),

        // Carrito, fuera del ShellRoute de Home
        GoRoute(
          path: Routes.cart,
          name: 'cart',
          builder: (context, state) => const CartScreen(),
        ),

        // Otras páginas envueltas por LayoutPagesScreen
        ShellRoute(
          builder: (context, state, child) {
            final title = state.extra is Map<String, dynamic>
                ? (state.extra as Map<String, dynamic>)['title'] ?? ''
                : 'No title';
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
