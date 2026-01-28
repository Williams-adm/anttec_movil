import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedType; // 'boleta' o 'factura'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Finalizar Venta",
          style: TextStyle(
            color: AppColors.extradarkT,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryS,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.extradarkT, size: 18),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                "¿Qué tipo de comprobante\nnecesitas?",
                style: TextStyle(
                  fontSize: 26,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                  color: AppColors.extradarkT,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Selecciona una opción para continuar con el registro de tu venta.",
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.semidarkT,
                ),
              ),
              const SizedBox(height: 40),

              // --- OPCIÓN BOLETA ---
              _buildModernOption(
                title: "Boleta de Venta",
                subtitle: "Uso personal / Consumidor final",
                icon: Icons.person_rounded,
                type: 'boleta',
              ),

              const SizedBox(height: 20),

              // --- OPCIÓN FACTURA ---
              _buildModernOption(
                title: "Factura Electrónica",
                subtitle: "Crédito fiscal para empresas (RUC)",
                icon: Icons.business_rounded,
                type: 'factura',
              ),

              const Spacer(),

              // --- BOTÓN CONTINUAR ---
              _buildContinueButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String type,
  }) {
    final bool isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primaryS, // Blanco
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primaryP : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryP.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          children: [
            // Icono con contenedor estilizado
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryP : AppColors.background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primaryP,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? AppColors.primaryP
                          : AppColors.extradarkT,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.semidarkT,
                    ),
                  ),
                ],
              ),
            ),
            // Indicador de selección
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected ? AppColors.primaryP : AppColors.secondaryS,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final bool isReady = _selectedType != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isReady ? 1.0 : 0.5,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: isReady
              ? [
                  BoxShadow(
                    color: AppColors.primaryP.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: ElevatedButton(
          onPressed: isReady
              ? () {
                  // Acción según selección
                  debugPrint("Continuar con: $_selectedType");
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryP,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.secondaryS,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Continuar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
