import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';

class FacturaScreen extends StatefulWidget {
  const FacturaScreen({super.key});

  @override
  State<FacturaScreen> createState() => _FacturaScreenState();
}

class _FacturaScreenState extends State<FacturaScreen> {
  // ✅ Controlador ahora en uso
  final TextEditingController _rucController = TextEditingController();
  final TextEditingController _razonSocialController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  @override
  void dispose() {
    // Es buena práctica liberar la memoria de los controladores
    _rucController.dispose();
    _razonSocialController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Datos de Factura",
            style: TextStyle(
                color: AppColors.extradarkT, fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.extradarkT, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildProgressIndicator(1),
            const SizedBox(height: 35),
            const Text(
              "Información de Empresa",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.extradarkT,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 10),
            const Text(
              "Ingresa un RUC válido para generar el comprobante electrónico.",
              style: TextStyle(color: AppColors.semidarkT, fontSize: 15),
            ),
            const SizedBox(height: 35),
            _buildInputField(
              label: "Número de RUC",
              hint: "Ej. 20123456789",
              icon: Icons.domain_rounded,
              keyboardType: TextInputType.number,
              controller: _rucController, // ✅ ASIGNADO AQUÍ
              suffix: TextButton(
                  onPressed: () {
                    debugPrint("Validando RUC: ${_rucController.text}");
                  },
                  child: const Text("VALIDAR",
                      style: TextStyle(
                          color: AppColors.primaryP,
                          fontWeight: FontWeight.w900,
                          fontSize: 12))),
            ),
            const SizedBox(height: 20),
            _buildInputField(
              label: "Razón Social",
              hint: "Nombre de la empresa",
              icon: Icons.business_center_outlined,
              controller: _razonSocialController, // ✅ ASIGNADO AQUÍ
            ),
            const SizedBox(height: 20),
            _buildInputField(
              label: "Dirección Fiscal",
              hint: "Domicilio legal",
              icon: Icons.location_on_outlined,
              controller: _direccionController, // ✅ ASIGNADO AQUÍ
            ),
            const SizedBox(height: 60),
            _buildActionButton("Generar Factura"),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int step) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: AppColors.primaryP,
              borderRadius: BorderRadius.circular(12)),
          child: Text("Paso $step de 2",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: LinearProgressIndicator(
                value: step / 2,
                backgroundColor: AppColors.tertiaryS,
                color: AppColors.primaryP,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10))),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    Widget? suffix,
    TextEditingController? controller, // ✅ Agregado al método
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.extradarkT,
                fontSize: 14)),
        const SizedBox(height: 12),
        TextField(
          controller: controller, // ✅ CONECTADO AL TEXTFIELD
          keyboardType: keyboardType,
          style: const TextStyle(
              color: AppColors.extradarkT, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryP, size: 22),
            suffixIcon: suffix,
            hintText: hint,
            hintStyle: const TextStyle(
                color: AppColors.lightdarkT, fontWeight: FontWeight.normal),
            filled: true,
            fillColor: AppColors.primaryS,
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    const BorderSide(color: AppColors.primaryP, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryP.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          debugPrint("Emitiendo factura para RUC: ${_rucController.text}");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryP,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          elevation: 0,
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
