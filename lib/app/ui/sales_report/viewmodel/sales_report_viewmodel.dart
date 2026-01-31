import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class SalesReportViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _sales = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get sales => _sales;
  String? get errorMessage => _errorMessage;

  // Carga las ventas (Simulado, aquí conectarías con tu Repository)
  Future<void> loadSales() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulamos una carga de datos de facturas y boletas
      await Future.delayed(const Duration(seconds: 1));

      _sales = [
        {
          'id': 'F001-00045',
          'type': 'Factura',
          'amount': 150.50,
          'date': '2026-01-31',
          'status': 'Pagado'
        },
        {
          'id': 'B001-00089',
          'type': 'Boleta',
          'amount': 45.00,
          'date': '2026-01-31',
          'status': 'Pagado'
        },
        {
          'id': 'F001-00046',
          'type': 'Factura',
          'amount': 2100.00,
          'date': '2026-01-30',
          'status': 'Pagado'
        },
      ];
    } catch (e) {
      _errorMessage = "Error al cargar el historial";
      dev.log("Error SalesReport: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
