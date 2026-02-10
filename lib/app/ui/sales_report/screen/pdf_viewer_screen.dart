import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';

// LIBRERÍAS PARA DESCARGA TEMPORAL (NECESARIAS PARA IMPRIMIR URLS)
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

// IMPORTS PROPIOS
import 'package:anttec_movil/app/ui/sales_report/widgets/printer_selector_modal.dart';
import 'package:anttec_movil/data/services/api/v1/printer_service.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';

class PdfViewerScreen extends StatefulWidget {
  final String path;
  final String title;
  final Uint8List? pdfBytes;

  const PdfViewerScreen({
    super.key,
    required this.path,
    required this.title,
    this.pdfBytes,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PrinterService _printerService = PrinterService();
  Key _viewerKey = UniqueKey();
  bool _isDownloading = false;

  // =========================================================
  // LÓGICA DE IMPRESIÓN (CON DESCARGA AUTOMÁTICA)
  // =========================================================

  void _abrirSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PrinterSelectorModal(
        onPrinterSelected: (type, address) {
          Navigator.pop(context); // Cerrar modal
          _procesarImpresion(type, address);
        },
      ),
    );
  }

  void _procesarImpresion(String type, String address) async {
    // 1. Mostrar feedback inicial
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("📄 Preparando documento..."),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black87,
      ),
    );

    try {
      String localPath = widget.path;

      // 2. SI ES UNA URL (INTERNET), PRIMERO LA DESCARGAMOS
      // La ticketera necesita un archivo físico para convertirlo a imagen.
      if (widget.path.startsWith('http')) {
        setState(() => _isDownloading = true);
        localPath = await _downloadPdfToTemp(widget.path);
        setState(() => _isDownloading = false);
      }

      if (type == 'STANDARD') {
        // === OPCIÓN 1: IMPRESORA A4 (HP, EPSON, SISTEMA ANDROID) ===
        await _printerService.printStandard(localPath);
      } else {
        // === OPCIÓN 2: TICKETERA TÉRMICA (80mm) ===
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⏳ Procesando imagen para ticketera..."),
            duration: Duration(seconds: 4),
            backgroundColor: Colors.blueGrey,
          ),
        );

        bool isBt = (type == 'BT');
        // Enviamos el path local (ya descargado)
        await _printerService.printTicketera(address, localPath, isBt);

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Ticket enviado correctamente"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isDownloading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _mostrarErrorDetallado(e.toString());
      }
    }
  }

  /// Descarga un PDF de internet a una carpeta temporal del celular
  Future<String> _downloadPdfToTemp(String url) async {
    final dir = await getTemporaryDirectory();
    final fileName = "temp_print_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final savePath = "${dir.path}/$fileName";

    await Dio().download(url, savePath);
    return savePath;
  }

  void _mostrarErrorDetallado(String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Text("Error"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("No se pudo imprimir. Detalle técnico:"),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Text(
                  error,
                  style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.redAccent),
                ),
              ),
              const SizedBox(height: 10),
              const Text("Sugerencias:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Text("• Verifica que la IP sea correcta (Self Test)."),
              const Text("• Apaga los Datos Móviles si usas WiFi Local."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cerrar"),
          )
        ],
      ),
    );
  }

  // =========================================================
  // INTERFAZ Y COMPARTIR
  // =========================================================

  void _compartir() async {
    if (widget.path.isNotEmpty) {
      // Si es URL, compartimos el enlace
      if (widget.path.startsWith('http')) {
        await Share.share("Aquí tienes tu comprobante: ${widget.path}",
            subject: widget.title);
      }
      // Si es archivo local, compartimos el archivo
      else if (File(widget.path).existsSync()) {
        await Share.shareXFiles([XFile(widget.path)], text: widget.title);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Archivo no disponible para compartir")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        actions: [
          IconButton(
            tooltip: "Recargar",
            icon: const Icon(Symbols.refresh),
            onPressed: () => setState(() => _viewerKey = UniqueKey()),
          ),
          IconButton(
            tooltip: "Compartir",
            icon: const Icon(Symbols.share),
            onPressed: _compartir,
          ),
          IconButton(
            tooltip: "Imprimir",
            icon: const Icon(Symbols.print, color: AppColors.primaryP),
            onPressed: _isDownloading ? null : _abrirSelector,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          _buildPdfContent(),
          if (_isDownloading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 10),
                    Text("Descargando PDF...",
                        style: TextStyle(color: Colors.white))
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildPdfContent() {
    // 1. Si viene en memoria (Bytes directos)
    if (widget.pdfBytes != null) {
      return SfPdfViewer.memory(widget.pdfBytes!, key: _viewerKey);
    }

    // 2. Si es una URL de Internet (http/https) - ¡CORRECCIÓN CRÍTICA!
    if (widget.path.startsWith('http')) {
      return SfPdfViewer.network(
        widget.path,
        key: _viewerKey,
        canShowScrollHead: false,
        canShowScrollStatus: false,
      );
    }

    // 3. Si es un archivo local en el celular
    return SfPdfViewer.file(File(widget.path), key: _viewerKey);
  }
}
