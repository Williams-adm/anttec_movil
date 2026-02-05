import 'dart:convert';
import 'dart:io';

// --- RUTAS DE WIDGETS ---
import 'package:anttec_movil/app/ui/checkout/boleta/widgets/boleta_widgets.dart';
import 'package:anttec_movil/app/ui/checkout/factura/widgets/factura_widgets.dart';
import 'package:anttec_movil/app/ui/checkout/receipt_view_screen.dart';

// --- RUTAS DE SERVICIOS ---
import 'package:anttec_movil/data/services/api/v1/sales_service.dart';
import 'package:anttec_movil/data/services/api/v1/customer_service.dart';
import 'package:anttec_movil/data/services/api/v1/payment_service.dart';

// --- FLUTTER ---
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
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
  // --- ESTADO ---
  String _selectedPayment = 'efectivo';
  String _digitalWallet = 'yape';
  String _selectedOtherType = 'card';

  // --- CONTROLADORES ---
  final _rucController = TextEditingController();
  final _razonSocialController = TextEditingController();
  final _direccionController = TextEditingController();
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
  bool _isSearchingRuc = false;
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
    _rucController.dispose();
    _razonSocialController.dispose();
    _direccionController.dispose();
    _recibidoController.dispose();
    _opController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE NEGOCIO ---

  Future<void> _buscarRuc() async {
    final ruc = _rucController.text.trim();

    if (ruc.isEmpty) {
      _showNotice("Ingrese un número de RUC", Symbols.keyboard, Colors.orange);
      return;
    }
    if (ruc.length != 11) {
      _showNotice(
          "El RUC debe tener 11 dígitos", Symbols.warning, Colors.orange);
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
        _showNotice(
            "Datos de empresa encontrados", Symbols.check_circle, Colors.green);
      } else {
        _showNotice("No se encontró información del RUC", Symbols.search_off,
            Colors.red);
      }
    } catch (e) {
      _showNotice(
          "Error de conexión al buscar RUC", Symbols.wifi_off, Colors.red);
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

  // --- VALIDACIÓN Y FINALIZACIÓN ---

  Future<void> _validarYFinalizar(double total, CartProvider cart) async {
    final rucText = _rucController.text.trim();

    // 1. VALIDACIONES DE EMPRESA
    if (rucText.isEmpty) {
      _showNotice(
          "Ingrese el RUC de la empresa", Symbols.domain, Colors.orange);
      return;
    }
    if (rucText.length != 11) {
      _showNotice(
          "RUC inválido (Debe ser 11 dígitos)", Symbols.error, Colors.red);
      return;
    }
    if (_razonSocialController.text.trim().isEmpty) {
      _showNotice("Falta la Razón Social", Symbols.business, Colors.orange);
      return;
    }
    if (_direccionController.text.trim().isEmpty) {
      _showNotice(
          "Falta la Dirección Fiscal", Symbols.location_on, Colors.orange);
      return;
    }

    // 2. VALIDACIONES DE PAGO
    String paymentMethod = '';
    String? paymentCode;
    double? cashAmount;

    if (_selectedPayment == 'efectivo') {
      double recibido =
          double.tryParse(_recibidoController.text.replaceAll(',', '.')) ?? 0.0;
      if (recibido < total) {
        _showNotice("Efectivo insuficiente", Symbols.money_off, Colors.red);
        return;
      }
      paymentMethod = 'cash';
      cashAmount = recibido;
    } else if (_selectedPayment == 'yape') {
      if (_opController.text.trim().isEmpty) {
        _showNotice("Falta Nro. de Operación", Symbols.qr_code_2, Colors.blue);
        return;
      }
      paymentMethod = _digitalWallet;
      paymentCode = _opController.text;
    } else {
      if (_referenceController.text.trim().isEmpty) {
        _showNotice(
            "Falta Código de Referencia", Symbols.receipt_long, Colors.blue);
        return;
      }
      paymentMethod = _selectedOtherType;
      paymentCode = _referenceController.text;
    }

    setState(() => _isProcessing = true);

    // 3. ARMADO DEL OBJETO
    final orderData = {
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

    // 4. ENVÍO
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
      _showNotice(
          "Error al procesar la factura", Symbols.cloud_off, Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // --- VISTA PRINCIPAL ---
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CABECERA
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

            // 2. PAGOS
            const Text("Método de Pago",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.extradarkT)),
            const SizedBox(height: 15),

            PaymentMethodsSelector(
                selectedPayment: _selectedPayment,
                onPaymentChanged: (v) => setState(() => _selectedPayment = v)),

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
                onTypeChanged: (v) => setState(() => _selectedOtherType = v),
                refController: _referenceController,
              ),

            const SizedBox(height: 30),

            AmountSummary(total: total),

            const SizedBox(height: 30),

            // 3. FOOTER
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

  void _showNotice(String msg, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      content: Row(children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
            child:
                Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)))
      ]),
    ));
  }

  void _showSuccessDialog(double total, CartProvider cart) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("¡Factura Emitida!", textAlign: TextAlign.center),
        content: const Text("El comprobante se ha generado exitosamente.",
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
                              'id': 'F001-NEW',
                              'type': 'Factura',
                              'amount': total,
                              'date': 'Ahora',
                              'customer_name': _razonSocialController.text,
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
            label: const Text("VER FACTURA"),
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
