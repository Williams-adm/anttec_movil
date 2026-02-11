import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

// Imports de estilos y lógica
import 'package:anttec_movil/app/ui/scan/styles/scan_styles.dart';
import 'package:anttec_movil/app/ui/scan/controllers/scan_controller.dart';

// Imports de tus widgets
import '../widgets/scan_overlay.dart';
import '../widgets/scan_header.dart';
import '../widgets/scan_footer.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ScanController _controller = ScanController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed('home');
        }
      },
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: ScanStyles.backgroundColor,
            body: Stack(
              children: [
                // 1. CÁMARA (Fondo total)
                Positioned.fill(
                  child: MobileScanner(
                    controller: _controller.cameraController,
                    fit: BoxFit.cover,
                    onDetect: (capture) =>
                        _controller.onDetect(capture, context),
                  ),
                ),

                // 2. OVERLAY (Dibuja el recuadro y las esquinas blancas)
                const Positioned.fill(
                  child: ScanOverlay(),
                ),

                // 3. INTERFAZ DE USUARIO (Capas superiores)
                SafeArea(
                  child: Stack(
                    children: [
                      // Header: Flash y Botón Cerrar (Arriba)
                      Align(
                        alignment: Alignment.topCenter,
                        child: ScanHeader(controller: _controller),
                      ),

                      // 🔥 SOLUCIÓN AL TEXTO:
                      // Lo centramos en la pantalla y le damos un "bottom padding"
                      // igual a la mitad del recuadro + un margen extra.
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: ScanStyles.scanWindowSize.height + 60,
                            left: 30,
                            right: 30,
                          ),
                          child: const Text(
                            "Coloque el código adentro del recuadro",
                            textAlign: TextAlign.center,
                            style: ScanStyles.instructionText,
                          ),
                        ),
                      ),

                      // Footer: Texto "Escanear" (Abajo)
                      const Align(
                        alignment: Alignment.bottomCenter,
                        child: ScanFooter(),
                      ),
                    ],
                  ),
                ),

                // 4. LOADER DE PROCESAMIENTO (Capa frontal bloqueante)
                if (_controller.isProcessing)
                  Container(
                    color: ScanStyles.loaderBackgroundColor,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: ScanStyles.white,
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Procesando producto...",
                            style: ScanStyles.loadingText,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
