import 'package:anttec_movil/data/services/api/v1/customer_service.dart'; // <--- IMPORTANTE
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

class BoletaScreen extends StatefulWidget {
  const BoletaScreen({super.key});

  @override
  State<BoletaScreen> createState() => _BoletaScreenState();
}

class _BoletaScreenState extends State<BoletaScreen> {
  // Configuración de Pago
  String _selectedPayment = 'efectivo';
  String _digitalWallet = 'yape';

  // Configuración de Cliente
  String _tipoDocumento = 'DNI'; // Opciones: 'DNI', 'CE'

  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController =
      TextEditingController(); // Nuevo campo

  final TextEditingController _recibidoController = TextEditingController();
  final TextEditingController _opController = TextEditingController();

  // Servicios
  final PrinterService _printerService = PrinterService();
  final PaymentService _paymentService = PaymentService();
  final CustomerService _customerService = CustomerService(); // Nuevo servicio

  double _vuelto = 0.0;
  bool _isProcessing = false;
  bool _isSearchingDni = false; // Para el loading del botón de búsqueda

  // Variables QR
  String? _qrImageUrl;
  bool _isLoadingQr = false;

  @override
  void initState() {
    super.initState();
    _cargarImagenQr('yape');
  }

  @override
  void dispose() {
    _docNumberController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _recibidoController.dispose();
    _opController.dispose();
    super.dispose();
  }

