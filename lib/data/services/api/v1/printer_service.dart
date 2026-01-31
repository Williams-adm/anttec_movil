import 'dart:async';
import 'dart:io';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'dart:developer' as dev;

class PrinterService {
  // ==========================================================
  // 1. UTILIDADES DE BÚSQUEDA Y DIAGNÓSTICO
  // ==========================================================

  /// Obtiene la lista de dispositivos Bluetooth ya emparejados en el celular
  Future<List<BluetoothInfo>> getPairedBluetooths() async {
    try {
      final List<BluetoothInfo> list =
          await PrintBluetoothThermal.pairedBluetooths;
      return list;
    } catch (e) {
      dev.log("Error buscando bluetooths: $e");
      return [];
    }
  }

  /// Escanea la red WiFi local buscando dispositivos con el puerto 9100 abierto (Ticketeras)
  Stream<String> scanNetworkPrinters() async* {
    final info = NetworkInfo();
    String? wifiIp = await info.getWifiIP();

    if (wifiIp == null) {
      dev.log("⚠️ No estás conectado a WiFi. No se puede escanear la red.");
      return;
    }

    // Obtenemos la subred (Ej: si tu IP es 192.168.1.50 -> '192.168.1')
    final String subnet = wifiIp.substring(0, wifiIp.lastIndexOf('.'));

    // Lista de futuros para chequear IPs en paralelo (del 1 al 254)
    final List<Future<String?>> checks = [];

    for (int i = 1; i < 255; i++) {
      final ip = '$subnet.$i';
      checks.add(_checkPort(ip, 9100));
    }

    // A medida que las IPs responden, las enviamos a la UI
    for (final future in checks) {
      final result = await future;
      if (result != null) {
        yield result;
      }
    }
  }

  /// Verifica rápidamente si una IP tiene un puerto abierto (Ping técnico)
  Future<String?> _checkPort(String ip, int port) async {
    try {
      // Timeout corto (200ms) para escanear rápido toda la red
      final socket = await Socket.connect(ip, port,
          timeout: const Duration(milliseconds: 200));
      socket.destroy();
      return ip; // ¡Respondió! Es una impresora.
    } catch (e) {
      return null;
    }
  }

  /// Prueba de conexión manual (Ping más largo para verificar estabilidad)
  Future<bool> testNetworkConnection(String ip, int port) async {
    try {
      final socket =
          await Socket.connect(ip, port, timeout: const Duration(seconds: 2));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================================
  // 2. MÉTODOS DE IMPRESIÓN (RED Y BLUETOOTH)
  // ==========================================================

  /// Imprimir en Ticketera de Red (Ethernet/WiFi)
  Future<void> printNetwork(
      String ip, int port, Map<String, dynamic> sale) async {
    try {
      dev.log("🖨️ Conectando a Ticketera de Red: $ip:$port");

      final socket =
          await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
      final List<int> bytes = await _generateTicket(sale);

      socket.add(bytes);
      await socket.flush();
      await socket.close();
      dev.log("✅ Ticket enviado por Red exitosamente");
    } catch (e) {
      dev.log("❌ Error de Red: $e");
      throw Exception("No se pudo conectar a la ticketera en $ip");
    }
  }

  /// Imprimir en Impresora Portátil (Bluetooth)
  Future<void> printBluetooth(
      String macAddress, Map<String, dynamic> sale) async {
    try {
      dev.log("🖨️ Conectando a Bluetooth: $macAddress");

      final bool connected =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);

      if (!connected) {
        throw Exception(
            "No se pudo conectar al dispositivo Bluetooth. Verifica que esté encendido.");
      }

      final List<int> bytes = await _generateTicket(sale);
      final result = await PrintBluetoothThermal.writeBytes(bytes);

      dev.log("✅ Ticket enviado por Bluetooth. Resultado: $result");
    } catch (e) {
      dev.log("❌ Error Bluetooth: $e");
      rethrow;
    }
  }

  // ==========================================================
  // 3. DISEÑADOR DEL TICKET (ESC/POS)
  // ==========================================================
  Future<List<int>> _generateTicket(Map<String, dynamic> sale) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // --- ENCABEZADO ---
    bytes += generator.text('ANTTEC MOVIL',
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            bold: true));

    bytes += generator.text('RUC: 10203040501',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Direccion: Huancayo, Junin',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Tel: 999-999-999',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr();

    // --- DATOS DEL DOCUMENTO ---
    final isFactura = sale['type'] == 'Factura';
    bytes += generator.text(
        isFactura ? 'FACTURA ELECTRONICA' : 'BOLETA DE VENTA',
        styles: const PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text('Serie-Correlativo: ${sale['id']}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Fecha Emision: ${sale['date']}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.hr();

    // --- DETALLE DE PRODUCTOS ---
    bytes += generator.row([
      PosColumn(text: 'Cant', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(
          text: 'Descripcion', width: 7, styles: const PosStyles(bold: true)),
      PosColumn(
          text: 'Total',
          width: 3,
          styles: const PosStyles(bold: true, align: PosAlign.right)),
    ]);

    // Bucle dinámico de productos
    if (sale['items'] != null) {
      for (var item in sale['items']) {
        bytes += generator.row([
          PosColumn(text: '${item['qty']}', width: 2),
          PosColumn(text: item['name'], width: 7),
          PosColumn(
              text: (item['total'] as double).toStringAsFixed(2),
              width: 3,
              styles: const PosStyles(align: PosAlign.right)),
        ]);
      }
    }

    bytes += generator.hr();

    // --- TOTALES ---
    final double amount = sale['amount'] as double;
    bytes += generator.text(
        'OP. GRAVADA: S/. ${(amount * 0.82).toStringAsFixed(2)}',
        styles: const PosStyles(align: PosAlign.right));
    bytes += generator.text(
        'IGV (18%): S/. ${(amount * 0.18).toStringAsFixed(2)}',
        styles: const PosStyles(align: PosAlign.right));

    bytes += generator.text('TOTAL A PAGAR: S/. ${amount.toStringAsFixed(2)}',
        styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
            bold: true));

    bytes += generator.hr(ch: '-');

    // --- PIE DE PÁGINA ---
    bytes += generator.text('Gracias por su preferencia!',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Representacion impresa de la',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(
        isFactura ? 'Factura Electronica' : 'Boleta de Venta Electronica',
        styles: const PosStyles(align: PosAlign.center));

    // --- ESPACIO Y CORTE ---
    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }
}
