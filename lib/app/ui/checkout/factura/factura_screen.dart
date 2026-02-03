import 'package:anttec_movil/data/services/api/v1/printer_service.dart';
import 'package:anttec_movil/app/ui/sales_report/widgets/printer_selector_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

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

  final PrinterService _printerService = PrinterService();
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

  void _showCustomNotice(
      {required String message, required IconData icon, required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Expanded(
                child: Text(message,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14))),
          ]),
        ),
      ),
    );
  }

  void _calculateChange(double total) {
    double recibido = double.tryParse(_recibidoController.text) ?? 0.0;
    setState(() => _vuelto = recibido > total ? recibido - total : 0.0);
  }

  void _validarYFinalizar(
      BuildContext context, double total, CartProvider cart) {
    if (_rucController.text.length != 11) {
      _showCustomNotice(
          message: "El RUC debe tener 11 dígitos",
          icon: Symbols.info,
          color: Colors.orange[800]!);
      return;
    }
    if (_razonSocialController.text.isEmpty ||
        _direccionController.text.isEmpty) {
      _showCustomNotice(
          message: "Complete los datos de la empresa",
          icon: Symbols.domain,
          color: Colors.orange[800]!);
      return;
    }
    if (_selectedPayment == 'efectivo') {
      double recibido = double.tryParse(_recibidoController.text) ?? 0.0;
      if (recibido < total) {
        _showCustomNotice(
            message: "Efectivo insuficiente",
            icon: Symbols.payments,
            color: Colors.redAccent);
        return;
      }
    }
    _showSuccessDialog(context, total, cart);
  }

  void _showSuccessDialog(
      BuildContext context, double total, CartProvider cart) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            shape: BoxShape.circle)),
                    Container(
                        width: 75,
                        height: 75,
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle),
                        child: const Icon(Symbols.check_rounded,
                            color: Colors.white, size: 45, weight: 700)),
                  ],
                ),
                const SizedBox(height: 25),
                const Text("¡Venta Realizada!",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.extradarkT)),
                const SizedBox(height: 10),
                Text("Factura registrada por S/. ${total.toStringAsFixed(2)}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _abrirSelectorImpresora(context, total, cart),
                    icon: const Icon(Symbols.print),
                    label: const Text("IMPRIMIR FACTURA"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryP,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: TextButton(
                    onPressed: () {
                      cart.clearCart(); // ✅ Método corregido
                      ctx.go('/home');
                    },
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryP,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                                color: AppColors.primaryP, width: 1.5))),
                    child: const Text("FINALIZAR Y SALIR",
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _abrirSelectorImpresora(
      BuildContext context, double total, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PrinterSelectorModal(
          onPrinterSelected: (type, address) =>
              _imprimir(type, address, total, cart)),
    );
  }

  void _imprimir(
      String type, String address, double total, CartProvider cart) async {
    final Map<String, dynamic> saleData = {
      'id': 'F001-${DateTime.now().second}',
      'type': 'Factura',
      'amount': total,
      'ruc': _rucController.text,
      'customer': _razonSocialController.text,
      'date': DateTime.now().toString().substring(0, 16),
      'items': cart.items
          .map((i) => {
                'qty': i.quantity,
                'name': i.name,
                'total': i.price * i.quantity
              })
          .toList(),
    };
    try {
      if (type == 'NET') {
        await _printerService.printNetwork(address, 9100, saleData);
      } else {
        await _printerService.printBluetooth(address, saleData);
      }
      _showCustomNotice(
          message: "Factura enviada a ticketera",
          icon: Symbols.print_connect,
          color: Colors.green);
    } catch (e) {
      _showCustomNotice(
          message: "Fallo al imprimir: $e",
          icon: Symbols.error,
          color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final double totalPagar = cart.totalAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text("Datos de Factura",
              style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.background),
      body: SingleChildScrollView(
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
                hint: "11 dígitos",
                icon: Symbols.business,
                controller: _rucController,
                isNumeric: true,
                maxLength: 11),
            const SizedBox(height: 15),
            _buildInputField(
                label: "Razón Social",
                hint: "Nombre legal",
                icon: Symbols.assignment,
                controller: _razonSocialController),
            const SizedBox(height: 15),
            _buildInputField(
                label: "Dirección Fiscal",
                hint: "Domicilio legal",
                icon: Symbols.location_on,
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
                      "Efectivo", Symbols.payments, 'efectivo')),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildPaymentMiniCard(
                      "Yape / Plin", Symbols.qr_code_scanner, 'yape')),
            ]),
            const SizedBox(height: 25),
            if (_selectedPayment == 'efectivo')
              _buildCashCalculator(totalPagar),
            if (_selectedPayment == 'yape')
              _buildDigitalWalletSelector(totalPagar),
            const SizedBox(height: 30),
            _buildSummaryBox(totalPagar),
            const SizedBox(height: 30),
            _buildActionButton(context, "REALIZAR VENTA", totalPagar, cart),
            const SizedBox(height: 30),
          ],
        ),
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            ],
            onChanged: (_) => _calculateChange(total),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryP),
            decoration: const InputDecoration(
                hintText: "0.00",
                labelText: "EFECTIVO RECIBIDO",
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
                  color: _vuelto > 0 ? Colors.green[700] : Colors.grey)),
        ]),
      ]),
    );
  }

  Widget _buildInputField(
      {required String label,
      required String hint,
      required IconData icon,
      required TextEditingController controller,
      bool isNumeric = false,
      int? maxLength,
      Widget? suffix}) {
    return TextField(
        controller: controller,
        maxLength: maxLength,
        inputFormatters: [
          if (isNumeric) FilteringTextInputFormatter.digitsOnly,
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength)
        ],
        decoration: InputDecoration(
            counterText: "",
            labelText: label,
            hintText: hint,
            suffixIcon: suffix,
            prefixIcon: Icon(icon, color: AppColors.primaryP),
            filled: true,
            fillColor: AppColors.primaryS,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none)));
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
                    color: isSelected ? Colors.white : AppColors.extradarkT,
                    fontWeight: FontWeight.bold))
          ])),
    );
  }

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
        Icon(Symbols.qr_code_2,
            size: 180,
            color: _digitalWallet == 'yape'
                ? const Color(0xFF742D87)
                : const Color(0xFF00B4C5)),
        const SizedBox(height: 20),
        _buildInputField(
            label: "Nro. Operación",
            hint: "000000",
            icon: Symbols.receipt_long,
            controller: _opController,
            isNumeric: true),
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

  Widget _buildSummaryBox(double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.primaryS, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("Monto Final:",
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.semidarkT)),
        Text("S/. ${total.toStringAsFixed(2)}",
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryP)),
      ]),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String text, double total, CartProvider cart) {
    return SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
            onPressed: () => _validarYFinalizar(context, total, cart),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryP,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            child: Text(text,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold))));
  }
}
