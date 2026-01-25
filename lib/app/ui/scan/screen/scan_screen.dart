import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart'; // ✅ Necesario para la navegación

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
    // 🔥 SOLUCIÓN AQUÍ: PopScope intercepta el botón físico "Atrás"
    return PopScope(
      canPop: false, // 1. Le decimos al sistema: "No cierres la app todavía"
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // Si ya se gestionó, no hacemos nada.

        // 2. Ejecutamos nuestra lógica manual
        if (context.canPop()) {
          context.pop(); // Si hay historial, vuelve atrás normal.
        } else {
          context.goNamed('home'); // Si no hay historial, ¡fuerza ir al Home!
        }
      },
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: ScanStyles.backgroundColor,
            body: Stack(
              children: [
                // 1. CÁMARA
                Positioned.fill(
                  child: MobileScanner(
                    controller: _controller.cameraController,
                    fit: BoxFit.cover,
                    onDetect: (capture) =>
                        _controller.onDetect(capture, context),
                  ),
                ),

                // 2. OVERLAY
                const Positioned.fill(
                  child: ScanOverlay(),
                ),

                // 3. INTERFAZ UI
                SafeArea(
                  child: Column(
                    children: [
                      // Header
                      ScanHeader(controller: _controller),

                      const Spacer(),

                      // Texto Instrucción
                      const Text(
                        "Coloque el código adentro del recuadro",
                        style: ScanStyles.instructionText,
                      ),

                      SizedBox(height: ScanStyles.scanWindowSize.height - 30),

                      const Spacer(),

                      // Footer
                      const ScanFooter(),
                    ],
                  ),
                ),

                // 4. LOADER
                if (_controller.isProcessing)
                  Container(
                    color: ScanStyles.loaderBackgroundColor,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: ScanStyles.white),
                          SizedBox(height: 15),
                          Text("Procesando...", style: ScanStyles.loadingText),
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
