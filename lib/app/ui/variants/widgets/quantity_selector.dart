import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int stock;
  final Color primaryColor;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onAddToCart;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.stock,
    required this.primaryColor,
    required this.onIncrement,
    required this.onDecrement,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _btn(Icons.remove, stock > 0 ? onDecrement : null),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "$quantity",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _btn(Icons.add, stock > 0 ? onIncrement : null),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: stock > 0 ? onAddToCart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(stock > 0 ? "Agregar al carrito" : "Agotado"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback? onPressed) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 45, minHeight: 45),
    );
  }
}
