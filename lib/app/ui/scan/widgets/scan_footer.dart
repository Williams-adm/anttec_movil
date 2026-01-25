import 'package:flutter/material.dart';
import 'package:anttec_movil/app/ui/scan/styles/scan_styles.dart';

class ScanFooter extends StatelessWidget {
  const ScanFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          // Botón Galería
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ScanStyles.galleryButtonBorder),
              color: ScanStyles.galleryButtonBackground,
            ),
            child: const Icon(
              Icons.photo_library,
              color: ScanStyles.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 15),

          // Texto Modo
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                color: ScanStyles.accentColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Escanear",
                style: ScanStyles.modeText,
              ),
            ],
          )
        ],
      ),
    );
  }
}
