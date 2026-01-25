import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:anttec_movil/data/services/api/v1/api_service.dart';
import 'package:anttec_movil/data/services/api/v1/scaner_service.dart';

class ScanController extends ChangeNotifier {
  // Estado
  bool isProcessing = false;

  // Controladores y Servicios
  final MobileScannerController cameraController = MobileScannerController();
  late final ScannerService _scannerService;

  ScanController() {
    _scannerService = ScannerService(apiService: ApiService());
  }

  // Lógica principal de detección
  void onDetect(BarcodeCapture capture, BuildContext context) {
    if (isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        _processBarcode(code, context);
      }
    }
  }

  Future<void> _processBarcode(String barcode, BuildContext context) async {
    isProcessing = true;
    notifyListeners(); // Actualiza la UI para mostrar cargando

    try {
      // 1. Consulta al servicio
      final productData = await _scannerService.getVariantByBarcode(barcode);

      if (context.mounted) {
        // 2. Navegación exitosa
        context.push('/producto/$barcode', extra: productData);
      }
    } catch (e) {
      if (context.mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        _showError(context, message);
      }
    } finally {
      // Pequeña pausa para UX
      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        isProcessing = false;
        notifyListeners(); // Actualiza la UI para ocultar cargando
      }
    }
  }

  // Acciones de la cámara
  void switchCamera() => cameraController.switchCamera();
  void toggleTorch() => cameraController.toggleTorch();

  // Helpers de UI
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
