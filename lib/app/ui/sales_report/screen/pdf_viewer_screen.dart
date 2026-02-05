import 'package:anttec_movil/app/ui/sales_report/widgets/printer_selector_modal.dart';
import 'package:anttec_movil/data/services/api/v1/printer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:material_symbols_icons/symbols.dart';

class PdfViewerScreen extends StatelessWidget {
  final String path;
  final String title;

  const PdfViewerScreen({super.key, required this.path, required this.title});

  // Función para abrir el modal que ya tienes creado
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

  // Lógica para enviar a imprimir usando tu PrinterService
  void _imprimirPdfTermico(String type, String address) async {
    final PrinterService printerService = PrinterService();

    // Nota: Aquí deberías tener una lógica en tu PrinterService
    // para convertir el PDF a imagen/bytes para ticketera térmica.
    // Por ahora, enviamos un mapa genérico como ejemplo de lo que ya haces:
    final Map<String, dynamic> data = {
      'type': 'Reimpresión',
      'id': title,
      'amount': 0.0, // Estos datos deberían venir de la venta real
      'items': [],
    };

    try {
      if (type == 'NET') {
        await printerService.printNetwork(address, 9100, data);
      } else {
        await printerService.printBluetooth(address, data);
      }
    } catch (e) {
      debugPrint("Error al imprimir desde PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        backgroundColor: AppColors.background,
        centerTitle: true,
        elevation: 0,
        actions: [
          // BOTÓN DE IMPRESIÓN AÑADIDO
          IconButton(
            icon: const Icon(Symbols.print, size: 28),
            tooltip: "Imprimir en ticketera",
            onPressed: () => _abrirSelectorImpresora(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PDFView(
        filePath: path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}
