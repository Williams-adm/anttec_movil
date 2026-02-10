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

  /// Abre el visor de PDF
  void _openPdfDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          path: pdfPath,
          title: saleData['id'] ?? "Comprobante",
          pdfBytes: pdfBytes,
          // ❌ SE ELIMINÓ 'saleData' PORQUE YA NO ES NECESARIO PARA IMPRIMIR EL PDF
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bloqueamos el botón físico atrás para obligar a usar "REGRESAR AL INICIO"
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Limpiamos carrito y redirigimos al home de forma segura
        context.read<CartProvider>().clearCart();
        context.go('/home');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FA),
        appBar: AppBar(
          title: const Text("Comprobante Digital",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            children: [
              // --- CARD DE TICKET VISUAL ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 35),

                    // Icono de Éxito Centrado
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                      child: const Icon(Symbols.check_circle,
                          color: Colors.green, size: 50, fill: 1),
                    ),

                    const SizedBox(height: 20),

                    const Text("¡Venta Exitosa!",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87)),

                    const SizedBox(height: 8),

                    const Text("El comprobante ha sido generado",
                        style: TextStyle(color: Colors.black45, fontSize: 14)),

                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 25, horizontal: 40),
                      child: Divider(color: Color(0xFFF0F0F0), thickness: 1.5),
                    ),

                    // --- DETALLES DINÁMICOS CENTRADOS ---
                    _buildCenteredInfo(
                        "NRO. DOCUMENTO", saleData['id'] ?? '---'),
                    const SizedBox(height: 20),
                    _buildCenteredInfo("CLIENTE",
                        saleData['customer_name'] ?? 'Público General'),

                    const SizedBox(height: 30),

                    // --- SECCIÓN TOTAL (DESTACADA) ---
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          const Text("TOTAL PAGADO",
                              style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2)),
                          const SizedBox(height: 5),
                          Text(
                              "S/. ${(saleData['amount'] as double).toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryP)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Adorno visual de corte de papel
                    _buildTicketCutter(),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- BOTONES DE ACCIÓN ---
              ElevatedButton.icon(
                onPressed: () => _openPdfDetail(context),
                icon: const Icon(Symbols.picture_as_pdf, color: Colors.white),
                label: const Text("VER BOLETA A DETALLE"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 58),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18))),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  context.read<CartProvider>().clearCart();
                  context.go('/home');
                },
                child: const Text("REGRESAR AL INICIO",
                    style: TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper para construir bloques de información centrados
  Widget _buildCenteredInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black38,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  /// Efecto visual dentado para el final del ticket
  Widget _buildTicketCutter() {
    return Row(
        children: List.generate(
            15,
            (index) => Expanded(
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 12,
                    decoration: const BoxDecoration(
                        color: Color(0xFFF4F7FA), // Combina con el fondo
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10)))))));
  }
}
