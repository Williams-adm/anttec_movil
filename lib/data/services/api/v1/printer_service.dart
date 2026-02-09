import 'dart:async';
import 'dart:io';
import 'dart:typed_data'; // ✅ Necesario para manejar bytes de imagen

import 'package:flutter/services.dart'
    show rootBundle; // ✅ Necesario para cargar assets
import 'package:image/image.dart'
    as img; // ✅ Necesario para procesar la imagen para la impresora

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'dart:developer' as dev;

class PrinterService {
  // ==========================================================
  // 1. UTILIDADES Y DIAGNÓSTICO
  // ==========================================================
  // (Esta sección no cambia, se mantiene igual)
  Future<List<BluetoothInfo>> getPairedBluetooths() async {
    try {
      return await PrintBluetoothThermal.pairedBluetooths;
    } catch (e) {
      dev.log("Error buscando bluetooths: $e");
      return [];
    }
  }

  Stream<String> scanNetworkPrinters() async* {
    final info = NetworkInfo();
    String? wifiIp = await info.getWifiIP();
    if (wifiIp == null) return;

    final String subnet = wifiIp.substring(0, wifiIp.lastIndexOf('.'));
    final List<Future<String?>> checks = [];

    for (int i = 1; i < 255; i++) {
      final ip = '$subnet.$i';
      checks.add(_checkPort(ip, 9100));
    }

    for (final future in checks) {
      final result = await future;
      if (result != null) yield result;
    }
  }

  Future<String?> _checkPort(String ip, int port) async {
    try {
      final socket = await Socket.connect(ip, port,
          timeout: const Duration(milliseconds: 200));
      socket.destroy();
      return ip;
    } catch (e) {
      return null;
    }
  }

  Future<bool> testNetworkConnection(String ip, int port) async {
    try {
      final socket =
          await Socket.connect(ip, port, timeout: const Duration(seconds: 2));
      socket.destroy();
      return true;
    } catch (e) {
      dev.log("Error de conexión manual a $ip: $e");
      return false;
    }
  }

  // ==========================================================
  // 2. MÉTODOS DE IMPRESIÓN
  // ==========================================================
  // (Esta sección no cambia, se mantiene igual)
  Future<void> printNetwork(
      String ip, int port, Map<String, dynamic> sale) async {
    try {
      final socket =
          await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
      final List<int> bytes = await _generateTicket(sale);
      socket.add(bytes);
      await socket.flush();
      await socket.close();
    } catch (e) {
      throw Exception("No se pudo conectar a la ticketera en $ip");
    }
  }

  Future<void> printBluetooth(
      String macAddress, Map<String, dynamic> sale) async {
    try {
      final bool connected =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
      if (!connected) throw Exception("No se pudo conectar al Bluetooth.");
      final List<int> bytes = await _generateTicket(sale);
      await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      rethrow;
    }
  }

  // ==========================================================
  // 🆕 FUNCIÓN AUXILIAR PARA CARGAR IMAGEN DE ASSETS
  // ==========================================================
  Future<img.Image?> _loadImageFromAssets(String path) async {
    try {
      final ByteData data = await rootBundle.load(path);
      final Uint8List bytes = data.buffer.asUint8List();
      return img.decodeImage(bytes);
    } catch (e) {
      dev.log("❌ Error cargando logo para ticket: $e");
      return null;
    }
  }

  // ==========================================================
  // 3. GENERADOR DE TICKET (ESTILO PROFESIONAL CON LOGO)
  // ==========================================================
  Future<List<int>> _generateTicket(Map<String, dynamic> sale) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // 🆕 --- CARGAR E IMPRIMIR LOGO ---
    // Cargamos la imagen antes de empezar a generar el ticket
    final img.Image? logoImage =
        await _loadImageFromAssets('assets/images/logo_anttec.png');

