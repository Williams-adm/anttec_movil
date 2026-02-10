import 'dart:async';
import 'dart:io';

// LIBRERÍAS DE IMAGEN Y PDF
import 'package:image/image.dart' as img;
import 'package:pdfx/pdfx.dart';
import 'package:printing/printing.dart'; // ✅ Vital para impresora A4

// LIBRERÍAS DE TICKETERA
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'dart:developer' as dev;

class PrinterService {
  // ==========================================================
  // A. MUNDO TICKETERA (80mm - PDF a IMAGEN)
  // ==========================================================

  /// Convierte PDF a Imagen y lo manda a la Ticketera (Red o Bluetooth)
  Future<void> printTicketera(
      String address, String pdfPath, bool isBluetooth) async {
    try {
      dev.log("🔄 Iniciando proceso Ticketera...");

      // 1. Convertir PDF a Imagen
      final document = await PdfDocument.openFile(pdfPath);
      final page = await document.getPage(1);

      // Renderizamos al doble de calidad (scale 2.0) para nitidez en letras pequeñas
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.jpeg,
        quality: 100,
      );

      if (pageImage == null) {
        throw Exception("No se pudo renderizar el PDF");
      }

      final img.Image? decodedImage = img.decodeImage(pageImage.bytes);
      if (decodedImage == null) {
        throw Exception("No se pudo decodificar la imagen");
      }

      // 2. Preparar Comandos ESC/POS
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      bytes += generator.reset();

      // ⚠️ AJUSTE CLAVE: 550px para papel de 80mm
      // (576px es el máximo teórico, 550px es seguro para evitar cortes)
      final img.Image resized = img.copyResize(decodedImage, width: 550);

      bytes += generator.image(resized);
      bytes += generator.feed(3);
      bytes += generator.cut();

      // 3. Enviar a la máquina
      if (isBluetooth) {
        final bool connected =
            await PrintBluetoothThermal.connect(macPrinterAddress: address);
        if (!connected) {
          throw Exception("No conectado al Bluetooth");
        }
        await PrintBluetoothThermal.writeBytes(bytes);
      } else {
        // --- LÓGICA DE RED ROBUSTA (HUANCAYO) ---
        dev.log("🔌 Conectando a Ticketera IP: $address");

        // Timeout de 5s para redes WiFi lentas o saturadas
        final socket = await Socket.connect(address, 9100,
            timeout: const Duration(seconds: 5));

        socket.add(bytes);
        await socket.flush();

        // ⏳ ESPERA DE SEGURIDAD: 3 SEGUNDOS
        // Esto evita que la impresora corte la conexión antes de recibir toda la imagen
        dev.log("⏳ Enviando datos (esperando 3s)...");
        await Future.delayed(const Duration(seconds: 3));

        await socket.close();
      }

      await page.close();
      await document.close();
      dev.log("✅ Ticket impreso con éxito");
    } catch (e) {
      dev.log("❌ Error Ticketera: $e");
      rethrow; // Reenviamos el error para que la UI lo muestre
    }
  }

  // ==========================================================
  // B. MUNDO IMPRESORA ESTÁNDAR (A4 - Sistema Android)
  // ==========================================================

  /// Abre el diálogo nativo de Android para imprimir en HP, Epson, Canon, etc.
  Future<void> printStandard(String pdfPath) async {
    try {
      dev.log("🖨️ Abriendo impresión de sistema...");
      final file = File(pdfPath);
      final bytes = await file.readAsBytes();

      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'Documento Anttec',
      );
    } catch (e) {
      throw Exception("Error en impresión estándar: $e");
    }
  }

  // ==========================================================
  // C. UTILIDADES DE RED Y BLUETOOTH
  // ==========================================================

  Future<List<BluetoothInfo>> getPairedBluetooths() async {
    try {
      return await PrintBluetoothThermal.pairedBluetooths;
    } catch (e) {
      dev.log("Error BT: $e");
      return [];
    }
  }

  Stream<String> scanNetworkPrinters() async* {
    final info = NetworkInfo();
    String? wifiIp = await info.getWifiIP();
    if (wifiIp == null) {
      return;
    }

    final String subnet = wifiIp.substring(0, wifiIp.lastIndexOf('.'));
    final List<Future<String?>> checks = [];

    // Escaneo rápido (timeout corto para barrer 255 IPs)
    for (int i = 1; i < 255; i++) {
      checks.add(_checkPort('$subnet.$i', 9100));
    }

    for (final future in checks) {
      final result = await future;
      if (result != null) {
        yield result;
      }
    }
  }

  Future<String?> _checkPort(String ip, int port) async {
    try {
      // 1.5s es suficiente para saber si hay alguien escuchando
      final socket = await Socket.connect(ip, port,
          timeout: const Duration(milliseconds: 1500));
      socket.destroy();
      return ip;
    } catch (e) {
      return null;
    }
  }

  Future<bool> testNetworkConnection(String ip) async {
    try {
      // Test manual: 5 segundos de paciencia (puede que el WiFi esté lento)
      final socket =
          await Socket.connect(ip, 9100, timeout: const Duration(seconds: 5));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }
}
