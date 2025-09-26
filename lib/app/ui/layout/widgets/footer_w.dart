import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class FooterW extends StatelessWidget {
  const FooterW({super.key});

  @override
  Widget build(BuildContext context) {
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
                  IconButton(
                    onPressed: () {
                      if (currentRouteName != 'home') {
                        context.goNamed('home');
                      }
                    },
                    icon: Icon(Symbols.home, size: 48.0),
                  ),
                  const SizedBox(width: 90.0), // espacio para el botón central
                  IconButton(
                    onPressed: () {
                      if (currentRouteName != 'sale') {
                        context.goNamed('sale');
                      }
                    },
                    icon: Icon(Symbols.order_approve, size: 48.0),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              padding: EdgeInsets.all(12.0),
              shape: CircleBorder(),
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
