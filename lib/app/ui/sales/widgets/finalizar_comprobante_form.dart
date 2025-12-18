import 'package:flutter/material.dart';
import 'finalizar_util_widgets.dart';

class FinalizarComprobanteForm extends StatelessWidget {
  final Color themeColor;
  final String tipoComprobante;
  final String tipoDocumento;
  final TextEditingController numeroDocCtrl;
  final TextEditingController razonSocialCtrl;
  final TextEditingController direccionCtrl;
  final ValueChanged<String> onChangeTipoComprobante;
  final ValueChanged<String> onChangeTipoDocumento;

  const FinalizarComprobanteForm({
    super.key,
    required this.themeColor,
    required this.tipoComprobante,
    required this.tipoDocumento,
    required this.numeroDocCtrl,
    required this.razonSocialCtrl,
    required this.direccionCtrl,
    required this.onChangeTipoComprobante,
    required this.onChangeTipoDocumento,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccione el tipo de comprobante:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SegmentButton(
                label: 'Boleta',
                selected: tipoComprobante == 'Boleta',
                color: themeColor,
                onTap: () => onChangeTipoComprobante('Boleta'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SegmentButton(
                label: 'Factura',
                selected: tipoComprobante == 'Factura',
                color: themeColor,
                onTap: () => onChangeTipoComprobante('Factura'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Seleccione el tipo de documento:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownLike(
          value: tipoDocumento,
          items: tipoComprobante == 'Boleta'
              ? const ['DNI', 'CE']
              : const ['RUC'],
          onChanged: onChangeTipoDocumento,
        ),
        const SizedBox(height: 16),
        Text(
          tipoComprobante == 'Boleta'
              ? 'Ingrese el N° de $tipoDocumento:'
              : 'Ingrese el N° de RUC:',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: numeroDocCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onPressed: () {},
              child: const Text('Consultar'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          tipoComprobante == 'Boleta'
              ? 'Nombres y apellidos:'
              : 'Razón Social:',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        ReadOnlyField(controller: razonSocialCtrl),
        const SizedBox(height: 12),
        if (tipoComprobante == 'Factura') ...[
          const Text(
            'Dirección Fiscal:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          ReadOnlyField(controller: direccionCtrl),
        ],
      ],
    );
  }
}
