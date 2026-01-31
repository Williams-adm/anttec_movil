import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class SalesReportViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _sales = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get sales => _sales;
  String? get errorMessage => _errorMessage;

  // Carga las ventas (Simulado)
  Future<void> loadSales() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulamos la espera de la API
      await Future.delayed(const Duration(seconds: 1));

      _sales = [
        {
          'id': 'F001-00045',
          'type': 'Factura',
          'amount': 240.00,
          'date': '2026-01-31 15:30',
          'status': 'Pagado',
          'payment': 'Transferencia',
          // ✅ Lista de productos para la impresora
          'items': [
            {'qty': 1, 'name': 'Teclado Mecanico RGB', 'total': 150.00},
            {'qty': 1, 'name': 'Mouse G203', 'total': 90.00},
          ]
        },
        {
          'id': 'B001-00089',
          'type': 'Boleta',
          'amount': 45.00,
          'date': '2026-01-31 10:15',
          'status': 'Pagado',
          'payment': 'Yape',
          'items': [
            {'qty': 1, 'name': 'Mousepad XL Antryx', 'total': 45.00},
          ]
        },
        {
          'id': 'F001-00046',
          'type': 'Factura',
          'amount': 2100.00,
          'date': '2026-01-30 18:00',
          'status': 'Pagado',
          'payment': 'Efectivo',
          'items': [
            {'qty': 1, 'name': 'Monitor 144hz Asus', 'total': 1200.00},
            {'qty': 1, 'name': 'Silla Gamer', 'total': 900.00},
          ]
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
