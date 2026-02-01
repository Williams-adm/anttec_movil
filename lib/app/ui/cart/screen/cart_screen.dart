import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/ui/cart/widgets/cart_item_card.dart';
import 'package:material_symbols_icons/symbols.dart';

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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Clear",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle),
                  child: const Icon(Symbols.delete_sweep,
                      color: Colors.red, size: 45),
                ),
                const SizedBox(height: 20),
                const Text("¿Vaciar carrito?",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                const Text("Se eliminarán todos los productos.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                        child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("CANCELAR",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                        provider.clearCart();
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0),
                      child: const Text("SÍ, VACIAR"),
                    )),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryP));
            }

            return Column(
              children: [
                _buildHeader(context, cartProvider),

                // LISTA DE PRODUCTOS
                Expanded(
                  child: cartProvider.items.isEmpty
                      ? _buildEmptyCard(context)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          itemCount: cartProvider.items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) => CartItemCard(
                              item: cartProvider.items[index],
                              provider: cartProvider),
                        ),
                ),

                // ✅ SECCIÓN INFERIOR (TOTAL + BOTONES)
                if (cartProvider.items.isNotEmpty) ...[
                  _buildBottomSummary(context, cartProvider),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CartProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          const Text('Resumen de venta',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.extradarkT)),
          const Spacer(),
          if (provider.items.isNotEmpty) ...[
            IconButton(
                icon: const Icon(Symbols.delete_forever,
                    size: 30, color: Colors.red),
                onPressed: () => _showClearCartConfirmation(context, provider))
          ],
          IconButton(
              icon: const Icon(Symbols.close, size: 32),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              }),
        ],
      ),
    );
  }

  // ✅ NUEVO WIDGET: Muestra el total y los botones
  Widget _buildBottomSummary(BuildContext context, CartProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
        children: [
          // 1. FILA DEL TOTAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total a pagar",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey),
              ),
              Text(
                "S/. ${provider.totalAmount.toStringAsFixed(2)}", // Usa el getter del provider
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.extradarkT),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. BOTONES DE ACCIÓN
          Row(
            children: [
              Expanded(
                  child: OutlinedButton(
                onPressed: () => context.go('/home'),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side:
                        const BorderSide(color: AppColors.primaryP, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: const Text('AÑADIR MÁS',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryP)),
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: ElevatedButton(
                onPressed: () => context.pushNamed('checkout'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryP,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0),
                child: const Text('FINALIZAR',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                  color: AppColors.primaryS, shape: BoxShape.circle),
              child: const Icon(Symbols.shopping_cart_off,
                  size: 80, color: AppColors.primaryP)),
          const SizedBox(height: 24),
          const Text("Tu carrito está vacío",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.extradarkT)),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryP,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text("IR A PRODUCTOS",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
