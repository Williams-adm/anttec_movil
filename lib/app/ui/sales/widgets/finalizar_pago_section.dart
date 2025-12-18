import 'package:flutter/material.dart';
import 'finalizar_util_widgets.dart';

class FinalizarPagoSection extends StatelessWidget {
  final Color themeColor;
  final bool emisionFisica;
  final String metodoPago;
  final ValueChanged<bool> onChangeEmision;
  final ValueChanged<String> onChangeMetodoPago;
  final VoidCallback onConfirmar;

  const FinalizarPagoSection({
    super.key,
    required this.themeColor,
    required this.emisionFisica,
    required this.metodoPago,
    required this.onChangeEmision,
    required this.onChangeMetodoPago,
    required this.onConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de emisión:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            RadioText(
              label: 'Física',
              selected: emisionFisica,
              onTap: () => onChangeEmision(true),
              color: themeColor,
            ),
            const SizedBox(width: 16),
            RadioText(
              label: 'Virtual',
              selected: !emisionFisica,
              onTap: () => onChangeEmision(false),
              color: themeColor,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Método de pago:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: [
            RadioText(
              label: 'Efectivo',
              selected: metodoPago == 'Efectivo',
              onTap: () => onChangeMetodoPago('Efectivo'),
              color: themeColor,
            ),
            RadioText(
              label: 'Billetera Digital',
              selected: metodoPago == 'Billetera',
              onTap: () => onChangeMetodoPago('Billetera'),
              color: themeColor,
            ),
            RadioText(
              label: 'Otros',
              selected: metodoPago == 'Otros',
              onTap: () => onChangeMetodoPago('Otros'),
              color: themeColor,
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: onConfirmar,
            child: const Text(
              'Confirmar Venta',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
