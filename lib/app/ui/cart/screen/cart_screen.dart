import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simula la lista de productos agregados al carrito
    final List products = []; // Cambia por tu lógica real

    if (products.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Resumen de venta'),
          actions: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'El resumen de ventas se encuentra vacío',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Reemplaza esta imagen por tu asset o network
                Image.asset(
                  'assets/img/cart_empty.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8739B1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Por ejemplo, vuelve atrás o navega a productos
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Agregar productos',
                      style: TextStyle(fontSize: 17, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Color(0xFFF8F6FC),
      );
    }

    // Aquí tu código para mostrar los productos cuando SÍ hay elementos en el carrito
    return Scaffold(
      appBar: AppBar(title: Text('Resumen de venta')),
      body: ListView(
        children: [
          // Listar productos
        ],
      ),
    );
  }
}
