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
import 'package:anttec_movil/app/ui/layout/screen/layout_pages_screen.dart';

import 'package:anttec_movil/app/ui/scan/screen/scan_screen.dart';
import 'package:anttec_movil/app/ui/cart/screen/cart_screen.dart';
import 'package:anttec_movil/app/ui/sales/finalizar_venta_page.dart';
import 'package:anttec_movil/app/ui/variants/variant_screen.dart';
import 'package:anttec_movil/app/ui/chat/screen/chat_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter router() => GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: Routes.splash,
      debugLogDiagnostics: true,
      routes: [
        // ===========================================================
        // NIVEL RAÍZ (Pantallas completas sin menú inferior)
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

        // ✅ PRODUCTO (Correcto: Está afuera del Shell)
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

        // ✅ FINALIZAR VENTA (MOVIDO AQUÍ)
        // Antes estaba dentro del Shell y causaba el error rojo.
        // Ahora está afuera y funcionará perfecto.
        GoRoute(
          path: Routes.finalizarVenta,
          name: 'finalizar-venta',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const FinalizarVentaPage(),
        ),

        // ===========================================================
        // SHELL ROUTE (Pantallas con menú inferior)
        // ===========================================================
        ShellRoute(
          builder: (context, state, child) => LayoutScreen(content: child),
          routes: [
            // PESTAÑA INICIO
            ShellRoute(
              builder: (context, state, child) =>
                  LayoutHomeScreen(content: child),
              routes: [
                GoRoute(
                  path: Routes.home,
                  name: 'home',
                  builder: (context, state) => HomeScreen(),
                  // ✅ Home limpio sin hijos conflictivos
                ),
                // 🗑️ Aquí borramos finalizar-venta porque ya lo subimos
              ],
            ),

            // PESTAÑA CARRITO
            GoRoute(
              path: Routes.cart,
              name: 'cart',
              builder: (context, state) => const CartScreen(),
            ),

            // PESTAÑA SCAN
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
