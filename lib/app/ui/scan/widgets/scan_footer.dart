import 'package:flutter/material.dart';
import 'package:anttec_movil/app/ui/scan/styles/scan_styles.dart';

class ScanFooter extends StatelessWidget {
  const ScanFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: Column(
        mainAxisSize: MainAxisSize
            .min, // Hace que la columna ocupe el espacio mínimo necesario
        children: [
          // Solo mostramos el indicador del modo de escaneo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                color: ScanStyles.accentColor,
                size:
                    24, // Aumenté un poco el tamaño para darle mejor jerarquía
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
