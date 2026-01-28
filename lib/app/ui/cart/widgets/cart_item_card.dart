import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';

class CartItemCard extends StatefulWidget {
  final dynamic item;
  final CartProvider provider;

  const CartItemCard({
    super.key,
    required this.item,
    required this.provider,
  });

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  late int _currentQuantity;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.item.quantity;
  }

  @override
  void didUpdateWidget(covariant CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.quantity != oldWidget.item.quantity) {
      _currentQuantity = widget.item.quantity;
    }
  }

  void _updateQuantity(int newQuantity) {
    // ✅ VALIDACIÓN DE STOCK
    if (newQuantity > widget.item.maxStock) {
      _showStockLimitMessage();
      return;
    }

    setState(() {
      _currentQuantity = newQuantity;
    });
    widget.provider.updateItem(widget.item.variantId, newQuantity);
  }

  // ✅ MENSAJE DE ADVERTENCIA
  void _showStockLimitMessage() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Stock máximo alcanzado (${widget.item.maxStock} unidades)",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryP,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Verificamos si podemos seguir sumando
    final bool canIncrease = _currentQuantity < widget.item.maxStock;

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
                  widget.item.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.extradarkT),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () => widget.provider.removeItem(widget.item.id),
                child: const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child:
                      Icon(Icons.delete_outline, color: Colors.red, size: 26),
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
                    color: Colors.white),
                child: CachedNetworkImage(
                  imageUrl: widget.item.image ?? "",
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
                            color: AppColors.extradarkT, fontSize: 16),
                        children: [
                          const TextSpan(
                              text: 'Precio   ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: 'S/. ${widget.item.price}'),
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
                          if (_currentQuantity > 1) {
                            _updateQuantity(_currentQuantity - 1);
                          }
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text('$_currentQuantity',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18)),
                        ),
                        // ✅ BOTÓN SUMAR CON LÓGICA DE STOCK
                        _qtyButton(
                          Icons.add,
                          () {
                            if (canIncrease) {
                              _updateQuantity(_currentQuantity + 1);
                            } else {
                              _showStockLimitMessage();
                            }
                          },
                          isEnabled: canIncrease,
                        ),
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

  // ✅ WIDGET DE BOTÓN MEJORADO
  Widget _qtyButton(IconData icon, VoidCallback onTap,
      {bool isEnabled = true}) {
    return Material(
      color: isEnabled
          ? AppColors.tertiaryS
          : AppColors.secondaryS.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 20,
            color: isEnabled ? AppColors.extradarkT : Colors.grey,
          ),
        ),
      ),
    );
  }
}
