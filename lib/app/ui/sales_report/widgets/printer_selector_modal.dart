import 'package:anttec_movil/data/services/api/v1/printer_service.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterSelectorModal extends StatefulWidget {
  final Function(String type, String address) onPrinterSelected;

  const PrinterSelectorModal({super.key, required this.onPrinterSelected});

  @override
  State<PrinterSelectorModal> createState() => _PrinterSelectorModalState();
}

class _PrinterSelectorModalState extends State<PrinterSelectorModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PrinterService _printerService = PrinterService();

  // Estado Bluetooth
  List<BluetoothInfo> _bluetoothDevices = [];
  bool _scanningBT = false;

  // Estado Red (Manual y Escáner)
  final TextEditingController _ipController = TextEditingController();
  bool _testingNet = false;
  bool? _netStatus;

  // ✅ CORREGIDO: Ahora es final porque solo modificamos su contenido, no la referencia
  final List<String> _networkDevices = [];

  bool _scanningNet = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSavedIp();
    _scanBluetooth(); // Escanear Bluetooth automáticamente al abrir
  }

  void _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    _ipController.text = prefs.getString('saved_printer_ip') ?? '192.168.1.87';
  }

  // --- BLUETOOTH ---
  void _scanBluetooth() async {
    if (!mounted) return;
    setState(() => _scanningBT = true);
    final devices = await _printerService.getPairedBluetooths();
    if (mounted) {
      setState(() {
        _bluetoothDevices = devices;
        _scanningBT = false;
      });
    }
  }

  // --- RED: ESCANEO ---
  void _scanNetwork() async {
    setState(() {
      _scanningNet = true;
      _networkDevices.clear();
    });

    _printerService.scanNetworkPrinters().listen((ip) {
      if (mounted) {
        setState(() {
          _networkDevices.add(ip);
        });
      }
    }, onDone: () {
      if (mounted) setState(() => _scanningNet = false);
    });
  }

  // --- RED: PRUEBA MANUAL ---
  void _testIp(String ipToTest) async {
    if (ipToTest.isEmpty) return;

    _ipController.text = ipToTest; // Actualizar campo visual

    setState(() {
      _testingNet = true;
      _netStatus = null;
    });
    final success = await _printerService.testNetworkConnection(ipToTest, 9100);

    if (mounted) {
      setState(() {
        _testingNet = false;
        _netStatus = success;
      });

      if (success) {
        // Guardar la IP exitosa para futuras veces
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('saved_printer_ip', ipToTest);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 15),
          const Text("Seleccionar Impresora",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF6C3082),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF6C3082),
            tabs: const [
              Tab(icon: Icon(Symbols.bluetooth), text: "Bluetooth"),
              Tab(icon: Icon(Symbols.lan), text: "Red / WiFi"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBluetoothTab(),
                _buildNetworkTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothTab() {
    return Column(
      children: [
        if (_scanningBT)
          const LinearProgressIndicator(
              color: Color(0xFF6C3082), backgroundColor: Color(0xFFF3E5F5)),
        Expanded(
          child: _bluetoothDevices.isEmpty && !_scanningBT
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Symbols.bluetooth_disabled,
                          size: 50, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      const Text(
                          "No se encontraron dispositivos Bluetooth vinculados"),
                      TextButton(
                          onPressed: _scanBluetooth,
                          child: const Text("Reintentar"))
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _bluetoothDevices.length,
                  itemBuilder: (context, index) {
                    final device = _bluetoothDevices[index];
                    return ListTile(
                      leading: const Icon(Symbols.print, color: Colors.black54),
                      title: Text(device.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(device.macAdress),
                      trailing: const Icon(Symbols.chevron_right),
                      onTap: () {
                        // Al seleccionar, cerramos modal y enviamos la MAC
                        widget.onPrinterSelected('BT', device.macAdress);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNetworkTab() {
    return Column(
      children: [
        // 1. INPUT MANUAL
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Dirección IP Manual",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ipController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Ej: 192.168.1.87",
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Symbols.router, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Botón Check
                  IconButton.filled(
                    onPressed:
                        _testingNet ? null : () => _testIp(_ipController.text),
                    icon: _testingNet
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check),
                    style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF6C3082)),
                  )
                ],
              ),
              if (_netStatus != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _netStatus! ? "✅ Conexión Exitosa" : "❌ No responde",
                    style: TextStyle(
                        color: _netStatus! ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
            ],
          ),
        ),

        const Divider(height: 1),

        // 2. ESCÁNER DE RED
        Container(
          width: double.infinity,
          color: Colors.grey[50],
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Escáner de Red Local",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              TextButton.icon(
                onPressed: _scanningNet ? null : _scanNetwork,
                icon: _scanningNet
                    ? const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh, size: 18),
                label: Text(_scanningNet ? "Escaneando..." : "Escanear"),
              )
            ],
          ),
        ),

        if (_scanningNet)
          const LinearProgressIndicator(
              color: Color(0xFF6C3082), backgroundColor: Color(0xFFF3E5F5)),

        // 3. RESULTADOS DEL ESCÁNER
        Expanded(
          child: _networkDevices.isEmpty && !_scanningNet
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Symbols.wifi_find,
                          size: 40, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      const Text("Presiona 'Escanear' para buscar ticketeras",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _networkDevices.length,
                  itemBuilder: (context, index) {
                    final ip = _networkDevices[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE0F2F1),
                        child: Icon(Symbols.print, color: Color(0xFF00695C)),
                      ),
                      title: const Text("Impresora ESC/POS"),
                      subtitle: Text(ip),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _testIp(ip); // Selecciona y prueba
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10)),
                        child: const Text("Probar"),
                      ),
                    );
                  },
                ),
        ),

        // 4. BOTÓN USAR IP MANUAL (Si el test pasó)
        if (_netStatus == true)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  widget.onPrinterSelected('NET', _ipController.text);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C3082),
                    foregroundColor: Colors.white),
                child: const Text("USAR ESTA IMPRESORA"),
              ),
            ),
          )
      ],
    );
  }
}