    if (logoImage != null) {
      // Redimensionamos la imagen para que quepa bien en el papel térmico (aprox 380px de ancho es seguro)
      // Esto evita que se imprima basura si la imagen original es muy grande HD.
      final img.Image resizedLogo = img.copyResize(logoImage, width: 380);
      // Imprimimos la imagen centrada
      bytes += generator.image(resizedLogo, align: PosAlign.center);
      bytes += generator.feed(1); // Un pequeño espacio debajo del logo
    } else {
      // Si falla la carga de la imagen, mostramos el texto de respaldo
      dev.log("⚠️ No se pudo cargar el logo, usando texto de respaldo.");
      bytes += generator.text('ANTTEC',
          styles: const PosStyles(
              align: PosAlign.center,
              height: PosTextSize.size2,
              width: PosTextSize.size2,
              bold: true));
    }

    // --- ENCABEZADO DE TEXTO (Se mantiene el nombre debajo del logo) ---
    // Agregamos el nombre de la empresa en texto grande debajo del logo
    bytes += generator.text('ANTTEC PERÚ',
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            bold: true));

    bytes += generator.text('PERALTA BERNAOLA ROBBIE WILLIAMS',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Av. Giraldez NRO. 274 INT. T-2 Huancayo',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('RUC: 10752359879',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.hr();

    // --- DATOS DEL COMPROBANTE ---
    final String typeDoc = sale['type'] ?? 'BOLETA DE VENTA';
    bytes += generator.text('$typeDoc ELECTRÓNICA',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text(sale['id'] ?? 'BBB2-000000',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.hr();

    // --- DATOS DEL CLIENTE ---
    bytes += generator.text(
        'ADQUIRIENTE: ${sale['customer_name'] ?? 'Público General'}',
        styles: const PosStyles(bold: true));
    bytes += generator.text('DNI/RUC: ${sale['doc_number'] ?? '---'}');
    bytes += generator.text('FECHA EMISIÓN: ${sale['date'] ?? '09/02/2026'}');
    bytes += generator.text('MONEDA: SOLES');
    bytes += generator.hr();

    // --- TABLA DE PRODUCTOS (4 COLUMNAS: CAN | DESCRIPCIÓN | P/U | TOTAL) ---
    bytes += generator.row([
      PosColumn(text: 'CAN', width: 1, styles: const PosStyles(bold: true)),
      PosColumn(
          text: 'DESCRIPCIÓN', width: 5, styles: const PosStyles(bold: true)),
      PosColumn(
          text: 'P/U',
          width: 3,
          styles: const PosStyles(bold: true, align: PosAlign.right)),
      PosColumn(
          text: 'TOTAL',
          width: 3,
          styles: const PosStyles(bold: true, align: PosAlign.right)),
    ]);

    if (sale['items'] != null) {
      for (var item in sale['items']) {
        bytes += generator.row([
          PosColumn(text: '${item['qty']}', width: 1),
          PosColumn(text: '${item['name']}', width: 5),
          PosColumn(
            text: (item['price'] as double? ?? 0.0).toStringAsFixed(2),
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: (item['total'] as double? ?? 0.0).toStringAsFixed(2),
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
    }
    bytes += generator.hr();

    // --- RESUMEN DE TOTALES ---
    final double totalAmount = sale['amount'] as double? ?? 0.0;
    final double gravada = totalAmount / 1.18;
    final double igv = totalAmount - gravada;

    bytes += generator.row([
      PosColumn(
          text: 'GRAVADA',
          width: 8,
          styles: const PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'S/ ${gravada.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'IGV (18%)',
          width: 8,
          styles: const PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'S/ ${igv.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'TOTAL',
          width: 8,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
      PosColumn(
          text: 'S/ ${totalAmount.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.hr();
    // (Opcional: Si tu API devuelve el monto en letras, descomenta esta línea)
    // bytes += generator.text('SON: ${sale['amount_letters'] ?? '---'}', styles: const PosStyles(align: PosAlign.left));
    // bytes += generator.hr();

    // --- PIE DE PÁGINA Y QR LEGAL ---
    bytes += generator.text('Representación impresa de la $typeDoc',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Visite: www.nubefact.com/10752359879',
        styles: const PosStyles(align: PosAlign.center));

    bytes += generator.feed(1);

    bytes += generator.qrcode(
        sale['qr_content'] ?? 'https://www.nubefact.com/consulta',
        size: QRSize.size4,
        align: PosAlign.center);

    bytes += generator.feed(1);
    bytes += generator.text('Emitido desde anttec_movil',
        styles: const PosStyles(align: PosAlign.center));

    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }
}
