import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:anttec_movil/app/core/styles/texts.dart';

// ✅ Importaciones de tus servicios
import 'package:anttec_movil/data/services/api/v1/api_service.dart';
// Asegúrate de que esta ruta coincida con donde guardaste el archivo de arriba
import 'package:anttec_movil/data/services/api/v1/scaner_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isProcessing = false;
  final MobileScannerController cameraController = MobileScannerController();

  late final ScannerService _scannerService;

  @override
  void initState() {
    super.initState();
    // 💉 Inyección de dependencias manual:
    // Creamos el ApiService y se lo pasamos al ScannerService.
    _scannerService = ScannerService(apiService: ApiService());
  }

  Future<void> _processBarcode(String barcode) async {
    setState(() => _isProcessing = true);

    try {
      // 1. Consulta limpia al servicio
      final productData = await _scannerService.getVariantByBarcode(barcode);

      if (mounted) {
        // 2. Navegación enviando la DATA completa (ahorras una petición en la sig. pantalla)
        context.push('/producto/$barcode', extra: productData);
      }
    } catch (e) {
      // Limpieza del mensaje de error para la UI
      final message = e.toString().replaceAll('Exception: ', '');
      _showError(message);
    } finally {
      // Pequeña pausa para UX
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        _processBarcode(code);
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
                // Overlay de carga
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 10),
                          Text(
                            "Consultando...",
                            style: AppTexts.body2.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
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
              onPressed: () => cameraController.switchCamera(),
            ),
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => cameraController.toggleTorch(),
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
