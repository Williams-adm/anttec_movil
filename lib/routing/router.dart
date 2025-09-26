import 'package:anttec_movil/app/ui/auth/login/screen/login_screen.dart';
import 'package:anttec_movil/app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:anttec_movil/app/ui/home/screen/home_screen.dart';
import 'package:anttec_movil/app/ui/layout/screen/layout_home_screen.dart';
import 'package:anttec_movil/app/ui/layout/screen/layout_pages_screen.dart';
import 'package:anttec_movil/app/ui/layout/screen/layout_screen.dart';
import 'package:anttec_movil/app/ui/layout/view_models/layout_home_viewmodel.dart';
import 'package:anttec_movil/app/ui/scan/screen/scan_screen.dart';
import 'package:anttec_movil/app/ui/splash/screen/splash_screen.dart';
import 'package:anttec_movil/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter router() => GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      name: 'splash',
      builder: (BuildContext context, GoRouterState state) {
        return SplashScreen();
      },
    ),
    GoRoute(
      path: Routes.login,
      name: 'login',
      builder: (BuildContext context, GoRouterState state) {
        return LoginScreen(
          viewModel: LoginViewmodel(authRepository: context.read()),
        );
      },
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) =>
          LayoutScreen(content: child),
      routes: [
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) =>
              LayoutHomeScreen(
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
              builder: (BuildContext context, GoRouterState state) {
                return HomeScreen();
              },
            ),
          ],
        ),
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            final title = state.extra is Map<String, dynamic>
                ? (state.extra as Map<String, dynamic>)['title'] ?? ''
                : 'No title';
            return LayoutPagesScreen(title: title, content: child);
          },
          routes: [
            GoRoute(
              path: Routes.scan,
              name: 'scan',
              builder: (BuildContext context, GoRouterState state) {
                return ScanScreen();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
