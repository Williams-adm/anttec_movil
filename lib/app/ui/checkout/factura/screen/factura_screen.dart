import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:anttec_movil/app/ui/checkout/boleta/widgets/boleta_widgets.dart';
import 'package:anttec_movil/app/ui/checkout/factura/widgets/factura_widgets.dart';
import 'package:anttec_movil/app/ui/checkout/receipt_view_screen.dart';
import 'package:anttec_movil/data/services/api/v1/sales_service.dart';
import 'package:anttec_movil/data/services/api/v1/customer_service.dart';
import 'package:anttec_movil/data/services/api/v1/payment_service.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

class FacturaScreen extends StatefulWidget {
  const FacturaScreen({super.key});

  @override
  State<FacturaScreen> createState() => _FacturaScreenState();
}

class _FacturaScreenState extends State<FacturaScreen> {
  // Estado de Pago
  String _selectedPayment = 'efectivo';
  String _digitalWallet = 'yape';
  String _selectedOtherType = 'card';
  final String _tipoDocumento = 'RUC';

  // Controladores
  final _rucController = TextEditingController();
  final _razonSocialController = TextEditingController();
  final _direccionController = TextEditingController();
  final _recibidoController = TextEditingController();
  final _opController = TextEditingController();
  final _referenceController = TextEditingController();

  // Servicios
  final _salesService = SalesService();
  final _customerService = CustomerService();
  final _paymentService = PaymentService();

  // Variables de Estado
  double _vuelto = 0.0;
  bool _isProcessing = false;
  bool _isSearchingRuc = false;
  String? _qrImageUrl;
  bool _isLoadingQr = false;
  String? _pdfPath;
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    _cargarImagenQr('yape');
    _rucController.addListener(() {
      if (_rucController.text.isEmpty) {
        setState(() {
          _razonSocialController.clear();
          _direccionController.clear();
        });
      }
    });
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

