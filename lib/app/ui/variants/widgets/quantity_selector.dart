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
    final bool isOutOfStock = stock <= 0;

    // Usamos IntrinsicHeight para que los botones y el texto tengan la misma altura
    return IntrinsicHeight(
      child: Row(
        children: [
          // --- CONTADOR [- 1 +] ---
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCounterBtn(Icons.remove, onDecrement, quantity > 1),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    "$quantity",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildCounterBtn(Icons.add, onIncrement, quantity < stock),
              ],
            ),
          ),

          const SizedBox(width: 15),

          // --- BOTÓN AGREGAR (EXPANDED) ---
          // Este Expanded es el que causaba error.
          // Para que funcione, el PADRE en VariantScreen también debe usar Expanded.
          Expanded(
            child: SizedBox(
              height: 45, // Altura fija para el botón
              child: ElevatedButton(
                onPressed: isOutOfStock ? null : onAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: Colors.grey[300],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isOutOfStock ? "Agotado" : "Agregar",
                  style: TextStyle(
                    color: isOutOfStock ? Colors.grey : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterBtn(IconData icon, VoidCallback onTap, bool enabled) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? Colors.black87 : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
