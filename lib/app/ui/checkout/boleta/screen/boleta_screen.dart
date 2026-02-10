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
import 'package:anttec_movil/app/core/styles/colors.dart';

class BoletaScreen extends StatefulWidget {
  const BoletaScreen({super.key});

  @override
  State<BoletaScreen> createState() => _BoletaScreenState();
}

class _BoletaScreenState extends State<BoletaScreen> {
  String _selectedPayment = 'efectivo';
  String _digitalWallet = 'yape';
  String _selectedOtherType = 'card';
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
    if (_docNumberController.text.trim().isEmpty) {
      _showNotice(
          _tipoDocumento == 'DNI'
              ? "Falta completar el DNI"
              : "Falta completar CE",
          Symbols.badge,
          Colors.orange);
      return;
    }

    if (_nombreController.text.trim().isEmpty ||
        _apellidoController.text.trim().isEmpty) {
      _showNotice(
          "Complete Nombres y Apellidos", Symbols.person_alert, Colors.orange);
      return;
    }

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
        _showNotice("Nro. Operación Yape debe tener 8 números", Symbols.error,
            Colors.red);
        return;
      }
      if (_digitalWallet == 'plin' && op.length != 7) {
        _showNotice("Nro. Operación Plin debe tener 7 números", Symbols.error,
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
      "type_voucher": "boleta",
      "document_type": _tipoDocumento,
      "document_number": _docNumberController.text.trim(),
      "customer": {
        "name": _nombreController.text.trim(),
        "last_name": _apellidoController.text.trim()
      },
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
      final voucherData = res.data['voucher'];

      if (voucherData != null) {
        String rawBase64 =
            voucherData['content'].toString().replaceAll(RegExp(r'\s+'), '');
        final bytes = base64Decode(rawBase64);
        _pdfBytes = bytes;

        final dir = await getApplicationDocumentsDirectory();
        final file = File(
            '${dir.path}/bol_${DateTime.now().millisecondsSinceEpoch}.pdf');
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
                'id': voucherData?['number'] ?? 'B001-000',
                'type': 'Boleta',
                'amount': total,
                'customer_name':
                    '${_nombreController.text} ${_apellidoController.text}',
                'doc_number': _docNumberController.text.trim(),
                'date': voucherData?['date'] ?? '10/02/2026',
                'qr_content': voucherData?['external_id'] ?? '',
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
      canPop: !_isProcessing,
      child: Scaffold(
        appBar: AppBar(
            title: const Text("Finalizar Boleta",
                style: TextStyle(fontWeight: FontWeight.w900))),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              ClientHeaderSection(
                  tipoDocumento: _tipoDocumento,
                  onTypeChanged: (v) {
                    setState(() {
                      _tipoDocumento = v;
                      _docNumberController.clear();
                      _nombreController.clear();
                      _apellidoController.clear();
                    });
                  },
                  docController: _docNumberController,
                  isSearching: _isSearchingDni,
                  onSearch: _buscarDni),
              BoletaInputField(
                  label: "Nombres",
                  icon: Symbols.person,
                  controller: _nombreController),
              BoletaInputField(
                  label: "Apellidos",
                  icon: Symbols.person_add,
                  controller: _apellidoController),
              const SizedBox(height: 25),
              PaymentMethodsSelector(
                  selectedPayment: _selectedPayment,
                  onPaymentChanged: (v) =>
                      setState(() => _selectedPayment = v)),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
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
