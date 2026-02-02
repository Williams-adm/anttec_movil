import 'package:flutter/material.dart';

// ✅ CORRECCIÓN CLAVE: Usamos el archivo original de tu proyecto
import 'package:anttec_movil/data/services/api/v1/model/product/product_detail_response.dart';

import '../widgets/color_selector.dart';
import '../widgets/quantity_selector.dart';

class VariantInfoBody extends StatelessWidget {
  final String brandName;
  final String sku;
  final String productName;
  final double price;
  final int currentDisplayedStock;
  final String description;
  final dynamic
      data; // Esto contiene el objeto ProductDetailData con las specifications
  final dynamic variant;

  // Callbacks y estado
  final Function(int) onVariantSelected;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onAddToCart;
  final bool isAddingToCart;

  final List<dynamic> variants;

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
    required this.variants,
  });

  static const Color _primaryColor = Color(0xFF7E33A3);

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
                  style: const TextStyle(
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
                style: const TextStyle(
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
            variants: variants.cast<VariantOption>().toList(),
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
              child:
                  Center(child: LinearProgressIndicator(color: _primaryColor)),
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

          // ✅ AQUÍ AGREGAMOS LA TABLA DE ESPECIFICACIONES
          // Verificamos si la lista existe y no está vacía
          if (data.specifications != null &&
              data.specifications.isNotEmpty) ...[
            const SizedBox(height: 30),
            const Text(
              "Especificaciones Técnicas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: List.generate(data.specifications.length, (index) {
                  final spec = data.specifications[index];
                  // Determinamos si es el último para no ponerle borde abajo
                  final isLast = index == data.specifications.length - 1;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      // Efecto cebra: filas pares gris claro, impares blanco
                      color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: index == 0
                            ? const Radius.circular(12)
                            : Radius.zero,
                        bottom:
                            isLast ? const Radius.circular(12) : Radius.zero,
                      ),
                      border: isLast
                          ? null
                          : Border(
                              bottom: BorderSide(color: Colors.grey.shade100)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            spec.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    _primaryColor // Usamos el morado de tu marca
                                ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            spec.value,
                            style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
