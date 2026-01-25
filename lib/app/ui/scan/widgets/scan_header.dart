import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:anttec_movil/app/ui/scan/styles/scan_styles.dart';
import 'package:anttec_movil/app/ui/scan/controllers/scan_controller.dart';

class ScanHeader extends StatelessWidget {
  final ScanController controller;

  const ScanHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // BOTÓN ATRÁS
          _CircleButton(
            icon: Icons.arrow_back,
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed('home');
              }
            },
          ),

          // BOTÓN FLASH
          Container(
            decoration: const BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: ValueListenableBuilder(
                valueListenable: controller.cameraController,
                builder: (context, state, child) {
                  final isTorchOn = state.torchState == TorchState.on;
                  return Icon(
                    isTorchOn ? Icons.flash_on : Icons.flash_off,
                    color: isTorchOn ? Colors.amber : ScanStyles.white,
                    size: 28,
                  );
                },
              ),
              onPressed: controller.toggleTorch,
            ),
          ),
        ],
      ),
    );
  }
}

// Un pequeño widget privado para no repetir código de decoración
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black26,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: ScanStyles.white, size: 28),
        onPressed: onTap,
      ),
    );
  }
}
