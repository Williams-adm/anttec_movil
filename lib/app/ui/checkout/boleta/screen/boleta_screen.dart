import 'dart:convert';
import 'dart:io';
// IMPORTS PROPIOS
import 'package:anttec_movil/app/ui/checkout/boleta/widgets/boleta_widgets.dart';
import 'package:anttec_movil/app/ui/checkout/receipt_view_screen.dart';
import 'package:anttec_movil/data/services/api/v1/sales_service.dart';
import 'package:anttec_movil/data/services/api/v1/customer_service.dart';
import 'package:anttec_movil/data/services/api/v1/payment_service.dart';
// IMPORTS FLUTTER
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

class BoletaScreen extends StatefulWidget {
  const BoletaScreen({super.key});

  @override
  State<BoletaScreen> createState() => _BoletaScreenState();
}

class _BoletaScreenState extends State<BoletaScreen> {
  // --- ESTADO ---
  String _selectedPayment = 'efectivo';
  String _digitalWallet = 'yape';
  String _selectedOtherType = 'card';
  String _tipoDocumento = 'DNI';

  // --- CONTROLADORES ---
  final _docNumberController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _recibidoController = TextEditingController();
  final _opController = TextEditingController();
  final _referenceController = TextEditingController();

  // --- SERVICIOS ---
  final _salesService = SalesService();
  final _customerService = CustomerService();
  final _paymentService = PaymentService();

  // --- VARIABLES LÓGICAS ---
  double _vuelto = 0.0;
  bool _isProcessing = false;
  bool _isSearchingDni = false;
  String? _qrImageUrl;
  bool _isLoadingQr = false;
  String? _pdfPath;

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

  // --- LÓGICA DE NEGOCIO ---

  Future<void> _buscarDni() async {
    final dni = _docNumberController.text.trim();
    if (dni.length != 8) {
      _showMsg("DNI debe tener 8 dígitos", Colors.orange);
      return;
    }
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
    // 1. Validaciones
    final docLen = _docNumberController.text.length;
    if (_tipoDocumento == 'DNI' && docLen != 8) {
      _showMsg("DNI incorrecto", Colors.red);
      return;
    }
    if (_tipoDocumento == 'CE' && (docLen < 8 || docLen > 12)) {
      _showMsg("CE inválido", Colors.red);
      return;
    }
    if (_nombreController.text.isEmpty || _apellidoController.text.isEmpty) {
      _showMsg("Complete datos del cliente", Colors.orange);
      return;
    }

    // 2. Preparar datos de pago
    String paymentMethod = '';
    String? paymentCode;
    double? cashAmount;

    if (_selectedPayment == 'efectivo') {
      double recibido = double.tryParse(_recibidoController.text) ?? 0.0;
      if (recibido < total) {
        _showMsg("Pago insuficiente", Colors.red);
        return;
      }
      paymentMethod = 'cash';
      cashAmount = recibido;
    } else if (_selectedPayment == 'yape') {
      if (_opController.text.isEmpty) {
        _showMsg("Falta Nro Operación", Colors.orange);
        return;
      }
      paymentMethod = _digitalWallet;
      paymentCode = _opController.text;
    } else {
      paymentMethod = _selectedOtherType;
      paymentCode = _referenceController.text;
    }

    setState(() => _isProcessing = true);

    // 3. Crear Objeto de Venta (CON INT PARA SERVIDOR)
    final orderData = {
      "type_voucher": "boleta",
      "document_type": _tipoDocumento,
      "document_number": int.tryParse(_docNumberController.text) ?? 0,
      "customer": {
        "name": _nombreController.text,
        "last_name": _apellidoController.text
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

    // 4. Enviar al Servidor
    try {
      final res = await _salesService.createOrder(orderData);

      if (!mounted) return;

      if (res.data['voucher'] != null) {
        final bytes = base64Decode(res.data['voucher']['content']);
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${res.data['voucher']['filename']}');
        await file.writeAsBytes(bytes);
        setState(() => _pdfPath = file.path);
      }
      _showSuccessDialog(total, cart);
    } catch (e) {
      _showMsg("Error al procesar venta", Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // --- VISTA PRINCIPAL (UI) ---
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = cart.totalAmount;

    return Scaffold(
      appBar: AppBar(
          title: const Text("Finalizar Boleta",
              style: TextStyle(fontWeight: FontWeight.w900))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SECCIÓN CLIENTE
            const Text("Datos del Cliente",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.extradarkT)),
            const SizedBox(height: 15),

            ClientHeaderSection(
              tipoDocumento: _tipoDocumento,
              onTypeChanged: (val) {
                setState(() => _tipoDocumento = val);
                _docNumberController.clear();
              },
              docController: _docNumberController,
              isSearching: _isSearchingDni,
              onSearch: _buscarDni,
            ),

            BoletaInputField(
                label: "Nombres",
                icon: Symbols.person,
                controller: _nombreController),
            BoletaInputField(
                label: "Apellidos",
                icon: Symbols.person_add,
                controller: _apellidoController),

            const SizedBox(height: 35),

            // 2. SECCIÓN PAGO
            const Text("Método de Pago",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.extradarkT)),
            const SizedBox(height: 15),

            PaymentMethodsSelector(
              selectedPayment: _selectedPayment,
              onPaymentChanged: (val) => setState(() => _selectedPayment = val),
            ),

            const SizedBox(height: 25),

            // 3. PANELES DINÁMICOS
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
                  onTypeChanged: (v) => setState(() => _selectedOtherType = v),
                  refController: _referenceController),

            // 4. FOOTER Y BOTÓN
            const SizedBox(height: 30),
            BoletaFooter(
                total: total,
                isProcessing: _isProcessing,
                onProcess: () => _validarYFinalizar(total, cart)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- UTILIDADES ---
  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(backgroundColor: color, content: Text(msg)));
  }

  void _showSuccessDialog(double total, CartProvider cart) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Venta Exitosa", textAlign: TextAlign.center),
        content: const Text("La boleta se ha generado correctamente.",
            textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              if (_pdfPath != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ReceiptViewScreen(pdfPath: _pdfPath!, saleData: {
                              'id': 'B001-NEW',
                              'type': 'Boleta',
                              'amount': total,
                              'date': 'Ahora',
                              'customer_name':
                                  '${_nombreController.text} ${_apellidoController.text}',
                              'items': cart.items
                                  .map((e) => {
                                        'qty': e.quantity,
                                        'name': e.name,
                                        'total': e.price * e.quantity
                                      })
                                  .toList()
                            })));
              }
            },
            icon: const Icon(Symbols.visibility),
            label: const Text("VER BOLETA"),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryP,
                foregroundColor: Colors.white),
          ),
          TextButton(
            onPressed: () {
              cart.clearCart();
              context.go('/home');
            },
            child: const Text("SALIR"),
          ),
        ],
      ),
    );
  }
}