  // --- LOGICA BUSQUEDA DNI ---
  Future<void> _buscarDni() async {
    final dni = _docNumberController.text.trim();
    if (dni.length != 8) {
      _showCustomNotice(
          message: "El DNI debe tener 8 dígitos",
          icon: Symbols.warning,
          color: Colors.orange);
      return;
    }

    setState(() => _isSearchingDni = true);

    // Limpiamos campos antes de buscar
    _nombreController.clear();
    _apellidoController.clear();

    try {
      final data = await _customerService.consultarDni(dni);

      if (!mounted) return;

      if (data != null) {
        // La API devuelve: name, last_name, document_number
        setState(() {
          _nombreController.text = data['name'] ?? '';
          _apellidoController.text = data['last_name'] ?? '';
        });
        _showCustomNotice(
            message: "Datos encontrados",
            icon: Symbols.check_circle,
            color: Colors.green);
      } else {
        _showCustomNotice(
            message: "DNI no encontrado en RENIEC",
            icon: Symbols.error,
            color: Colors.redAccent);
      }
    } catch (e) {
      if (mounted) {
        _showCustomNotice(
            message: "Error de conexión",
            icon: Symbols.wifi_off,
            color: Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isSearchingDni = false);
    }
  }

  // --- LOGICA IMAGEN QR ---
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

  // --- LOGICA GENERAL UI ---
  void _showCustomNotice(
      {required String message, required IconData icon, required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(milliseconds: 2000),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(message,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14))),
            ],
          ),
        ),
      ),
    );
  }

  void _calculateChange(double total) {
    double recibido = double.tryParse(_recibidoController.text) ?? 0.0;
    setState(() {
      _vuelto = recibido > total ? recibido - total : 0.0;
    });
  }

  void _validarYFinalizar(double total, CartProvider cart) async {
    // Validaciones
    int largoDoc = _tipoDocumento == 'DNI' ? 8 : 12; // CE suele ser hasta 12
    if (_docNumberController.text.length < 8) {
      _showCustomNotice(
          message: "Documento inválido",
          icon: Symbols.info,
          color: Colors.orange);
      return;
    }

    if (_nombreController.text.trim().isEmpty ||
        _apellidoController.text.trim().isEmpty) {
      _showCustomNotice(
          message: "Complete Nombres y Apellidos",
          icon: Symbols.person_alert,
          color: Colors.orange);
      return;
    }

    String nombreCompleto =
        "${_nombreController.text} ${_apellidoController.text}";

    if (_selectedPayment == 'efectivo') {
      double recibido = double.tryParse(_recibidoController.text) ?? 0.0;
      if (recibido < total) {
        _showCustomNotice(
            message: "Monto insuficiente",
            icon: Symbols.warning,
            color: Colors.redAccent);
        return;
      }
      _showSuccessDialog(total, cart);
    } else if (_selectedPayment == 'yape') {
      if (_opController.text.isEmpty) {
        _showCustomNotice(
            message: "Falta Nro. Operación",
            icon: Symbols.qr_code_2,
            color: Colors.blueAccent);
        return;
      }

      setState(() => _isProcessing = true);

      try {
        await _paymentService.procesarPagoDigital(
          wallet: _digitalWallet,
          numeroOperacion: _opController.text,
          monto: total,
          nombreCliente: nombreCompleto,
          documento: _docNumberController.text,
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
  }

  // ... _showSuccessDialog, _abrirSelectorImpresora, _imprimir ...
  // (Mantener igual que antes, solo asegúrate de pasar 'nombreCompleto' si lo usas en el ticket)
  // Por brevedad, asumo que usas los mismos métodos de impresión de la respuesta anterior.
  void _showSuccessDialog(double total, CartProvider cart) {
    // ... (Mismo código de tu showGeneralDialog anterior)
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
                          color: Colors.white, size: 45, weight: 700),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Text("¡Venta Realizada!",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.extradarkT)),
                const SizedBox(height: 10),
                Text("Total cobrado: S/. ${total.toStringAsFixed(2)}",
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
                    label: const Text("IMPRIMIR BOLETA"),
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
      'id': 'B001-${DateTime.now().second}',
      'type': 'Boleta',
      'amount': total,
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
          message: "Ticket enviado correctamente",
          icon: Symbols.print_connect,
          color: Colors.green);
    } catch (e) {
      _showCustomNotice(
          message: "Error de impresión: $e",
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
          title: const Text("Finalizar Boleta",
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
            const Text("Datos del Cliente",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.extradarkT)),
            const SizedBox(height: 15),

            // --- SELECTOR TIPO DOCUMENTO ---
            _buildDocumentTypeSelector(),
            const SizedBox(height: 15),

            // --- INPUT DOCUMENTO CON BOTON DE BUSQUEDA ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildInputField(
                    label: _tipoDocumento == 'DNI' ? "DNI" : "Carnet Ext.",
                    hint: _tipoDocumento == 'DNI'
                        ? "8 dígitos"
                        : "Hasta 12 dígitos",
                    icon: Symbols.badge,
                    controller: _docNumberController,
                    isNumeric: true,
                    maxLength: _tipoDocumento == 'DNI' ? 8 : 12,
                  ),
                ),
                if (_tipoDocumento == 'DNI') ...[
                  const SizedBox(width: 10),
                  _buildSearchButton(),
                ]
              ],
            ),

            const SizedBox(height: 15),

            // --- NOMBRES Y APELLIDOS SEPARADOS ---
            _buildInputField(
                label: "Nombres",
                hint: "Ingrese nombres",
                icon: Symbols.person,
                controller: _nombreController),
            const SizedBox(height: 15),
            _buildInputField(
                label: "Apellidos",
                hint: "Ingrese apellidos",
                icon: Symbols.person_add, // Icono diferente para variar
                controller: _apellidoController),

            const SizedBox(height: 30),
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

  // --- WIDGETS NUEVOS ---

  Widget _buildDocumentTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryS,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildDocTypeButton('DNI')),
          Expanded(child: _buildDocTypeButton('CE')),
        ],
      ),
    );
  }

  Widget _buildDocTypeButton(String type) {
    bool isSelected = _tipoDocumento == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tipoDocumento = type;
          _docNumberController.clear();
          _nombreController.clear();
          _apellidoController.clear();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryP : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            type,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.semidarkT,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: _isSearchingDni ? null : _buscarDni,
      child: Container(
        height: 56, // Altura estándar del input field
        width: 56,
        decoration: BoxDecoration(
          color: AppColors.primaryP,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: _isSearchingDni
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

  // --- WIDGETS EXISTENTES (Mantener) ---
  // (Solo asegúrate de que _buildInputField use el maxLength que le pasamos)

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
    // ... (Mantener implementación previa con _qrImageUrl)
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
