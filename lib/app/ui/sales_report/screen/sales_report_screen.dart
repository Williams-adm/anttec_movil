import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

// IMPORTS PROPIOS
import 'package:anttec_movil/data/services/api/v1/printer_service.dart';
import 'package:anttec_movil/app/ui/sales_report/widgets/printer_selector_modal.dart';
import 'package:anttec_movil/app/ui/shared/widgets/loader_w.dart';
import 'package:anttec_movil/app/ui/sales_report/viewmodel/sales_report_viewmodel.dart';
import 'package:anttec_movil/app/ui/sales_report/screen/pdf_viewer_screen.dart'; // IMPORTA TU VISOR

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final Color _purpleColor = const Color(0xFF6C3082);
  final Color _blueColor = const Color(0xFF1976D2);
  final Color _backgroundColor = const Color(0xFFF8F0FB);
  final Color _paidColor = const Color(0xFF00C853);

  final PrinterService _printerService = PrinterService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesReportViewmodel>().loadSales(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final vm = context.read<SalesReportViewmodel>();
      if (!vm.isLoading) {
        vm.loadSales();
      }
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  // --- NUEVA LÓGICA: NAVEGAR AL VISOR INTERNO ---
  void _handleViewPdf(String? url, String orderNumber) {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No hay PDF disponible"),
          backgroundColor: Colors.orange));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          path: url,
          title: "Comprobante $orderNumber",
        ),
      ),
    );
  }

  // --- LÓGICA IMPRESIÓN (SIN ERROR DE POP) ---
  void _handlePrintRequest(int index) async {
    // 1. Mostrar Loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final vm = context.read<SalesReportViewmodel>();
    // 2. Obtener datos
    final saleWithItems = await vm.fetchSaleDetailsForPrint(index);

    if (!mounted) return;

    // 3. CERRAR DIÁLOGO CORRECTAMENTE (Usando rootNavigator)
    Navigator.of(context, rootNavigator: true).pop();

    if (saleWithItems != null) {
      _openPrinterModal(saleWithItems);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Error al obtener datos de impresión"),
            backgroundColor: Colors.red),
      );
    }
  }

  void _openPrinterModal(Map<String, dynamic> sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PrinterSelectorModal(
        onPrinterSelected: (type, address) =>
            _executePrint(type, address, sale),
      ),
    );
  }

  void _executePrint(
      String type, String address, Map<String, dynamic> sale) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Imprimiendo ${sale['order_number']}..."),
      backgroundColor: Colors.black87,
    ));
    try {
      if (type == 'NET') {
        await _printerService.printNetwork(address, 9100, sale);
      } else {
        await _printerService.printBluetooth(address, sale);
      }
    } catch (e) {
      dev.log("Error impresión: $e");
    }
  }

  // --- UI ---
  void _showDatePicker() async {
    final vm = context.read<SalesReportViewmodel>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.selectedDate ?? now,
      firstDate: DateTime(2023),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: _purpleColor,
            colorScheme: ColorScheme.light(primary: _purpleColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      vm.setDateFilter(picked);
    }
  }

  IconData _getPaymentIcon(String? method) {
    switch (method?.toLowerCase()) {
      case 'yape':
        return Symbols.qr_code;
      case 'plin':
        return Symbols.smartphone;
      case 'card':
        return Symbols.credit_card;
      default:
        return Symbols.payments;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SalesReportViewmodel>();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("Historial de Ventas",
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            onPressed: _showDatePicker,
            icon: Icon(
              vm.selectedDate != null
                  ? Symbols.filter_alt_off
                  : Symbols.calendar_month,
              color: vm.selectedDate != null ? Colors.red : _purpleColor,
            ),
          ),
        ],
      ),
      body: LoaderW(
        isLoading: vm.isLoading && vm.sales.isEmpty,
        child: Column(
          children: [
            if (vm.selectedDate != null)
              Container(
                width: double.infinity,
                color: _purpleColor.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    "Filtro: ${DateFormat('dd/MM/yyyy').format(vm.selectedDate!)}",
                    style: TextStyle(
                        color: _purpleColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            _buildTotalCard(vm.totalSalesAmount, vm.totalDocs),
            const SizedBox(height: 10),
            Expanded(
              child: vm.sales.isEmpty && !vm.isLoading
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async => vm.loadSales(refresh: true),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                        itemCount: vm.sales.length + (vm.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == vm.sales.length) {
                            return const Center(
                                child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ));
                          }
                          return _buildSaleCard(vm.sales[index], index);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(double total, int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _purpleColor.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Recaudado",
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              Text("S/. ${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _purpleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text("$count",
                    style: TextStyle(
                        color: _purpleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
                Text("Ventas",
                    style: TextStyle(color: _purpleColor, fontSize: 10)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSaleCard(Map<String, dynamic> sale, int index) {
    final isFactura = sale['type_voucher'] == 'factura';
    final themeColor = isFactura ? _blueColor : _purpleColor;
    final icon = isFactura ? Symbols.domain : Symbols.receipt_long;
    final String paymentMethod = sale['method_payment'] ?? 'cash';
    final double amount = double.tryParse(sale['total'].toString()) ?? 0.0;
    final String? pdfUrl = sale['voucher'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: themeColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          isFactura ? "FACTURA ELECTRÓNICA" : "BOLETA DE VENTA",
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(sale['order_number'] ?? '---',
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(sale['time'] ?? '',
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                    Text(sale['date'] ?? '',
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 10)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_getPaymentIcon(paymentMethod),
                        size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(paymentMethod.toUpperCase(),
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _paidColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("EXITOSO",
                      style: TextStyle(
                          color: _paidColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: Text("S/. ${amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
            const SizedBox(height: 16),

            // --- BOTONES ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    // LÓGICA DE VISOR INTERNO
                    onPressed: () =>
                        _handleViewPdf(pdfUrl, sale['order_number'] ?? 'Doc'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Symbols.visibility, size: 18),
                    label: const Text("Ver PDF"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    // LÓGICA DE IMPRESIÓN (USA ID de ORDEN)
                    onPressed: () => _handlePrintRequest(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    icon: const Icon(Symbols.print, size: 18),
                    label: const Text("Imprimir"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.receipt_long, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text("No hay ventas registradas",
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
