import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';

// Importamos nuestros widgets separados
import 'package:anttec_movil/app/ui/cart/widgets/cart_constants.dart';
import 'package:anttec_movil/app/ui/cart/widgets/cart_item_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
  }

  void _showClearCartConfirmation(BuildContext context, CartProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Vaciar carrito?"),
        content: const Text("Se eliminarán todos los productos de tu lista."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              provider.clearCart();
              Navigator.pop(ctx);
            },
            child: const Text("Sí, vaciar",
                style: TextStyle(
                    color: AppColors.deleteRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            if (cartProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (cartProvider.items.isEmpty) {
              return _buildEmptyState(cartProvider);
            }

            return Column(
              children: [
                // --- Cabecera ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    children: [
                      const Text(
                        'Resumen de venta',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_forever,
                            size: 28, color: AppColors.deleteRed),
                        onPressed: () =>
                            _showClearCartConfirmation(context, cartProvider),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close,
                            size: 30, color: AppColors.textDark),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // --- Lista de Productos (Usando el Widget separado) ---
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: cartProvider.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      // ✅ Aquí usamos nuestro componente limpio
                      return CartItemCard(item: item, provider: cartProvider);
                    },
                  ),
                ),

                // --- Botones Inferiores ---
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightPurple,
                            foregroundColor: AppColors.textDark,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Añadir más\nproductos',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.pushNamed('checkout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkPurple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Finalizar\nventa',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(CartProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text("Tu carrito está vacío",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => provider.fetchCart(),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPurple,
                foregroundColor: Colors.white),
            child: const Text("Recargar"),
          )
        ],
      ),
    );
  }
}
