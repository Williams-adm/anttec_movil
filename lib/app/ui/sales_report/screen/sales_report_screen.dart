import 'dart:developer' as dev;
import 'package:anttec_movil/app/ui/shared/widgets/loader_w.dart';
import 'package:anttec_movil/app/ui/sales_report/viewmodel/sales_report_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  // --- PALETA DE COLORES ---
  final Color _purpleColor =
      const Color(0xFF6C3082); // Color principal (Boletas)
  final Color _blueColor =
      const Color(0xFF1976D2); // Color secundario (Facturas)
  final Color _backgroundColor = const Color(0xFFF8F0FB);
  final Color _paidColor = const Color(0xFF00C853);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesReportViewmodel>().loadSales();
    });
  }

  // Helper para calcular total
  double _calculateTotal(List<Map<String, dynamic>> sales) {
    return sales.fold(0.0, (sum, item) => sum + (item['amount'] as double));
  }

  // Helper simulado: Cantidad de productos
  int _getProductCount(int index) {
    if (index % 4 == 0) {
      return 12;
    }
    if (index % 3 == 0) {
      return 3;
    }
    return 2;
  }

  // Helper simulado: Método de pago
  Map<String, dynamic> _getPaymentMethod(int index) {
    if (index % 3 == 0) {
      return {'icon': Symbols.account_balance_wallet, 'name': 'Yape'};
    }
    if (index % 2 == 0) {
      return {'icon': Symbols.credit_card, 'name': 'Transferencia'};
    }
    return {'icon': Symbols.payments, 'name': 'Efectivo'};
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SalesReportViewmodel>();
    final totalSales = _calculateTotal(vm.sales);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Historial de Ventas",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            onPressed: () {
              dev.log("Filtrar por fecha");
            },
            icon: Icon(Symbols.calendar_month, color: _purpleColor),
          ),
        ],
      ),
      body: LoaderW(
        isLoading: vm.isLoading,
        child: Column(
          children: [
            // 1. TARJETA DE TOTALES (Recuperada y estilizada)
            _buildTotalCard(totalSales, vm.sales.length),

            const SizedBox(height: 10),

            // 2. LISTA DE VENTAS
            Expanded(
              child: vm.sales.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                      itemCount: vm.sales.length,
                      itemBuilder: (context, index) {
                        final sale = vm.sales[index];
                        final productCount = _getProductCount(index);
                        final paymentMethod = _getPaymentMethod(index);
                        return _buildSaleCard(
                            sale, productCount, paymentMethod);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  // ✅ TARJETA DE TOTALES (Agregada nuevamente)
  Widget _buildTotalCard(double total, int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _purpleColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ventas del Día",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "S/. ${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _purpleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  "$count",
                  style: TextStyle(
                    color: _purpleColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  "Docs",
                  style: TextStyle(
                    color: _purpleColor,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSaleCard(Map<String, dynamic> sale, int productCount,
      Map<String, dynamic> paymentMethod) {
    // ✅ LÓGICA DE COLORES: Factura (Azul) vs Boleta (Morado)
    final isFactura = sale['type'] == 'Factura';
    final themeColor = isFactura ? _blueColor : _purpleColor;
    final icon = isFactura ? Symbols.domain : Symbols.receipt_long;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- HEADER ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono con color dinámico
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: themeColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale['type'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sale['id'],
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  sale['date'],
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),

            // --- CONTENIDO ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cantidad
                    Row(
                      children: [
                        Icon(Symbols.shopping_bag,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          "$productCount Productos",
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Método Pago
                    Row(
                      children: [
                        Icon(paymentMethod['icon'],
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          paymentMethod['name'],
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                // Total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "S/. ${sale['amount'].toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- FOOTER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Badge PAGADO
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _paidColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: _paidColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "PAGADO",
                        style: TextStyle(
                          color: _paidColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón Imprimir (Color dinámico según Factura/Boleta)
                OutlinedButton.icon(
                  onPressed: () {
                    dev.log("🖨️ Imprimir: ${sale['id']}");
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: themeColor, // Texto morado o azul
                    side: BorderSide(color: themeColor), // Borde morado o azul
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  icon: const Icon(Symbols.print, size: 20),
                  label: const Text(
                    "Imprimir",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.receipt_long, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No hay ventas registradas",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
