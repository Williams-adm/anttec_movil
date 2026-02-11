import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/ui/chat/widgets/chat_product_card.dart';

class ChatMessageItem extends StatelessWidget {
  final Map<String, dynamic> message;

  const ChatMessageItem({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message['role'] == 'user';
    final products = message['products'] as List<dynamic>;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // 1. Burbuja de Texto + Avatar
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment:
                CrossAxisAlignment.end, // Para alinear avatar abajo
            children: [
              // Avatar del Bot (Solo si no es usuario)
              if (!isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 8, bottom: 4),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ]),
                  child: const Icon(Symbols.smart_toy,
                      size: 18, color: AppColors.primaryP),
                ),
              ],

              // Burbuja de Texto
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primaryP : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Text(
                    message['content'],
                    style: TextStyle(
                        color: isUser ? Colors.white : const Color(0xFF2D3339),
                        fontSize: 15,
                        height: 1.5, // Mejor lectura
                        fontWeight:
                            isUser ? FontWeight.w500 : FontWeight.normal),
                  ),
                ),
              ),
            ],
          ),

          // 2. Carrusel de Productos (Solo si es bot y tiene productos)
          if (!isUser && products.isNotEmpty) ...[
            const SizedBox(height: 16), // Un poco más de separación
            SizedBox(
              // ✅ AJUSTE CLAVE: Altura aumentada a 410px para evitar el 'Bottom Overflowed'
              // y dar espacio a la sombra inferior de la tarjeta nueva.
              height: 410,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                // Padding izquierdo para alinear visualmente con el texto del bot (40px)
                // Padding inferior para que no se corte la sombra (20px)
                padding: const EdgeInsets.only(left: 40, right: 16, bottom: 20),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return ChatProductCard(product: products[index]);
                },
              ),
            ),
          ]
        ],
      ),
    );
  }
}
