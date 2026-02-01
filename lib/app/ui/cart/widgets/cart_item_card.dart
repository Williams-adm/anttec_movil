import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:material_symbols_icons/symbols.dart';

class CartItemCard extends StatefulWidget {
  final dynamic item;
  final CartProvider provider;

  const CartItemCard({super.key, required this.item, required this.provider});

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
    if (newQuantity > widget.item.maxStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Stock máximo: ${widget.item.maxStock}"),
            backgroundColor: AppColors.primaryP),
      );
      return;
    }
    setState(() => _currentQuantity = newQuantity);
    widget.provider.updateItem(widget.item.variantId, newQuantity);
  }

  @override
  Widget build(BuildContext context) {
    final bool canIncrease = _currentQuantity < widget.item.maxStock;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: widget.item.image ?? "",
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      const Icon(Symbols.broken_image, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.extradarkT),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text("S/. ${widget.item.price}",
                        style: const TextStyle(
                            color: AppColors.primaryP,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                  ],
                ),
              ),
              // ✅ CAMBIO CLAVE: Pasamos el objeto item completo
              IconButton(
                icon: const Icon(Symbols.delete_rounded,
                    color: Colors.redAccent, size: 24),
                onPressed: () => widget.provider.removeItem(widget.item),
              ),
            ],
          ),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF5F5F5))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Cantidad",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              Container(
                decoration: BoxDecoration(
                    color: AppColors.primaryS,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    _qtyBtn(
                        Symbols.remove_rounded,
                        () => _currentQuantity > 1
                            ? _updateQuantity(_currentQuantity - 1)
                            : null),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$_currentQuantity',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 17)),
                    ),
                    _qtyBtn(
                        Symbols.add_rounded,
                        () => canIncrease
                            ? _updateQuantity(_currentQuantity + 1)
                            : null,
                        isEnabled: canIncrease),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback? onTap, {bool isEnabled = true}) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(icon,
            size: 22, color: isEnabled ? AppColors.primaryP : Colors.grey[400]),
      ),
    );
  }
}
