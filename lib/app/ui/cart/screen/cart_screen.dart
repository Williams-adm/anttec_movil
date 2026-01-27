import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // 🔥 FORZAR CARGA DE DATOS AL ENTRAR
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para escuchar cambios
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        // 1. Cargando...
        if (cartProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Carrito Vacío
        if (cartProvider.items.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mi Carrito')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text("Tu carrito está vacío",
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        // Botón de depuración para intentar recargar manual
                        cartProvider.fetchCart();
                      },
                      child: const Text("Recargar"))
                ],
              ),
            ),
          );
        }

        // 3. Lista de Productos
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi Carrito'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                onPressed: () => cartProvider.clearCart(),
              )
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: item.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Icon(Icons.image),
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                        title: Text(item.name),
                        subtitle: Text("${item.quantity} x S/. ${item.price}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () => cartProvider.removeItem(item.id!),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Total y Botón Pagar
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total: S/. ${cartProvider.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Pagar"),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
