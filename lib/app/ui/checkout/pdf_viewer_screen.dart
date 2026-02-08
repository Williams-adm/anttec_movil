import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:material_symbols_icons/symbols.dart';

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
  Key _viewerKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Symbols.refresh),
            onPressed: () => setState(() => _viewerKey = UniqueKey()),
          ),
        ],
      ),
      // --- CARGA DESDE MEMORIA O DISCO ---
      body: widget.pdfBytes != null
          ? SfPdfViewer.memory(widget.pdfBytes!, key: _viewerKey)
          : SfPdfViewer.file(File(widget.path), key: _viewerKey),
    );
  }
}
