import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:anttec_movil/data/services/api/v1/sales_service.dart';
import 'package:anttec_movil/data/services/api/v1/customer_service.dart';
import 'package:anttec_movil/data/services/api/v1/payment_service.dart';
import 'package:anttec_movil/app/ui/sales_report/screen/pdf_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  String _selectedOtherType = 'card';

  final TextEditingController _rucController = TextEditingController();
  final TextEditingController _razonSocialController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _recibidoController = TextEditingController();
  final TextEditingController _opController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  final SalesService _salesService = SalesService();
  final CustomerService _customerService = CustomerService();
  final PaymentService _paymentService = PaymentService();

  bool _isProcessing = false;
  bool _isSearchingRuc = false;
  String? _qrImageUrl;
  bool _isLoadingQr = false;
  double _vuelto = 0.0;
  String? _pdfPath;

  @override
  void initState() {
    super.initState();
    _cargarImagenQr('yape');
  }

  @override
  void dispose() {
    _rucController.dispose();
    _razonSocialController.dispose();
    _direccionController.dispose();
    _recibidoController.dispose();
    _opController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE APOYO ---

  Future<void> _buscarRuc() async {
    final ruc = _rucController.text.trim();
    if (ruc.length != 11) {
      _showCustomNotice(
          message: "El RUC debe tener 11 dígitos",
          icon: Symbols.warning,
          color: Colors.orange);
      return;
    }

    setState(() => _isSearchingRuc = true);

    try {
      final data = await _customerService.consultarRuc(ruc);

      if (mounted && data != null) {
        setState(() {
          _razonSocialController.text = data['business_name'] ?? '';
          _direccionController.text = data['tax_address'] ?? '';
        });
        _showCustomNotice(
            message: "Datos de empresa cargados",
            icon: Symbols.check_circle,
            color: Colors.green);
      } else {
        _showCustomNotice(
            message: "No se encontró información del RUC",
            icon: Symbols.search_off,
            color: Colors.red);
      }
    } catch (e) {
      _showCustomNotice(
          message: "Error de red al consultar RUC",
          icon: Symbols.error,
          color: Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isSearchingRuc = false);
      }
    }
  }

  Future<void> _guardarPdfLocal(Map<String, dynamic> voucherData) async {
    try {
      final bytes = base64Decode(voucherData['content']);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${voucherData['filename']}');
      await file.writeAsBytes(bytes);
      setState(() => _pdfPath = file.path);
    } catch (e) {
      debugPrint("Error al guardar PDF: $e");
    }
  }

  void _abrirFactura() {
    if (_pdfPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PdfViewerScreen(path: _pdfPath!, title: "Factura Electrónica"),
        ),
      );
    }
  }

  Future<void> _cargarImagenQr(String wallet) async {
    setState(() {
      _isLoadingQr = true;
      _qrImageUrl = null;
    });
    final url = await _paymentService.obtenerInfoBilletera(wallet);
    if (mounted) {
      setState(() {
        _qrImageUrl = url;
        _isLoadingQr = false;
      });
    }
  }

  void _calculateChange(double total) {
    double recibido =
        double.tryParse(_recibidoController.text.replaceAll(',', '.')) ?? 0.0;
    setState(() {
      _vuelto = recibido > total ? recibido - total : 0.0;
    });
  }

  // --- PROCESAR VENTA ---

  void _validarYFinalizar(double total, CartProvider cart) async {
    final rucText = _rucController.text.trim();

    if (rucText.length != 11) {
      _showCustomNotice(
          message: "Verifica el número de RUC",
          icon: Symbols.warning,
          color: Colors.orange);
      return;
    }
    if (_razonSocialController.text.trim().isEmpty) {
      _showCustomNotice(
          message: "Falta completar Razón Social",
          icon: Symbols.business,
          color: Colors.orange);
      return;
    }

    String paymentMethod = '';
    String? paymentCode;
    double? cashAmount;

    if (_selectedPayment == 'efectivo') {
      double recibido =
          double.tryParse(_recibidoController.text.replaceAll(',', '.')) ?? 0.0;
      if (recibido < total) {
        _showCustomNotice(
            message: "Efectivo insuficiente",
            icon: Symbols.error,
            color: Colors.redAccent);
        return;
      }
      paymentMethod = 'cash';
      cashAmount = recibido;
    } else if (_selectedPayment == 'yape') {
      if (_opController.text.trim().isEmpty) {
        _showCustomNotice(
            message: "Falta Nro. Operación",
            icon: Symbols.qr_code_2,
            color: Colors.blue);
        return;
      }
      paymentMethod = _digitalWallet;
      paymentCode = _opController.text;
    } else {
      if (_referenceController.text.trim().isEmpty) {
        _showCustomNotice(
            message: "Falta Referencia",
            icon: Symbols.receipt_long,
            color: Colors.blue);
        return;
      }
      paymentMethod = _selectedOtherType;
      paymentCode = _referenceController.text;
    }

    setState(() => _isProcessing = true);

    final Map<String, dynamic> orderData = {
      "type_voucher": "factura",
      "document_type": "RUC",
      "document_number": int.tryParse(rucText) ?? 0,
      "customer": {
        "business_name": _razonSocialController.text.trim(),
        "tax_address": _direccionController.text.trim(),
      },
      "payment_method": paymentMethod,
      if (paymentCode != null) "payment_method_code": paymentCode,
      if (cashAmount != null) "cash": cashAmount,
      "items": cart.items
          .map((i) => {
                "product_id": i.id,
                "quantity": i.quantity,
                "price": i.price,
                "name": i.name
              })
          .toList(),
      "total": total
    };

    try {
      final res = await _salesService.createOrder(orderData);
      if (!mounted) {
        return;
      }
      if (res.data['voucher'] != null) {
        await _guardarPdfLocal(res.data['voucher']);
      }
      _showSuccessDialog(total, cart);
    } catch (e) {
      _showCustomNotice(
          message: "Error de conexión con el servidor",
          icon: Symbols.wifi_off,
          color: Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = cart.totalAmount;
    return Scaffold(
      appBar: AppBar(
          title: const Text("Venta: Factura",
              style: TextStyle(fontWeight: FontWeight.w900))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Datos de la Empresa",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.extradarkT)),
          const SizedBox(height: 15),
          Row(children: [
            Expanded(
                child: _buildInputField(
                    label: "Número RUC",
                    icon: Symbols.badge,
                    controller: _rucController,
                    isNumeric: true,
                    maxLength: 11)),
            const SizedBox(width: 10),
            _buildSearchButtonRuc(),
          ]),
          _buildInputField(
              label: "Razón Social",
              icon: Symbols.business,
              controller: _razonSocialController),
          _buildInputField(
              label: "Dirección Fiscal",
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
            _buildPaymentMiniCard("Efectivo", Symbols.payments, 'efectivo'),
            const SizedBox(width: 10),
            _buildPaymentMiniCard("Digital", Symbols.qr_code_scanner, 'yape'),
            const SizedBox(width: 10),
            _buildPaymentMiniCard("Otros", Symbols.more_horiz, 'otros'),
          ]),
          const SizedBox(height: 25),
          if (_selectedPayment == 'efectivo') _buildCashCalculator(total),
          if (_selectedPayment == 'yape') _buildDigitalWalletSelector(),
          if (_selectedPayment == 'otros') _buildOtherPaymentSelector(),
          const SizedBox(height: 30),
          _buildSummaryBox(total),
          const SizedBox(height: 30),
          _buildActionButton(total, cart),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  // --- WIDGETS UI ---

  Widget _buildSearchButtonRuc() {
    return GestureDetector(
      onTap: _isSearchingRuc ? null : _buscarRuc,
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
            color: AppColors.primaryP, borderRadius: BorderRadius.circular(16)),
        child: Center(
            child: _isSearchingRuc
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Symbols.search, color: Colors.white)),
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
              FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*'))
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
      required IconData icon,
      required TextEditingController controller,
      bool isNumeric = false,
      int? maxLength}) {
    return Padding(
        padding: const EdgeInsets.only(top: 15),
        child: TextField(
            controller: controller,
            maxLength: maxLength,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            inputFormatters: [
              if (isNumeric) FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
                counterText: "",
                labelText: label,
                prefixIcon: Icon(icon, color: AppColors.primaryP),
                filled: true,
                fillColor: AppColors.primaryS,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none))));
  }

  Widget _buildPaymentMiniCard(String title, IconData icon, String value) {
    bool sel = _selectedPayment == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPayment = value),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
                color: sel ? AppColors.primaryP : AppColors.primaryS,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: sel ? AppColors.primaryP : AppColors.tertiaryS)),
            child: Column(children: [
              Icon(icon, color: sel ? Colors.white : AppColors.primaryP),
              const SizedBox(height: 5),
              Text(title,
                  style: TextStyle(
                      color: sel ? Colors.white : AppColors.extradarkT,
                      fontSize: 12,
                      fontWeight: FontWeight.bold))
            ])),
      ),
    );
  }

  Widget _buildDigitalWalletSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.primaryS, borderRadius: BorderRadius.circular(24)),
      child: Column(children: [
        Row(children: [
          Expanded(
              child: ActionChip(
                  label: const Text("Yape"),
                  onPressed: () {
                    setState(() => _digitalWallet = 'yape');
                    _cargarImagenQr('yape');
                  },
                  backgroundColor: _digitalWallet == 'yape'
                      ? AppColors.primaryP.withValues(alpha: 0.2)
                      : null)),
          const SizedBox(width: 10),
          Expanded(
              child: ActionChip(
                  label: const Text("Plin"),
                  onPressed: () {
                    setState(() => _digitalWallet = 'plin');
                    _cargarImagenQr('plin');
                  },
                  backgroundColor: _digitalWallet == 'plin'
                      ? AppColors.primaryP.withValues(alpha: 0.2)
                      : null)),
        ]),
        const SizedBox(height: 20),
        if (_isLoadingQr)
          const CircularProgressIndicator()
        else if (_qrImageUrl != null)
          Padding(
              padding: const EdgeInsets.all(15),
              child: CachedNetworkImage(imageUrl: _qrImageUrl!, height: 180))
        else
          const Icon(Symbols.qr_code_2, size: 80),
        _buildInputField(
            label: "Nro. Operación",
            icon: Symbols.receipt_long,
            controller: _opController),
      ]),
    );
  }

  Widget _buildOtherPaymentSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.primaryS, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Tipo de Transacción",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.semidarkT)),
        const SizedBox(height: 15),
        Row(children: [
          _buildOtherChip("Tarjeta", Symbols.credit_card, "card"),
          const SizedBox(width: 10),
          _buildOtherChip("Transf.", Symbols.account_balance, "transfers"),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _buildOtherChip("Depósito", Symbols.savings, "deposits"),
          const SizedBox(width: 10),
          _buildOtherChip("Otros", Symbols.confirmation_number, "others"),
        ]),
        _buildInputField(
            label: "Referencia",
            icon: Symbols.receipt_long,
            controller: _referenceController),
      ]),
    );
  }

  Widget _buildOtherChip(String label, IconData icon, String value) {
    bool sel = _selectedOtherType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedOtherType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: sel ? AppColors.primaryP : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: sel ? AppColors.primaryP : Colors.grey.shade300)),
          child: Column(children: [
            Icon(icon,
                size: 20, color: sel ? Colors.white : AppColors.semidarkT),
            Text(label,
                style: TextStyle(
                    color: sel ? Colors.white : AppColors.semidarkT,
                    fontWeight: FontWeight.bold,
                    fontSize: 11))
          ]),
        ),
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

  Widget _buildActionButton(double total, CartProvider cart) {
    return SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
            onPressed:
                _isProcessing ? null : () => _validarYFinalizar(total, cart),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryP,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("REGISTRAR FACTURA",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18))));
  }

  void _showCustomNotice(
      {required String message, required IconData icon, required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        content: Row(children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(message, style: const TextStyle(fontWeight: FontWeight.bold))
        ])));
  }

  void _showSuccessDialog(double total, CartProvider cart) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (ctx, a1, a2) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Symbols.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 20),
          const Text("¡Venta Exitosa!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _abrirFactura(),
              icon: const Icon(Symbols.visibility),
              label: const Text("VER FACTURA"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryP,
                  foregroundColor: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                cart.clearCart();
                ctx.go('/home');
              },
              icon: const Icon(Symbols.logout),
              label: const Text("SALIR"),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryP,
                  side: const BorderSide(color: AppColors.primaryP)),
            ),
          ),
        ]),
      ),
    );
  }
}
