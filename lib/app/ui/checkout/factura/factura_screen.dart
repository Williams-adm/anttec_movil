import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';

class FacturaScreen extends StatefulWidget {
  const FacturaScreen({super.key});

  @override
  State<FacturaScreen> createState() => _FacturaScreenState();
}

class _FacturaScreenState extends State<FacturaScreen> {
  String _selectedPayment = 'efectivo';
  String _digitalWallet = 'yape';

  final TextEditingController _rucController = TextEditingController();
  final TextEditingController _razonSocialController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _recibidoController = TextEditingController();
  final TextEditingController _opController = TextEditingController();

  double _vuelto = 0.0;

  @override
  void dispose() {
    _rucController.dispose();
    _razonSocialController.dispose();
    _direccionController.dispose();
    _recibidoController.dispose();
    _opController.dispose();
    super.dispose();
  }

  void _calculateChange(double total) {
    double recibido = double.tryParse(_recibidoController.text) ?? 0.0;
    setState(() {
      _vuelto = recibido > total ? recibido - total : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final double totalPagar = cart.totalAmount; // ✅ Corregido: Sin envío

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
                color: AppColors.extradarkT),
            onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text("Información de Empresa",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.extradarkT)),
              const SizedBox(height: 15),
              _buildInputField(
                  label: "RUC",
                  hint: "Ej. 20123456789",
                  icon: Icons.business_rounded,
                  controller: _rucController,
                  keyboardType: TextInputType.number,
                  suffix: TextButton(
                      onPressed: () => _simularValidacion(),
                      child: const Text("VALIDAR",
                          style: TextStyle(
                              color: AppColors.primaryP,
                              fontWeight: FontWeight.bold)))),
              const SizedBox(height: 15),
              _buildInputField(
                  label: "Razón Social",
                  hint: "Nombre legal",
                  icon: Icons.assignment_outlined,
                  controller: _razonSocialController),
              const SizedBox(height: 15),
              _buildInputField(
                  label: "Dirección Fiscal",
                  hint: "Domicilio legal",
                  icon: Icons.location_on_outlined,
                  controller: _direccionController),
              const SizedBox(height: 35),
              const Text("Método de Pago",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.extradarkT)),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(
                    child: _buildPaymentMiniCard(
                        "Efectivo", Icons.payments_outlined, 'efectivo')),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildPaymentMiniCard(
                        "Yape / Plin", Icons.qr_code_scanner, 'yape')),
              ]),
              const SizedBox(height: 25),
              if (_selectedPayment == 'efectivo')
                _buildCashCalculator(totalPagar),
              if (_selectedPayment == 'yape')
                _buildDigitalWalletSelector(totalPagar),
              const SizedBox(height: 30),
              _buildSummaryBox(totalPagar),
              const SizedBox(height: 30),
              _buildActionButton(context, "Emitir Factura"),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _simularValidacion() {
    if (_rucController.text.length == 11) {
      setState(() {
        _razonSocialController.text = "ANTTEC SOLUCIONES S.A.C.";
        _direccionController.text = "Av. Principal 456, Huancayo";
      });
    }
  }

  // --- REUTILIZACIÓN DE WIDGETS ---
  Widget _buildDigitalWalletSelector(double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.primaryS,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.tertiaryS)),
      child: Column(children: [
        Row(children: [
          Expanded(
              child: _buildWalletTypeButton(
                  "Yape", 'yape', const Color(0xFF742D87))),
          const SizedBox(width: 10),
          Expanded(
              child: _buildWalletTypeButton(
                  "Plin", 'plin', const Color(0xFF00B4C5))),
        ]),
        const SizedBox(height: 25),
        Icon(Icons.qr_code_2_rounded,
            size: 180,
            color: _digitalWallet == 'yape'
                ? const Color(0xFF742D87)
                : const Color(0xFF00B4C5)),
        const SizedBox(height: 20),
        _buildInputField(
            label: "Nro. Operación",
            hint: "000000",
            icon: Icons.receipt_long_outlined,
            controller: _opController,
            keyboardType: TextInputType.number),
      ]),
    );
  }

  Widget _buildWalletTypeButton(String label, String value, Color activeColor) {
    final isSelected = _digitalWallet == value;
    return GestureDetector(
      onTap: () => setState(() => _digitalWallet = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: isSelected ? activeColor : AppColors.background,
            borderRadius: BorderRadius.circular(12)),
        child: Center(
            child: Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.semidarkT,
                    fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildCashCalculator(double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: AppColors.primaryS,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryP.withValues(alpha: 0.1))),
      child: Column(children: [
        TextField(
            controller: _recibidoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _calculateChange(total),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryP),
            decoration: const InputDecoration(
                hintText: "0.00",
                labelText: "EFECTIVO RECIBIDO",
                labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.semidarkT),
                border: InputBorder.none,
                floatingLabelBehavior: FloatingLabelBehavior.always)),
        const Divider(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("VUELTO:",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.darkT)),
          Text("S/. ${_vuelto.toStringAsFixed(2)}",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color:
                      _vuelto > 0 ? Colors.green[700] : AppColors.semidarkT)),
        ]),
      ]),
    );
  }

  Widget _buildSummaryBox(double total) {
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.primaryS, borderRadius: BorderRadius.circular(20)),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Monto Final:",
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.semidarkT)),
          Text("S/. ${total.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryP))
        ]));
  }

  Widget _buildPaymentMiniCard(String title, IconData icon, String value) {
    final isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryP : AppColors.primaryS,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color:
                      isSelected ? AppColors.primaryP : AppColors.tertiaryS)),
          child: Column(children: [
            Icon(icon, color: isSelected ? Colors.white : AppColors.primaryP),
            const SizedBox(height: 5),
            Text(title,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.extradarkT))
          ])),
    );
  }

  Widget _buildInputField(
      {required String label,
      required String hint,
      required IconData icon,
      required TextEditingController controller,
      TextInputType? keyboardType,
      Widget? suffix}) {
    return TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
            color: AppColors.extradarkT, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            suffixIcon: suffix,
            prefixIcon: Icon(icon, color: AppColors.primaryP, size: 22),
            filled: true,
            fillColor: AppColors.primaryS,
            labelStyle: const TextStyle(color: AppColors.semidarkT),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.primaryP, width: 2))));
  }

  Widget _buildActionButton(BuildContext context, String text) {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            onPressed: () => _showSuccessDialog(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryP,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22))),
            child: Text(text,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900))));
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text("¡Venta Exitosa!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              const Text("Factura generada correctamente.",
                  textAlign: TextAlign.center),
              const SizedBox(height: 30),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () => ctx.go('/home'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryP,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: const Text("Finalizar",
                          style: TextStyle(color: Colors.white))))
            ])));
  }
}
