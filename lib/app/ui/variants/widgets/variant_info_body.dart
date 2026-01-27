import 'package:flutter/material.dart';
import '../widgets/color_selector.dart';
import '../widgets/quantity_selector.dart';

class VariantInfoBody extends StatelessWidget {
  final String brandName;
  final String sku;
  final String productName;
  final double price;
  final int currentDisplayedStock;
  final String description;
  final dynamic data; // Datos completos del producto
  final dynamic variant; // Variante seleccionada

  // Callbacks y estado
  final Function(int) onVariantSelected;
  final int quantity;
  final Function() onIncrement;
  final Function() onDecrement;
  final Function() onAddToCart;
  final bool isAddingToCart;

  const VariantInfoBody({
    super.key,
    required this.brandName,
    required this.sku,
    required this.productName,
    required this.price,
    required this.currentDisplayedStock,
    required this.description,
    required this.data,
    required this.variant,
    required this.onVariantSelected,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onAddToCart,
    required this.isAddingToCart,
  });

  final Color _primaryColor = const Color(0xFF7E33A3);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Marca y SKU
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  brandName.isEmpty ? "ANTTEC" : brandName,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor),
                ),
              ),
              const Spacer(),
              Text("SKU: $sku",
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),

          // Nombre del Producto
          Text(
            productName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // Precio y Stock
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "S/. ${price.toStringAsFixed(2)}",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _primaryColor),
              ),
              const Spacer(),
              Text(
                "$currentDisplayedStock disponibles",
                style: TextStyle(
                  fontSize: 14,
                  color: currentDisplayedStock < 5 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // Selector de Color
          const Text("Color:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ColorSelector(
            variants: data.variants,
            selectedId: variant.id,
            primaryColor: _primaryColor,
            onVariantSelected: onVariantSelected,
          ),
          const SizedBox(height: 25),

          // Selector de Cantidad
          const Text("Cantidad",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          QuantitySelector(
            quantity: quantity,
            stock: variant.stock,
            primaryColor: _primaryColor,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
            onAddToCart: isAddingToCart ? () {} : onAddToCart,
          ),

          // Loading
          if (isAddingToCart)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Center(child: LinearProgressIndicator()),
            ),

          const SizedBox(height: 30),

          // Descripción
          const Text("Descripción",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
