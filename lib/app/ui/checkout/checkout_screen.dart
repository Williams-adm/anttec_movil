import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'yape';

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final double totalPagar = cart.totalAmount + 10;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Finalizar Compra",
          style: TextStyle(
              color: AppColors.extradarkT, // ✅ Usando tu color real
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryS, // Blanco (S-50)
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.extradarkT),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dirección de envío",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.extradarkT),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.primaryS,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      AppColors.primaryP.withValues(alpha: 0.2), // Morado P-800
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      color: AppColors.primaryP, size: 30),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Casa",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.extradarkT)),
                        Text(
                          "Av. Giráldez 123, Huancayo",
                          style: TextStyle(
                              color: AppColors.semidarkT, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Cambiar",
                        style: TextStyle(
                            color: AppColors.primaryP,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Método de pago",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.extradarkT),
            ),
            const SizedBox(height: 15),
            _buildPaymentOption(
              value: 'yape',
              title: "Yape / Plin",
              icon: Icons.qr_code_2,
              isSelected: _selectedPaymentMethod == 'yape',
            ),
            const SizedBox(height: 10),
            _buildPaymentOption(
              value: 'card',
              title: "Tarjeta de Crédito/Débito",
              icon: Icons.credit_card,
              isSelected: _selectedPaymentMethod == 'card',
            ),
            const SizedBox(height: 30),
            const Text(
              "Resumen",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.extradarkT),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryS,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                      "Subtotal", "S/. ${cart.totalAmount.toStringAsFixed(2)}"),
                  const SizedBox(height: 10),
                  _buildSummaryRow("Envío", "S/. 10.00"),
                  const Divider(height: 30, color: AppColors.tertiaryS),
                  _buildSummaryRow(
                      "Total", "S/. ${totalPagar.toStringAsFixed(2)}",
                      isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.primaryS, boxShadow: [
          BoxShadow(
            color: AppColors.degraded.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ]),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Procesando pedido...")));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryP, // Morado P-800
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "Pagar S/. ${totalPagar.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryS),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      {required String value,
      required String title,
      required IconData icon,
      required bool isSelected}) {
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.primaryS,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primaryP, width: 2)
              : Border.all(color: AppColors.secondaryS),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primaryP : AppColors.lightdarkT,
                size: 28),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.extradarkT : AppColors.darkT,
                  fontSize: 16),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primaryP)
            else
              const Icon(Icons.circle_outlined, color: AppColors.secondaryS)
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal,
            color: isTotal ? AppColors.extradarkT : AppColors.semidarkT,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.bold,
            color: AppColors.extradarkT,
          ),
        ),
      ],
    );
  }
}
