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
  String _selectedPayment = 'efectivo';
  String _digitalWallet = 'yape';
  final String _selectedOtherType = 'card';
  final String _tipoDocumento = 'RUC';

  final _rucController = TextEditingController();
  final _razonSocialController = TextEditingController();
  final _direccionController = TextEditingController();
  final _recibidoController = TextEditingController();
  final _opController = TextEditingController();
  final _referenceController = TextEditingController();

  final _salesService = SalesService();
  final _customerService = CustomerService();
  final _paymentService = PaymentService();

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
    // 1. VALIDACIÓN: Datos fiscales
    if (_razonSocialController.text.trim().isEmpty ||
        _direccionController.text.trim().isEmpty) {
      _showNotice(
          "Complete Razón Social y Dirección", Symbols.domain, Colors.orange);
      return;
    }

    // 2. VALIDACIÓN: Pago
    if (_selectedPayment == 'efectivo') {
      double recibido =
          double.tryParse(_recibidoController.text.replaceAll(',', '.')) ?? 0.0;
      if (recibido < total) {
        _showNotice("Efectivo insuficiente", Symbols.money_off, Colors.red);
        return;
      }
    }

    setState(() => _isProcessing = true);

    final orderData = {
      "type_voucher": "factura",
      "document_type": _tipoDocumento,
      "document_number": int.tryParse(_rucController.text) ?? 0,
      "customer": {
        "business_name": _razonSocialController.text.trim(),
        "tax_address": _direccionController.text.trim()
      },
      "payment_method": _selectedPayment == 'efectivo'
          ? 'cash'
          : (_selectedPayment == 'yape' ? _digitalWallet : _selectedOtherType),
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
      if (res.data['voucher'] != null) {
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
      _showSuccessDialog(total, cart);
    } catch (e) {
      _showNotice("Error al procesar factura", Symbols.error, Colors.red);
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
                    opController: _opController),
              if (_selectedPayment == 'otros')
                OtherPaymentPanel(
                    selectedType: _selectedOtherType,
                    onTypeChanged: (v) =>
                        setState(() => _selectedPayment = 'otros'),
                    refController: _referenceController),
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

  void _showSuccessDialog(double total, CartProvider cart) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Icon(Symbols.check_circle,
                color: Colors.green, size: 80, fill: 1),
            const SizedBox(height: 20),
            const Text("¡Factura Emitida!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            const Text("La factura ha sido procesada con éxito.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 14)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ReceiptViewScreen(
                              pdfPath: _pdfPath!,
                              pdfBytes: _pdfBytes,
                              saleData: {
                                'id': 'PROCESADA',
                                'type': 'Factura',
                                'amount': total,
                                'customer_name': _razonSocialController.text,
                                'items': cart.items
                                    .map((e) => {
                                          'qty': e.quantity,
                                          'name': e.name,
                                          'total': e.price * e.quantity
                                        })
                                    .toList()
                              },
                            )));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryP,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: const Text("VER FACTURA",
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}
