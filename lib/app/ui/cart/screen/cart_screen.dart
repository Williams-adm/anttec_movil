import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppColors {
  static const Color background = Color(0xFFF8F9FD);
  static const Color darkPurple = Color(0xFF7A2E85);
  static const Color lightPurple = Color(0xFFEBCDF0);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color deleteRed = Color(0xFFE74C3C);
  static const Color qtyBackground = Color(0xFFE0E0E0);
}

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

  // Función para mostrar alerta antes de vaciar todo
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
              provider.clearCart(); // Llama a la API de borrar todo
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

            // 2. Estado Vacío
            if (cartProvider.items.isEmpty) {
              return _buildEmptyState(cartProvider);
            }

            // 3. Contenido Principal
            return Column(
              children: [
                // --- Cabecera con Tacho Global ---
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
                        tooltip: "Vaciar carrito",
                        icon: const Icon(Icons.delete_forever,
                            size: 28, color: AppColors.deleteRed),
                        onPressed: () =>
                            _showClearCartConfirmation(context, cartProvider),
                      ),

                      const SizedBox(width: 8),

                      // Botón Cerrar (CORREGIDO)
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

                // --- Lista de Productos ---
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: cartProvider.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return _buildProductCard(context, item, cartProvider);
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
                            // CORREGIDO: Bloques if con llaves
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
                          onPressed: () {
                            context.pushNamed('checkout');
                          },
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

  Widget _buildProductCard(
      BuildContext context, dynamic item, CartProvider provider) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 🗑️ BOTÓN 2: ELIMINAR SOLO ESTE ITEM
              InkWell(
                onTap: () {
                  // Llama a la API de eliminar un solo item
                  provider.removeItem(item.id!);
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Icon(Icons.delete_outline,
                      color: AppColors.deleteRed, size: 26),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 100,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: CachedNetworkImage(
                  imageUrl: item.image ?? "",
                  fit: BoxFit.contain,
                  placeholder: (_, __) =>
                      const Icon(Icons.image, color: Colors.grey),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            color: AppColors.textDark, fontSize: 16),
                        children: [
                          const TextSpan(
                              text: 'Precio  ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: 'S/. ${item.price}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Cantidad',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _qtyButton(Icons.remove, () {
                          if (item.quantity > 1) {
                            provider.updateItem(item.id!, item.quantity - 1);
                          }
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                        ),
                        _qtyButton(Icons.add, () {
                          provider.updateItem(item.id!, item.quantity + 1);
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.qtyBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppColors.textDark),
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
