import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

// --- ESTILOS ---
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/core/styles/titles.dart';

// --- COMPONENTES Y PROVIDERS ---
import 'package:anttec_movil/app/ui/layout/widgets/home/profile_w.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';
import 'package:anttec_movil/routing/routes.dart';

class HeaderHomeW extends StatelessWidget {
  final String profileName;
  final VoidCallback logout;

  const HeaderHomeW({
    super.key,
    required this.profileName,
    required this.logout,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 ESCUCHAMOS AL CART PROVIDER
    // context.watch hace que el Header se redibuje cada vez que el carrito cambie
    final cart = context.watch<CartProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- SECCIÓN IZQUIERDA: BIENVENIDA ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "¡Hola, bienvenido!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profileName,
                  style: AppTitles.h2.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),

          // --- SECCIÓN DERECHA: ACCIONES ---
          Row(
            children: [
              // Botón Carrito con Badge Reactivo
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    onPressed: () => context.push(Routes.cart),
                    icon: const Icon(
                      Symbols.shopping_cart_rounded,
                      size: 30,
                      color: AppColors.darkT,
                    ),
                  ),

                  // El Badge solo se muestra si hay items > 0
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryP,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),

              // Widget de Perfil (Avatar y Menú de Logout)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: ProfileW(logout: logout),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
