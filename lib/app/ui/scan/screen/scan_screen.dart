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
                // 1. CÁMARA
                Positioned.fill(
                  child: MobileScanner(
                    controller: _controller.cameraController,
                    fit: BoxFit.cover,
                    onDetect: (capture) =>
                        _controller.onDetect(capture, context),
                  ),
                ),

                // 2. OVERLAY (Dibuja el recuadro y las esquinas)
                const Positioned.fill(
                  child: ScanOverlay(),
                ),

                // 3. INTERFAZ UI
                SafeArea(
                  child: Column(
                    children: [
                      // Header (Flash, Cerrar)
                      ScanHeader(controller: _controller),

                      const Spacer(),

                      // Texto Instrucción
                      // Le agregamos un Padding para que no esté pegado a los bordes
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          "Coloque el código adentro del recuadro",
                          textAlign: TextAlign.center,
                          style: ScanStyles.instructionText,
                        ),
                      ),

                      // 🔥 LA CORRECCIÓN ESTÁ AQUÍ:
                      // Aumentamos el height para que el texto suba y no "cubra" las esquinas blancas.
                      // Al poner + 40 en lugar de - 30, alejamos las palabras del recuadro.
                      SizedBox(height: ScanStyles.scanWindowSize.height + 40),

                      const Spacer(),

                      // Footer (Galería, etc)
                      const ScanFooter(),
                    ],
                  ),
                ),

                // 4. LOADER DE PROCESAMIENTO
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
