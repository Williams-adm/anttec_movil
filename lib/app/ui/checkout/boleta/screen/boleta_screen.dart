import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:anttec_movil/app/ui/checkout/boleta/widgets/boleta_widgets.dart';
import 'package:anttec_movil/app/ui/checkout/receipt_view_screen.dart';
import 'package:anttec_movil/data/services/api/v1/sales_service.dart';
import 'package:anttec_movil/data/services/api/v1/customer_service.dart';
import 'package:anttec_movil/data/services/api/v1/payment_service.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

class BoletaScreen extends StatefulWidget {
  const BoletaScreen({super.key});

  @override
  State<BoletaScreen> createState() => _BoletaScreenState();
}

class _BoletaScreenState extends State<BoletaScreen> {
  String _selectedPayment = 'efectivo';
  static const String _digitalWallet = 'yape';
  static const String _selectedOtherType = 'card';
  String _tipoDocumento = 'DNI';

  final _docNumberController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _recibidoController = TextEditingController();
  final _opController = TextEditingController();
  final _referenceController = TextEditingController();

  final _salesService = SalesService();
  final _customerService = CustomerService();
  final _paymentService = PaymentService();

  double _vuelto = 0.0;
  bool _isProcessing = false;
  bool _isSearchingDni = false;
  String? _qrImageUrl;
  bool _isLoadingQr = false;
  String? _pdfPath;
  Uint8List? _pdfBytes;

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
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _buscarDni() async {
    final dni = _docNumberController.text.trim();
    if (dni.length != 8) return;
    setState(() => _isSearchingDni = true);
    try {
      final data = await _customerService.consultarDni(dni);
      if (mounted && data != null) {
        setState(() {
          _nombreController.text = data['name'] ?? '';
          _apellidoController.text = data['last_name'] ?? '';
        });
      }
    } finally {
      if (mounted) setState(() => _isSearchingDni = false);
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
    if (_nombreController.text.isEmpty) {
      _showNotice("Complete datos del cliente", Symbols.person, Colors.orange);
      return;
    }

    setState(() => _isProcessing = true);

    final orderData = {
      "type_voucher": "boleta",
      "document_type": _tipoDocumento,
      "document_number": int.tryParse(_docNumberController.text) ?? 0,
      "customer": {
        "name": _nombreController.text,
        "last_name": _apellidoController.text,
      },
      "payment_method": _selectedPayment == 'efectivo'
          ? 'cash'
          : (_selectedPayment == 'yape' ? _digitalWallet : _selectedOtherType),
      "items": cart.items
          .map(
            (i) => {
              "product_id": i.id,
              "quantity": i.quantity,
              "price": i.price,
              "name": i.name,
            },
          )
          .toList(),
      "total": total,
    };

    try {
      final res = await _salesService.createOrder(orderData);
      if (res.data['voucher'] != null) {
        String rawBase64 = res.data['voucher']['content'].toString().replaceAll(
          RegExp(r'\s+'),
          '',
        );
        final bytes = base64Decode(rawBase64);
        _pdfBytes = bytes;

        final dir = await getApplicationDocumentsDirectory();
        final file = File(
          '${dir.path}/bol_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        await file.writeAsBytes(bytes, flush: true);
        setState(() => _pdfPath = file.path);
      }
      _showSuccessDialog(total, cart);
    } catch (e) {
      _showNotice("Error al procesar venta", Symbols.error, Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = cart.totalAmount;

    return PopScope(
      canPop:
          !_isProcessing, // Bloquea el botón atrás si está procesando la venta
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Finalizar Boleta",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              ClientHeaderSection(
                tipoDocumento: _tipoDocumento,
                onTypeChanged: (v) => setState(() => _tipoDocumento = v),
                docController: _docNumberController,
                isSearching: _isSearchingDni,
                onSearch: _buscarDni,
              ),
              BoletaInputField(
                label: "Nombres",
                icon: Symbols.person,
                controller: _nombreController,
              ),
              BoletaInputField(
                label: "Apellidos",
                icon: Symbols.person_add,
                controller: _apellidoController,
              ),
              const SizedBox(height: 25),
              PaymentMethodsSelector(
                selectedPayment: _selectedPayment,
                onPaymentChanged: (v) => setState(() => _selectedPayment = v),
              ),
              const SizedBox(height: 20),
              if (_selectedPayment == 'efectivo')
                CashPaymentPanel(
                  controller: _recibidoController,
                  total: total,
                  vuelto: _vuelto,
                  onChanged: (_) => _calculateChange(total),
                ),
              if (_selectedPayment == 'yape')
                DigitalWalletPanel(
                  selectedWallet: _digitalWallet,
                  onWalletChanged: (v) => _cargarImagenQr(v),
                  isLoadingQr: _isLoadingQr,
                  qrImageUrl: _qrImageUrl,
                  opController: _opController,
                ),
              const SizedBox(height: 20),
              AmountSummary(total: total),
              const SizedBox(height: 30),
              BoletaFooter(
                total: total,
                isProcessing: _isProcessing,
                onProcess: () => _validarYFinalizar(total, cart),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotice(String msg, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(msg),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(double total, CartProvider cart) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Venta Exitosa", textAlign: TextAlign.center),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // ✅ pushReplacement: Elimina BoletaScreen de la pila
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ReceiptViewScreen(
                    pdfPath: _pdfPath ?? '',
                    pdfBytes: _pdfBytes,
                    saleData: {
                      'id': 'PROCESADO',
                      'type': 'Boleta',
                      'amount': total,
                      'date': 'Ahora',
                      'customer_name':
                          '${_nombreController.text} ${_apellidoController.text}',
                      'items': cart.items
                          .map(
                            (e) => {
                              'qty': e.quantity,
                              'name': e.name,
                              'total': e.price * e.quantity,
                            },
                          )
                          .toList(),
                    },
                  ),
                ),
              );
            },
            child: const Text("VER BOLETA"),
          ),
        ],
      ),
    );
  }
}
