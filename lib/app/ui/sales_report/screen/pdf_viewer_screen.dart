import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:material_symbols_icons/symbols.dart';

// IMPORTS PROPIOS
import 'package:anttec_movil/app/ui/sales_report/widgets/printer_selector_modal.dart';
import 'package:anttec_movil/data/services/api/v1/printer_service.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';

class PdfViewerScreen extends StatefulWidget {
  final String path; // URL del PDF (https://...)
  final String title;

  const PdfViewerScreen({super.key, required this.path, required this.title});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  // Usamos una UniqueKey para forzar la recarga del widget
  Key _viewerKey = UniqueKey();

  // Lógica de Impresión
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

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Enviando comando de impresión..."),
      duration: Duration(seconds: 1),
    ));

    try {
      if (type == 'NET') {
        await printerService.printNetwork(address, 9100, data);
      } else {
        await printerService.printBluetooth(address, data);
      }
    } catch (e) {
      debugPrint("Error al imprimir: $e");
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
          // BOTÓN RECARGAR (CORREGIDO)
          IconButton(
            icon: const Icon(Symbols.refresh),
            onPressed: () {
              setState(() {
                // Al cambiar la key, Flutter reconstruye el widget desde cero
                _viewerKey = UniqueKey();
              });
            },
          ),
          IconButton(
            icon: const Icon(Symbols.print, color: AppColors.primaryP),
            onPressed: () => _abrirSelectorImpresora(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      // CARGA EL PDF DESDE LA URL
      body: SfPdfViewer.network(
        widget.path,
        key: _viewerKey, // Asignamos la key dinámica aquí
        canShowScrollHead: false,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Error al cargar PDF: ${details.description}")),
          );
        },
      ),
    );
  }
}
