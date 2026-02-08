import 'dart:io';
import 'dart:typed_data'; // ✅ Necesario para Uint8List
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:material_symbols_icons/symbols.dart';

// IMPORTS PROPIOS
import 'package:anttec_movil/app/ui/sales_report/widgets/printer_selector_modal.dart';
import 'package:anttec_movil/data/services/api/v1/printer_service.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';

class PdfViewerScreen extends StatefulWidget {
  final String path; // Puede ser URL (https://) o Ruta Local (/data/user/...)
  final String title;
  final Uint8List? pdfBytes; // ✅ AGREGADO: Datos binarios del PDF

  const PdfViewerScreen({
    super.key,
    required this.path,
    required this.title,
    this.pdfBytes, // ✅ Definido en el constructor
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  // Key dinámica para forzar la reconstrucción del visor si algo cambia
  Key _viewerKey = UniqueKey();

  // Lógica de Impresión Térmica
  void _abrirSelectorImpresora(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PrinterSelectorModal(
          onPrinterSelected: (type, address) {
            _imprimirPdfTermico(type, address);
          },
        );
      },
    );
  }

  void _imprimirPdfTermico(String type, String address) async {
    final PrinterService printerService = PrinterService();
    final Map<String, dynamic> data = {
      'type': 'Reimpresión',
      'id': widget.title,
      'amount': 0.0,
      'items': [],
    };

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Enviando comando de impresión..."),
        duration: Duration(seconds: 1),
      ),
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
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // Botón para recargar el documento
          IconButton(
            icon: const Icon(Symbols.refresh),
            onPressed: () {
              setState(() {
                _viewerKey = UniqueKey();
              });
            },
          ),
          // Botón para abrir modal de impresión
          IconButton(
            icon: const Icon(Symbols.print, color: AppColors.primaryP),
            onPressed: () => _abrirSelectorImpresora(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      // --- LÓGICA DE CARGA DINÁMICA ---
      body: _buildPdfContent(),
    );
  }

  /// Decide qué motor de carga usar según los datos disponibles
  Widget _buildPdfContent() {
    // 1. Prioridad Máxima: Carga desde la memoria RAM (Uint8List)
    if (widget.pdfBytes != null) {
      return SfPdfViewer.memory(
        widget.pdfBytes!,
        key: _viewerKey,
        onDocumentLoadFailed: (details) => _handleError(details.description),
      );
    }

    // 2. Si es una URL de internet (REPORTES)
    if (widget.path.startsWith('http')) {
      return SfPdfViewer.network(
        widget.path,
        key: _viewerKey,
        onDocumentLoadFailed: (details) => _handleError(details.description),
      );
    }

    // 3. Si es una ruta de archivo local (BOLETAS guardadas en disco)
    return SfPdfViewer.file(
      File(widget.path),
      key: _viewerKey,
      onDocumentLoadFailed: (details) => _handleError(details.description),
    );
  }

  void _handleError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Error al cargar PDF: $message")));
  }
}
