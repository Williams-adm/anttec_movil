import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';
import 'cart_constants.dart';

class CartItemCard extends StatelessWidget {
  final dynamic item;
  final CartProvider provider;

  const CartItemCard({
    super.key,
    required this.item,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
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
          // Fila Superior: Nombre y Eliminar
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
              InkWell(
                onTap: () => provider.removeItem(item.id!),
                child: const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Icon(Icons.delete_outline,
                      color: AppColors.deleteRed, size: 26),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Fila Inferior: Imagen y Controles
          Row(
            children: [
              // Imagen
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

              // Datos y Botones
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
}
