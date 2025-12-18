import 'package:flutter/material.dart';
import 'widgets/finalizar_header.dart';
import 'widgets/finalizar_comprobante_form.dart';
import 'widgets/finalizar_pago_section.dart';

class FinalizarVentaPage extends StatefulWidget {
  const FinalizarVentaPage({super.key});

  @override
  State<FinalizarVentaPage> createState() => _FinalizarVentaPageState();
}

class _FinalizarVentaPageState extends State<FinalizarVentaPage> {
  String tipoComprobante = 'Boleta';
  String tipoDocumento = 'DNI';
  bool emisionFisica = true;
  String metodoPago = 'Efectivo';

  final TextEditingController numeroDocCtrl = TextEditingController();
  final TextEditingController razonSocialCtrl = TextEditingController();
  final TextEditingController direccionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _configurarCamposPorTipo();
  }

  void _configurarCamposPorTipo() {
    if (tipoComprobante == 'Boleta') {
      tipoDocumento = 'DNI';
      razonSocialCtrl.text = 'Pepito Pérez';
      direccionCtrl.clear();
      numeroDocCtrl.text = '1075232981';
    } else {
      tipoDocumento = 'RUC';
      razonSocialCtrl.text = 'Pepito SAC';
      direccionCtrl.text = 'Av. los Álamos #2021';
      numeroDocCtrl.text = '2075232981';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF7E2E9E);

    return Container(
      color: const Color(0xFFF7F1FF),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            const FinalizarHeader(),
            const SizedBox(height: 16),
            FinalizarComprobanteForm(
              themeColor: themeColor,
              tipoComprobante: tipoComprobante,
              tipoDocumento: tipoDocumento,
              numeroDocCtrl: numeroDocCtrl,
              razonSocialCtrl: razonSocialCtrl,
              direccionCtrl: direccionCtrl,
              onChangeTipoComprobante: (value) {
                tipoComprobante = value;
                _configurarCamposPorTipo();
              },
              onChangeTipoDocumento: (value) {
                setState(() => tipoDocumento = value);
              },
            ),
            const SizedBox(height: 20),
            FinalizarPagoSection(
              themeColor: themeColor,
              emisionFisica: emisionFisica,
              metodoPago: metodoPago,
              onChangeEmision: (value) {
                setState(() => emisionFisica = value);
              },
              onChangeMetodoPago: (value) {
                setState(() => metodoPago = value);
              },
              onConfirmar: () {
                // aquí armas tu request con todos los datos
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
