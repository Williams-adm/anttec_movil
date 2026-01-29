import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/routing/routes.dart';

// Imports de pantallas
import 'package:anttec_movil/app/ui/splash/screen/splash_screen.dart';
import 'package:anttec_movil/app/ui/auth/login/screen/login_screen.dart';
import 'package:anttec_movil/app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:anttec_movil/app/ui/home/screen/home_screen.dart';

// Layouts
import 'package:anttec_movil/app/ui/layout/screen/layout_screen.dart';
import 'package:anttec_movil/app/ui/layout/screen/layout_home_screen.dart';

import 'package:anttec_movil/app/ui/scan/screen/scan_screen.dart';
import 'package:anttec_movil/app/ui/cart/screen/cart_screen.dart';

// Pantallas de Checkout
import 'package:anttec_movil/app/ui/checkout/checkout_screen.dart';
import 'package:anttec_movil/app/ui/checkout/boleta/boleta_screen.dart'; // ✅ Importada
import 'package:anttec_movil/app/ui/checkout/factura/factura_screen.dart'; // ✅ Importada

import 'package:anttec_movil/app/ui/variants/screen/variant_screen.dart';
import 'package:anttec_movil/app/ui/chat/screen/chat_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter router() => GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: Routes.splash,
      debugLogDiagnostics: true,
      routes: [
        // ===========================================================
        // 1. NIVEL RAÍZ (Pantallas completas sin menú inferior)
        // ===========================================================
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
        GoRoute(
          path: '/chat',
          name: 'chat',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ChatScreen(),
        ),

        // ✅ PRODUCTO
        GoRoute(
          path: '/producto/:sku',
          name: 'product_detail',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final Map<String, dynamic>? data =
                state.extra as Map<String, dynamic>?;

            if (data == null) {
              return const Scaffold(
                  body: Center(child: Text("Error de datos")));
            }
            return VariantScreen(
              productId: data['id'],
              initialVariantId: data['selected_variant'] != null
                  ? data['selected_variant']['id']
                  : 0,
            );
          },
        ),

        // ✅ FINALIZAR VENTA (SELECTOR)
        GoRoute(
          path: '/checkout',
          name: 'checkout',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const CheckoutScreen(),
        ),

        // ✅ RUTA ESPECÍFICA BOLETA
        GoRoute(
          path: '/boleta',
          name: 'boleta',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const BoletaScreen(),
        ),

        // ✅ RUTA ESPECÍFICA FACTURA
        GoRoute(
          path: '/factura',
          name: 'factura',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const FacturaScreen(),
        ),

        // ✅ SCANNER
        GoRoute(
          path: Routes.scan,
          name: 'scan',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ScanScreen(),
        ),

        // ===========================================================
        // 2. SHELL ROUTE (Pantallas con menú inferior)
        // ===========================================================
        ShellRoute(
          builder: (context, state, child) => LayoutScreen(content: child),
          routes: [
            ShellRoute(
              builder: (context, state, child) =>
                  LayoutHomeScreen(content: child),
              routes: [
                GoRoute(
                  path: Routes.home,
                  name: 'home',
                  builder: (context, state) => HomeScreen(),
                ),
              ],
            ),
            GoRoute(
              path: Routes.cart,
              name: 'cart',
              builder: (context, state) => const CartScreen(),
            ),
          ],
        ),
      ],
    );
