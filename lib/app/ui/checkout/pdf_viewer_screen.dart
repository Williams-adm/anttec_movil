import 'package:anttec_movil/app/ui/sales_report/widgets/printer_selector_modal.dart';
import 'package:anttec_movil/data/services/api/v1/printer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'dart:ui'; // Para el efecto de desenfoque (Blur)

class PdfViewerScreen extends StatefulWidget {
  final String path;
  final String title;

  const PdfViewerScreen({super.key, required this.path, required this.title});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;

  void _abrirSelectorImpresora(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PrinterSelectorModal(
        onPrinterSelected: (type, address) =>
            _ejecutarImpresionTermica(type, address),
      ),
    );
  }

  void _ejecutarImpresionTermica(String type, String address) async {
    final PrinterService printerService = PrinterService();
    final Map<String, dynamic> data = {
      'type': 'Reimpresión',
      'id': widget.title,
      'amount': 0.0,
      'items': [],
      'date': DateTime.now().toString().substring(0, 16),
    };

    try {
      if (type == 'NET') {
        await printerService.printNetwork(address, 9100, data);
      } else {
        await printerService.printBluetooth(address, data);
      }
    } catch (e) {
      debugPrint("Error de impresión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Gris neutro tipo Apple
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.black87)),
            if (_isReady)
              Text("Página ${_currentPage + 1} de $_totalPages",
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_ios_new,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Capa 1: El PDF (Fondo)
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            backgroundColor: const Color(0xFFF5F5F7),
            onRender: (pages) => setState(() {
              _totalPages = pages!;
              _isReady = true;
            }),
            onPageChanged: (page, total) =>
                setState(() => _currentPage = page!),
          ),

          // Capa 2: Gradiente inferior para legibilidad
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Capa 3: El Botón Flotante Estilizado
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: SafeArea(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter:
                      ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Efecto cristal
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryP.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryP.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _abrirSelectorImpresora(context),
                        child: Container(
                          height: 65,
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Symbols.print_connect,
                                  color: Colors.white, size: 28),
                              const SizedBox(width: 15),
                              const Text(
                                "IMPRIMIR COMPROBANTE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
