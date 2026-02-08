import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

// --- IMPORTS PROPIOS ---
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/ui/sales_report/screen/pdf_viewer_screen.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';

class ReceiptViewScreen extends StatelessWidget {
  final Map<String, dynamic> saleData;
  final String pdfPath;
  final Uint8List? pdfBytes;

  const ReceiptViewScreen({
    super.key,
    required this.saleData,
    required this.pdfPath,
    this.pdfBytes,
  });

  void _openPdfDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          path: pdfPath,
          title: "Detalle del Documento",
          pdfBytes: pdfBytes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // PopScope bloquea el botón físico "atrás" para que no vuelvan al formulario
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Al intentar dar atrás, limpiamos carrito y vamos a Home
        context.read<CartProvider>().clearCart();
        context.go('/home');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: AppBar(
          title: const Text(
            "Comprobante Digital",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false, // Quitamos flecha de atrás
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            children: [
              // --- TICKET VISUAL ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(
                        Symbols.check_circle,
                        color: Colors.green,
                        size: 45,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "¡Venta Exitosa!",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- FILAS DE INFORMACIÓN (CON FIX DE OVERFLOW) ---
                    _buildInfoRow("Nro. Documento", saleData['id'] ?? '---'),
                    _buildInfoRow("Tipo", saleData['type'] ?? 'Comprobante'),
                    _buildInfoRow(
                      "Cliente",
                      saleData['customer_name'] ?? 'Público General',
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "TOTAL PAGADO",
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      "S/. ${(saleData['amount'] as double).toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryP,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Botón principal
              ElevatedButton.icon(
                onPressed: () => _openPdfDetail(context),
                icon: const Icon(Symbols.picture_as_pdf, color: Colors.white),
                label: const Text("VER BOLETA A DETALLE"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botón salir
              TextButton(
                onPressed: () {
                  context.read<CartProvider>().clearCart();
                  context.go('/home');
                },
                child: const Text(
                  "REGRESAR AL INICIO",
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ MÉTODO BLINDADO CONTRA TEXTOS LARGOS
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(width: 20),
          Expanded(
            // <--- Esto hace que el texto use el espacio sobrante y salte de línea
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
