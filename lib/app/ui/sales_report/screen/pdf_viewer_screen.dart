import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:material_symbols_icons/symbols.dart';

// IMPORTS PROPIOS
import 'package:anttec_movil/app/ui/sales_report/widgets/printer_selector_modal.dart';
import 'package:anttec_movil/data/services/api/v1/printer_service.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';

class PdfViewerScreen extends StatefulWidget {
  final String path;
  final String title;
  final Uint8List? pdfBytes;
  final Map<String, dynamic>? saleData; // ✅ Agregado para impresión real

  const PdfViewerScreen({
    super.key,
    required this.path,
    required this.title,
    this.pdfBytes,
    this.saleData, // ✅ Recibe la data de la venta
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  Key _viewerKey = UniqueKey();

  void _abrirSelectorImpresora(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PrinterSelectorModal(
        onPrinterSelected: (type, address) =>
            _imprimirPdfTermico(type, address),
      ),
    );
  }

  void _imprimirPdfTermico(String type, String address) async {
    final PrinterService printerService = PrinterService();

    // ✅ DATA REAL: Si no hay saleData (reimpresión vieja), usa un fallback
    final Map<String, dynamic> data = widget.saleData ??
        {
          'type': 'Reimpresión',
          'id': widget.title,
          'amount': 0.0,
          'customer_name': 'Cliente',
          'items': [],
        };

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enviando a impresora...")),
    );

    try {
      if (type == 'NET') {
        await printerService.printNetwork(address, 9100, data);
      } else {
        await printerService.printBluetooth(address, data);
      }
    } catch (e) {
      debugPrint("❌ Error al imprimir: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Symbols.refresh),
            onPressed: () => setState(() => _viewerKey = UniqueKey()),
          ),
          IconButton(
            icon: const Icon(Symbols.print, color: AppColors.primaryP),
            onPressed: () => _abrirSelectorImpresora(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _buildPdfContent(),
    );
  }

  Widget _buildPdfContent() {
    if (widget.pdfBytes != null) {
      return SfPdfViewer.memory(widget.pdfBytes!, key: _viewerKey);
    }
    if (widget.path.startsWith('http')) {
      return SfPdfViewer.network(widget.path, key: _viewerKey);
    }
    return SfPdfViewer.file(File(widget.path), key: _viewerKey);
  }
}
