import 'package:anttec_movil/data/services/api/v1/customer_service.dart';
import 'package:anttec_movil/data/services/api/v1/printer_service.dart';
import 'package:anttec_movil/data/services/api/v1/payment_service.dart';
import 'package:anttec_movil/app/ui/sales_report/widgets/printer_selector_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
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
  // Configuración de Pago
  String _selectedPayment = 'efectivo';
  String _digitalWallet = 'yape';
  String _selectedOtherType = 'card';

  final TextEditingController _rucController = TextEditingController();
  final TextEditingController _razonSocialController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  final TextEditingController _recibidoController = TextEditingController();
  final TextEditingController _opController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  final PrinterService _printerService = PrinterService();
  final PaymentService _paymentService = PaymentService();
  final CustomerService _customerService = CustomerService();

  double _vuelto = 0.0;
  bool _isProcessing = false;
  bool _isSearchingRuc = false;

  String? _qrImageUrl;
  bool _isLoadingQr = false;

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

  // --- LOGICA BUSQUEDA RUC ---
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
    _razonSocialController.clear();
    _direccionController.clear();

    try {
      final data = await _customerService.consultarRuc(ruc);
      if (!mounted) return;

      if (data != null) {
        setState(() {
          _razonSocialController.text = data['business_name'] ?? '';
          _direccionController.text = data['tax_address'] ?? '';
        });
        _showCustomNotice(
            message: "Datos de SUNAT obtenidos",
            icon: Symbols.check_circle,
            color: Colors.green);
      } else {
        _showCustomNotice(
            message: "RUC no encontrado",
            icon: Symbols.domain_disabled,
            color: Colors.redAccent);
      }
    } catch (e) {
      if (mounted) {
        _showCustomNotice(
            message: "Error al consultar SUNAT",
            icon: Symbols.wifi_off,
            color: Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isSearchingRuc = false);
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

  void _cambiarBilletera(String wallet) {
    if (_digitalWallet != wallet) {
      setState(() => _digitalWallet = wallet);
      _cargarImagenQr(wallet);
    }
  }

  // --- VALIDACION ---
  void _validarYFinalizar(double total, CartProvider cart) async {
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

    // 1. Efectivo
    if (_selectedPayment == 'efectivo') {
      double recibido = double.tryParse(_recibidoController.text) ?? 0.0;
      if (recibido < total) {
        _showCustomNotice(
            message: "Efectivo insuficiente",
            icon: Symbols.payments,
            color: Colors.redAccent);
        return;
      }
      _showSuccessDialog(total, cart);
    }
    // 2. Yape/Plin
    else if (_selectedPayment == 'yape') {
      if (_opController.text.isEmpty) {
        _showCustomNotice(
            message: "Ingresa el Nro. de Operación",
            icon: Symbols.qr_code_2,
            color: Colors.blueAccent);
        return;
      }
      await _procesarPagoApi(total, cart, _razonSocialController.text,
          _digitalWallet, _opController.text);
    }
    // 3. Otros
    else if (_selectedPayment == 'otros') {
      if (_referenceController.text.isEmpty) {
        _showCustomNotice(
            message: "Ingrese Código/Ref.",
            icon: Symbols.receipt_long,
            color: Colors.blueAccent);
        return;
      }
      await _procesarPagoApi(total, cart, _razonSocialController.text,
          _selectedOtherType, _referenceController.text);
    }
  }

  Future<void> _procesarPagoApi(double total, CartProvider cart, String cliente,
      String metodo, String ref) async {
    setState(() => _isProcessing = true);
    try {
      await _paymentService.procesarPagoDigital(
        wallet: metodo,
        numeroOperacion: ref,
        monto: total,
        nombreCliente: cliente,
        documento: _rucController.text,
      );

      if (!mounted) return;
      _showSuccessDialog(total, cart);
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.error.toString();
      _showCustomNotice(
          message: message, icon: Symbols.error, color: Colors.red);
    } catch (e) {
      if (!mounted) return;
      _showCustomNotice(
          message: "Error: $e", icon: Symbols.error, color: Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // --- UI HELPERS ---

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

  void _showSuccessDialog(double total, CartProvider cart) {
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
                      cart.clearCart();
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildInputField(
                      label: "RUC",
                      hint: "11 dígitos",
                      icon: Symbols.business,
                      controller: _rucController,
                      isNumeric: true,
                      maxLength: 11),
                ),
                const SizedBox(width: 10),
                _buildSearchButton(),
              ],
            ),
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
              const SizedBox(width: 10),
              Expanded(
                  child: _buildPaymentMiniCard(
                      "Yape/Plin", Symbols.qr_code_scanner, 'yape')),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildPaymentMiniCard(
                      "Otros", Symbols.more_horiz, 'otros')),
            ]),
            const SizedBox(height: 25),
            if (_selectedPayment == 'efectivo')
              _buildCashCalculator(totalPagar),
            if (_selectedPayment == 'yape')
              _buildDigitalWalletSelector(totalPagar),
            if (_selectedPayment == 'otros') _buildOtherPaymentSelector(),
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

  // --- WIDGETS AUXILIARES ---

  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: _isSearchingRuc ? null : _buscarRuc,
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: AppColors.primaryP,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: _isSearchingRuc
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Icon(Symbols.search, color: Colors.white),
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
            Icon(icon,
                color: isSelected ? Colors.white : AppColors.primaryP,
                size: 28),
            const SizedBox(height: 5),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.extradarkT,
                    fontSize: 12,
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
        _isLoadingQr
            ? const SizedBox(
                height: 180, child: Center(child: CircularProgressIndicator()))
            : _qrImageUrl != null
                ? Container(
                    height: 250,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: _qrImageUrl!,
                        fit: BoxFit.contain,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Symbols.broken_image, size: 50),
                      ),
                    ),
                  )
                : Icon(Symbols.qr_code_2,
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
      onTap: () => _cambiarBilletera(value),
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

  // --- WIDGET ACTUALIZADO: Selector de "OTROS" en cuadrícula 2x2 ---
  Widget _buildOtherPaymentSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.primaryS,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.tertiaryS)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tipo de Transacción",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.semidarkT)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                  child:
                      _buildOtherTypeChip("Card", Symbols.credit_card, "card")),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildOtherTypeChip(
                      "Transfer", Symbols.account_balance, "transfers")),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildOtherTypeChip(
                      "Deposit", Symbols.savings, "deposits")),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildOtherTypeChip(
                      "Others", Symbols.confirmation_number, "others")),
            ],
          ),
          const SizedBox(height: 25),
          _buildInputField(
            label: "Referencia / Código",
            hint: "Nro. transacción o nota",
            icon: Symbols.receipt_long,
            controller: _referenceController,
          ),
        ],
      ),
    );
  }

  // --- WIDGET ACTUALIZADO: Chip más grande ---
  Widget _buildOtherTypeChip(String label, IconData icon, String value) {
    bool isSelected = _selectedOtherType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedOtherType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryP : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? AppColors.primaryP : Colors.grey.shade300,
                width: isSelected ? 2 : 1),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: AppColors.primaryP.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ]
                : null),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 32,
                color: isSelected ? Colors.white : AppColors.semidarkT),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppColors.semidarkT)),
          ],
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

  Widget _buildActionButton(
      BuildContext context, String text, double total, CartProvider cart) {
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
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text(text,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold))));
  }
}
