import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:anttec_movil/app/core/styles/texts.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isProcessing = false;
  final MobileScannerController cameraController = MobileScannerController();

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() => _isProcessing = true);

        // 🔗 Redirige al detalle del producto
        // Ejemplo: /producto/12345
        context.push('/producto/$code');

        // Pequeño retraso para evitar lecturas múltiples
        Future.delayed(const Duration(seconds: 2), () {
          setState(() => _isProcessing = false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xffD9D9D9),
            borderRadius: BorderRadius.circular(10),
          ),
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 30),
          height: 560,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: _onDetect,
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Text(
          "Apunta la cámara hacia el código de barras para reconocer el producto.",
          textAlign: TextAlign.center,
          style: AppTexts.body2,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: () {
                cameraController.switchCamera();
              },
            ),
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () {
                cameraController.toggleTorch();
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