  // --- LÓGICA DE ZOOM DE QR (Igual que en Boleta) ---
  void _mostrarQrExpandido() {
    if (_qrImageUrl == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Imagen con Zoom (InteractiveViewer)
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.network(
                  _qrImageUrl!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Botón de cerrar
            Positioned(
              top: 0,
              right: 0,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _buscarRuc() async {
    final ruc = _rucController.text.trim();
    if (ruc.length != 11) return;
    setState(() => _isSearchingRuc = true);
    try {
      final data = await _customerService.consultarRuc(ruc);
      if (mounted && data != null) {
        setState(() {
          _razonSocialController.text = data['business_name'] ?? '';
          _direccionController.text = data['tax_address'] ?? '';
        });
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

  void _calculateChange(double total) {
    double recibido =
        double.tryParse(_recibidoController.text.replaceAll(',', '.')) ?? 0.0;
    setState(() {
      _vuelto = recibido > total ? recibido - total : 0.0;
    });
  }

  Future<void> _validarYFinalizar(double total, CartProvider cart) async {
    final ruc = _rucController.text.trim();
    String businessName = _razonSocialController.text.trim();
    final address = _direccionController.text.trim();

    // Validaciones RUC
    if (ruc.isEmpty) {
      _showNotice("Falta completar el RUC", Symbols.error, Colors.orange);
      return;
    }
    if (ruc.length != 11) {
      _showNotice(
          "El RUC debe tener 11 dígitos", Symbols.warning, Colors.orange);
      return;
    }
    if (!ruc.startsWith('10') && !ruc.startsWith('20')) {
      _showNotice(
          "RUC inválido (debe iniciar con 10 o 20)", Symbols.block, Colors.red);
      return;
    }

    if (businessName.length < 3) {
      _showNotice(
          "Razón Social muy corta", Symbols.domain_disabled, Colors.orange);
      return;
    }
    if (businessName.length > 80) businessName = businessName.substring(0, 80);
    if (address.isEmpty) {
      _showNotice(
          "Ingrese la Dirección Fiscal", Symbols.location_on, Colors.orange);
      return;
    }

    // Validaciones Pago
    if (_selectedPayment == 'efectivo') {
      double recibido =
          double.tryParse(_recibidoController.text.replaceAll(',', '.')) ?? 0.0;
      if (recibido < total) {
        _showNotice("Efectivo insuficiente", Symbols.money_off, Colors.red);
        return;
      }
    } else if (_selectedPayment == 'yape') {
      final op = _opController.text.trim();
      if (op.isEmpty) {
        _showNotice(
            "Falta el Nro. de Operación", Symbols.receipt_long, Colors.red);
        return;
      }
      if (_digitalWallet == 'yape' && op.length != 8) {
        _showNotice("Nro. Operación Yape debe tener 8 dígitos", Symbols.error,
            Colors.red);
        return;
      }
      if (_digitalWallet == 'plin' && op.length != 7) {
        _showNotice("Nro. Operación Plin debe tener 7 dígitos", Symbols.error,
            Colors.red);
        return;
      }
    }

    setState(() => _isProcessing = true);

    String finalPaymentMethod = "";
    String? finalCode;

    if (_selectedPayment == 'efectivo') {
      finalPaymentMethod = "cash";
    } else if (_selectedPayment == 'yape') {
      finalPaymentMethod = _digitalWallet;
      finalCode = _opController.text;
    } else {
      finalPaymentMethod = _selectedOtherType;
      finalCode = _referenceController.text;
    }

    final orderData = {
      "type_voucher": "factura",
      "document_type": _tipoDocumento,
      "document_number": ruc,
      "customer": {"business_name": businessName, "tax_address": address},
      "payment_method": finalPaymentMethod,
      if (finalCode != null && finalCode.isNotEmpty)
        "payment_method_code": finalCode,
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
      String? voucherNumber;

      if (res.data != null && res.data['voucher'] != null) {
        voucherNumber = res.data['voucher']['number'];
        String rawBase64 = res.data['voucher']['content']
            .toString()
            .replaceAll(RegExp(r'\s+'), '');
        final bytes = base64Decode(rawBase64);
        _pdfBytes = bytes;

        final dir = await getApplicationDocumentsDirectory();
        final file = File(
            '${dir.path}/fac_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(bytes, flush: true);
        setState(() => _pdfPath = file.path);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptViewScreen(
              pdfPath: _pdfPath ?? '',
              pdfBytes: _pdfBytes,
              saleData: {
                'id': voucherNumber ?? 'FACTURA ELECTRÓNICA',
                'type': 'Factura',
                'amount': total,
                'customer_name': _razonSocialController.text.trim(),
                'doc_number': _rucController.text.trim(),
                'items': cart.items
                    .map((e) => {
                          'qty': e.quantity,
                          'name': e.name,
                          'price': e.price,
                          'total': e.price * e.quantity
                        })
                    .toList()
              },
            ),
          ),
        );
      }
    } catch (e) {
      _showNotice("Error al procesar la factura", Symbols.error, Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = cart.totalAmount;

    return PopScope(
      canPop: !_isProcessing,
      child: Scaffold(
        appBar: AppBar(
            title: const Text("Venta: Factura",
                style: TextStyle(fontWeight: FontWeight.w900))),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyHeaderSection(
                  rucController: _rucController,
                  isSearching: _isSearchingRuc,
                  onSearch: _buscarRuc),
              BoletaInputField(
                  label: "Razón Social",
                  icon: Symbols.business,
                  controller: _razonSocialController),
              BoletaInputField(
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
              PaymentMethodsSelector(
                  selectedPayment: _selectedPayment,
                  onPaymentChanged: (v) =>
                      setState(() => _selectedPayment = v)),
              const SizedBox(height: 25),
              if (_selectedPayment == 'efectivo')
                CashPaymentPanel(
                    controller: _recibidoController,
                    total: total,
                    vuelto: _vuelto,
                    onChanged: (_) => _calculateChange(total)),
              if (_selectedPayment == 'yape')
                DigitalWalletPanel(
                  selectedWallet: _digitalWallet,
                  onWalletChanged: (v) {
                    setState(() => _digitalWallet = v);
                    _cargarImagenQr(v);
                  },
                  isLoadingQr: _isLoadingQr,
                  qrImageUrl: _qrImageUrl,
                  opController: _opController,
                  onQrTap: _mostrarQrExpandido, // Pasamos la función aquí
                ),
              if (_selectedPayment == 'otros')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tipo de Transacción",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 15),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.2,
                      children: [
                        _buildSubtypeButton(
                            "Tarjeta", Symbols.credit_card, 'card'),
                        _buildSubtypeButton(
                            "Transf.", Symbols.account_balance, 'transfers'),
                        _buildSubtypeButton(
                            "Depósito", Symbols.savings, 'deposits'),
                        _buildSubtypeButton(
                            "Otros", Symbols.more_horiz, 'others'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    BoletaInputField(
                      label: "Referencia (opcional)",
                      icon: Symbols.receipt_long,
                      controller: _referenceController,
                      borderColor: Colors.black, // Borde Negro
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              AmountSummary(total: total),
              const SizedBox(height: 30),
              BoletaFooter(
                  total: total,
                  isProcessing: _isProcessing,
                  onProcess: () => _validarYFinalizar(total, cart)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtypeButton(String label, IconData icon, String value) {
    bool isSelected = _selectedOtherType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedOtherType = value),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryP : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: isSelected ? AppColors.primaryP : Colors.grey.shade300),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.grey),
          Text(label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }

  void _showNotice(String msg, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        content: Row(children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style: const TextStyle(fontWeight: FontWeight.bold)))
        ])));
  }
}
