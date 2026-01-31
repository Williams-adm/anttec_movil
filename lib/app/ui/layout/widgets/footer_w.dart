import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class FooterW extends StatelessWidget {
  const FooterW({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos la ruta actual para saber qué botón pintar de color
    final String? currentRouteName = GoRouterState.of(context).name;

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Divider(thickness: 2, color: Color(0xFFBDBDBD), height: 0),
        ),
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 1. BOTÓN IZQUIERDO: HOME
                  IconButton(
                    onPressed: () {
                      if (currentRouteName != 'home') {
                        context.goNamed('home');
                      }
                    },
                    icon: Icon(
                      Symbols.home,
                      size: 48.0,
                      // Si estamos en home, se pinta del color primario
                      color: currentRouteName == 'home'
                          ? AppColors.primaryP
                          : Colors.black54,
                    ),
                  ),

                  // ESPACIO PARA EL BOTÓN CENTRAL (SCANNER)
                  const SizedBox(width: 90.0),

                  // 2. BOTÓN DERECHO: AHORA ES REPORTES / HISTORIAL
                  IconButton(
                    onPressed: () {
                      // Navegamos a la nueva pantalla de reportes
                      if (currentRouteName != 'reports') {
                        context.goNamed('reports');
                      }
                    },
                    // Cambiamos el icono a uno de analítica o lista
                    icon: Icon(
                      Symbols.analytics, // O puedes usar Symbols.receipt_long
                      size: 48.0,
                      // Si estamos en reports, se pinta del color primario
                      color: currentRouteName == 'reports'
                          ? AppColors.primaryP
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // BOTÓN FLOTANTE: SCANNER (Se mantiene igual)
        Positioned(
          top: -20,
          child: ElevatedButton(
            onPressed: () {
              if (currentRouteName != 'scan') {
                context.goNamed('scan', extra: {'title': 'Escanear'});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryP,
              padding: const EdgeInsets.all(12.0),
              shape: const CircleBorder(),
            ),
            child: Icon(
              Symbols.barcode_scanner,
              color: AppColors.primaryS,
              size: 48.0,
            ),
          ),
        ),
      ],
    );
  }
}
