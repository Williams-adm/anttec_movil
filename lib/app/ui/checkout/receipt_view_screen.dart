import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/ui/sales_report/widgets/printer_selector_modal.dart';
import 'package:anttec_movil/app/ui/sales_report/screen/pdf_viewer_screen.dart';
import 'package:anttec_movil/data/services/api/v1/printer_service.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
// Ya no necesitamos share_plus si borramos el botón de compartir

class ReceiptViewScreen extends StatelessWidget {
  final Map<String, dynamic> saleData;
  final String pdfPath;

  const ReceiptViewScreen({
    super.key,
    required this.saleData,
    required this.pdfPath,
  });

  void _openPdfDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          path: pdfPath,
          title: "Detalle del Documento",
        ),
      ),
    );
  }

  void _openPrinterSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PrinterSelectorModal(
        onPrinterSelected: (type, address) => _printReceipt(type, address),
      ),
    );
  }

  void _printReceipt(String type, String address) async {
    final printerService = PrinterService();
    try {
      if (type == 'NET') {
        await printerService.printNetwork(address, 9100, saleData);
      } else {
        await printerService.printBluetooth(address, saleData);
      }
    } catch (e) {
      debugPrint("Error de impresión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("Comprobante Digital",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // 1. CORRECCIÓN: Quitamos la X y el botón compartir
        automaticallyImplyLeading:
            false, // Esto evita que salga la flecha o la X automáticamente
        actions: [], // Sin botones a la derecha
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        child: Column(
          children: [
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
                    child: Icon(Symbols.check_circle,
                        color: Colors.green, size: 45),
                  ),
                  const SizedBox(height: 15),
                  const Text("¡Venta Exitosa!",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: Colors.black87)),
                  Text(saleData['date'] ?? '',
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12)),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(
                        indent: 30,
                        endIndent: 30,
                        thickness: 1,
                        color: Color(0xFFEEEEEE)),
                  ),

                  // Información
                  _buildInfoRow("Nro. Documento", saleData['id'] ?? '---'),
                  _buildInfoRow("Tipo", saleData['type'] ?? 'Comprobante'),
                  // Aquí se usa el método corregido para nombres largos
                  _buildInfoRow("Cliente",
                      saleData['customer_name'] ?? 'Público General'),

                  const SizedBox(height: 20),

                  // Lista Items
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Producto",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.black54)),
                            Text("Total",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.black54)),
                          ],
                        ),
                        const Divider(),
                        ...(saleData['items'] as List? ?? [])
                            .map((item) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                            "${item['qty']}x ${item['name']}",
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87)),
                                      ),
                                      Text(
                                          "S/. ${item['total'].toStringAsFixed(2)}",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87)),
                                    ],
                                  ),
                                )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text("TOTAL PAGADO",
                      style: TextStyle(
                          color: Colors.black45,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1)),
                  Text("S/. ${saleData['amount'].toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryP)),

                  const SizedBox(height: 40),

                  // Decoración corte papel
                  Row(
                      children: List.generate(
                          20,
                          (index) => Expanded(
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F2F5),
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                            index.isEven ? 10 : 0)),
                                  ),
                                ),
                              ))),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // BOTONES
            ElevatedButton.icon(
              onPressed: () => _openPdfDetail(context),
              icon: const Icon(Symbols.picture_as_pdf, color: Colors.white),
              label: const Text("VER BOLETA A DETALLE",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 2,
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () => _openPrinterSelector(context),
              icon: const Icon(Symbols.print, color: Colors.white),
              label: const Text("IMPRIMIR COMPROBANTE",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryP,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 2,
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("REGRESAR AL INICIO",
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 2. CORRECCIÓN: Método mejorado para evitar OVERFLOW
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment:
            CrossAxisAlignment.start, // Alinea arriba si hay salto de línea
        children: [
          // Label (izquierda)
          Text(label,
              style: const TextStyle(color: Colors.black54, fontSize: 13)),

          const SizedBox(width: 15), // Espacio vital para que no se peguen

          // Value (derecha) - EXPANDED SOLUCIONA EL OVERFLOW
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right, // Alinea el texto a la derecha
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black87),
              maxLines: 2, // Permite hasta 2 líneas si es muy largo
              overflow:
                  TextOverflow.ellipsis, // Pone "..." si es demasiado largo
            ),
          ),
        ],
      ),
    );
  }
}
