import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';

// ✅ IMPORTANTE: Asegúrate de que estos archivos existen en tu proyecto
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
    // Cargamos el carrito al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
  }

  // Alerta para confirmar vaciar todo el carrito
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
            // 1. Estado Cargando
            if (cartProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // --- CABECERA (Siempre visible) ---
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
                      if (cartProvider.items.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.delete_forever,
                              size: 28, color: AppColors.deleteRed),
                          onPressed: () =>
                              _showClearCartConfirmation(context, cartProvider),
                        ),
                      const SizedBox(width: 8),
                      // Botón Cerrar (X)
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

                // --- CONTENIDO CENTRAL ---
                Expanded(
                  // Si está vacío mostramos la tarjeta de diseño, si no, la lista
                  child: cartProvider.items.isEmpty
                      ? _buildEmptyCard(context)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: cartProvider.items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 15),
                          itemBuilder: (context, index) {
                            final item = cartProvider.items[index];
                            // Usamos el widget separado para cada producto
                            return CartItemCard(
                                item: item, provider: cartProvider);
                          },
                        ),
                ),

                // --- BOTONES INFERIORES (Solo si hay productos) ---
                if (cartProvider.items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                    child: Row(
                      children: [
                        // Botón Añadir más
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
                        // Botón Finalizar Venta
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

  // ✨ DISEÑO DE CARRITO VACÍO (Igual a tu imagen)
  Widget _buildEmptyCard(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // Usamos withValues para Flutter moderno (3.27+)
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Se ajusta al tamaño del contenido
          children: [
            const Text(
              "El resumen de ventas se\nencuentra vacío",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 30),

            // Icono / Ilustración del carrito
            const Icon(Icons.shopping_cart_outlined,
                size: 80, color: AppColors.textDark),

            const SizedBox(height: 30),

            // Botón Morado "Agregar productos"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Agregar productos",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
