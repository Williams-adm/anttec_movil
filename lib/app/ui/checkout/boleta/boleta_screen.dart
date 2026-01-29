import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';

class BoletaScreen extends StatelessWidget {
  const BoletaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, "Datos de Boleta"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildProgressIndicator(1),
              const SizedBox(height: 35),
              const Text(
                "Identificación del Cliente",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.extradarkT,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Ingresa los datos para la emisión de tu comprobante personal.",
                style: TextStyle(color: AppColors.semidarkT, fontSize: 15),
              ),
              const SizedBox(height: 40),
              _buildInputField(
                label: "Número de DNI (Opcional)",
                hint: "Ej. 70654321",
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 25),
              _buildInputField(
                label: "Nombres y Apellidos",
                hint: "Ej. Juan Pérez",
                icon: Icons.person_outline_rounded,
              ),
              const Spacer(),
              _buildActionButton(context, "Finalizar Boleta"),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS INTERNOS ---
  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    return AppBar(
      title: Text(title,
          style: const TextStyle(
              color: AppColors.extradarkT, fontWeight: FontWeight.w800)),
      centerTitle: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: AppColors.extradarkT, size: 20),
        onPressed: () => context.pop(),
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

  Widget _buildInputField(
      {required String label,
      required String hint,
      required IconData icon,
      TextInputType? keyboardType}) {
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
          keyboardType: keyboardType,
          style: const TextStyle(
              color: AppColors.extradarkT, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryP, size: 22),
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

  Widget _buildActionButton(BuildContext context, String text) {
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
        onPressed: () {},
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
