import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:anttec_movil/data/services/api/v1/sales_report_service.dart';
import 'dart:developer' as dev;

class SalesReportViewmodel extends ChangeNotifier {
  final SalesReportService _service = SalesReportService();

  bool _isLoading = false;
  List<Map<String, dynamic>> _sales = [];
  double _totalSalesAmount = 0.0;
  int _totalDocs = 0;

  DateTime? _selectedDate;
  int _currentPage = 1;
  bool _hasMorePages = true;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get sales => _sales;
  double get totalSalesAmount => _totalSalesAmount;
  int get totalDocs => _totalDocs;
  DateTime? get selectedDate => _selectedDate;

  // CARGAR VENTAS
  Future<void> loadSales({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _sales.clear();
      _hasMorePages = true;
      _totalSalesAmount = 0.0;
      _totalDocs = 0;
    }

    if (!_hasMorePages && !refresh) return;

    _isLoading = true;
    notifyListeners();

    String? dateStr;
    if (_selectedDate != null) {
      dateStr = DateFormat('dd-MM-yyyy').format(_selectedDate!);
    }

    final response = await _service.getOrders(
      page: _currentPage,
      date: dateStr,
    );

    if (response != null) {
      final List newSales = response['data'] ?? [];
      final totals = response['totals'] ?? {};
      final meta = response['meta'] ?? {};

      final List<Map<String, dynamic>> parsedSales =
          newSales.map((e) => Map<String, dynamic>.from(e)).toList();

      if (_currentPage == 1) {
        _sales = parsedSales;
      } else {
        _sales.addAll(parsedSales);
      }

      _totalSalesAmount =
          double.tryParse(totals['total_sales'].toString()) ?? 0.0;
      _totalDocs = totals['total_items'] ?? 0;

      int lastPage = meta['last_page'] ?? 1;
      if (_currentPage >= lastPage) {
        _hasMorePages = false;
      } else {
        _currentPage++;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void setDateFilter(DateTime date) {
    _selectedDate = date;
    loadSales(refresh: true);
  }

  // LÓGICA DE DETALLES CORREGIDA
  Future<Map<String, dynamic>?> fetchSaleDetailsForPrint(int index) async {
    var sale = _sales[index];

    // 1. Si ya tiene items, devolverlos
    if (sale.containsKey('items') &&
        sale['items'] != null &&
        (sale['items'] as List).isNotEmpty) {
      return sale;
    }

    // 2. Usamos el ID DE LA ORDEN (ej: 23), NO el voucher_id
    final rawId = sale['id'];
    if (rawId == null) {
      dev.log("Error: ID de venta nulo");
      return null;
    }

    final int orderId = int.parse(rawId.toString());

    // 3. Llamar al servicio corregido
    final items = await _service.getOrderDetails(orderId);

    if (items != null) {
      _sales[index]['items'] = items;
      notifyListeners();
      return _sales[index];
    }

    // Si falla, retornamos la venta sin items (al menos imprimirá cabecera)
    return sale;
  }
}
