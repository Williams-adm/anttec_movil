import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';

class ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const ChatInputArea({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          16, 10, 16, 24), // Más padding abajo para seguridad en iPhone
      decoration: const BoxDecoration(
        color: Color(
            0xFFF2F4F8), // Mismo color del fondo para que parezca transparente
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: "¿Qué estás buscando hoy?",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Botón de Enviar con animación de pulsación (InkWell)
          Material(
            color: AppColors.primaryP,
            borderRadius: BorderRadius.circular(30),
            elevation: 4,
            shadowColor: AppColors.primaryP.withValues(alpha: 0.4),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: isLoading ? null : onSend,
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Symbols.send, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
