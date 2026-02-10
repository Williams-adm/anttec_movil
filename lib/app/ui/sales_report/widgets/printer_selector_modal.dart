import 'package:anttec_movil/data/services/api/v1/printer_service.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterSelectorModal extends StatefulWidget {
  // type puede ser: 'NET', 'BT', o 'STANDARD'
  final Function(String type, String address) onPrinterSelected;

  const PrinterSelectorModal({super.key, required this.onPrinterSelected});

  @override
  State<PrinterSelectorModal> createState() => _PrinterSelectorModalState();
}

class _PrinterSelectorModalState extends State<PrinterSelectorModal>
    with SingleTickerProviderStateMixin {
  final PrinterService _printerService = PrinterService();

  // 0 = Ticketera (80mm), 1 = Impresora Estándar (A4)
  int _selectedMode = 0;
  late TabController _tabController;

  // Variables Ticketera
  List<BluetoothInfo> _btDevices = [];

  // ✅ CORREGIDO: Se agregó 'final' para eliminar el warning
  final List<String> _netDevices = [];

  final TextEditingController _ipController = TextEditingController();
  bool _scanning = false;
  bool _testingIp = false;
  bool? _ipStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSavedIp();
    _scanBluetooth();
  }

  void _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    // ✅ CORREGIDO: Se agregaron llaves {} al if
    if (mounted) {
      setState(() =>
          _ipController.text = prefs.getString('saved_ip') ?? '192.168.1.23');
    }
  }

  void _scanBluetooth() async {
    if (!mounted) return;
    setState(() => _scanning = true);
    final devices = await _printerService.getPairedBluetooths();

    // ✅ CORREGIDO: Se agregaron llaves {} al if
    if (mounted) {
      setState(() {
        _btDevices = devices;
        _scanning = false;
      });
    }
  }

  void _scanNetwork() async {
    setState(() {
      _scanning = true;
      _netDevices.clear();
    });
    _printerService.scanNetworkPrinters().listen((ip) {
      if (mounted) {
        setState(() => _netDevices.add(ip));
      }
    }, onDone: () {
      if (mounted) {
        setState(() => _scanning = false);
      }
    });
  }

  void _testIp(String ip) async {
    final cleanIp = ip.trim();
    if (cleanIp.isEmpty) return;

    setState(() {
      _testingIp = true;
      _ipStatus = null;
    });

    // Probamos conexión (el puerto 9100 está en el servicio)
    bool ok = await _printerService.testNetworkConnection(cleanIp);

    if (mounted) {
      setState(() {
        _testingIp = false;
        _ipStatus = ok;
      });
      if (ok) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('saved_ip', cleanIp);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 650,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          const Text("Seleccionar Tipo de Impresión",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),

          // --- HEADER: SWITCH TIPO IMPRESORA (TICKETERA vs A4) ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                _buildModeBtn("Ticketera", Symbols.receipt_long, 0),
                _buildModeBtn("Impresora A4", Symbols.print, 1),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // --- CONTENIDO ---
          Expanded(
            child: _selectedMode == 0
                ? _buildTicketeraView() // Vista Ticketera (BT/WiFi)
                : _buildStandardView(), // Vista Impresora A4
          ),
        ],
      ),
    );
  }

  Widget _buildModeBtn(String text, IconData icon, int index) {
    bool isSelected = _selectedMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isSelected ? const Color(0xFF6C3082) : Colors.grey),
              const SizedBox(width: 8),
              Text(text,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  // --- VISTA 1: TICKETERA ---
  Widget _buildTicketeraView() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6C3082),
          indicatorColor: const Color(0xFF6C3082),
          tabs: const [Tab(text: "Bluetooth"), Tab(text: "WiFi / Red")],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Bluetooth
              _btDevices.isEmpty
                  ? Center(
                      child: TextButton.icon(
                          icon: const Icon(Symbols.refresh),
                          label: const Text("Escanear BT"),
                          onPressed: _scanBluetooth))
                  : ListView.builder(
                      itemCount: _btDevices.length,
                      itemBuilder: (ctx, i) => ListTile(
                        leading: const Icon(Symbols.bluetooth),
                        title: Text(_btDevices[i].name),
                        subtitle: Text(_btDevices[i].macAdress),
                        trailing: const Icon(Symbols.chevron_right),
                        onTap: () => widget.onPrinterSelected(
                            'BT', _btDevices[i].macAdress),
                      ),
                    ),

              // WiFi
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(
                          child: TextField(
                              controller: _ipController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: "IP Manual",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Symbols.router)))),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF6C3082)),
                        icon: _testingIp
                            ? const SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.check, color: Colors.white),
                        onPressed: () => _testIp(_ipController.text),
                      )
                    ]),
                    if (_ipStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _ipStatus!
                              ? "✅ Conectado"
                              : "❌ No responde (Verifica WiFi y Datos apagados)",
                          style: TextStyle(
                              color: _ipStatus! ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    const Divider(),
                    ListTile(
                      title: const Text("Escáner de Red Local"),
                      trailing: _scanning
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : IconButton(
                              icon: const Icon(Symbols.refresh),
                              onPressed: _scanNetwork),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _netDevices.length,
                        itemBuilder: (ctx, i) => ListTile(
                          title: const Text("Impresora ESC/POS"),
                          subtitle: Text(_netDevices[i]),
                          leading: const Icon(Symbols.print),
                          onTap: () {
                            _ipController.text = _netDevices[i];
                            _testIp(_netDevices[i]);
                          },
                        ),
                      ),
                    ),
                    if (_ipStatus == true)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C3082),
                              foregroundColor: Colors.white),
                          onPressed: () => widget.onPrinterSelected(
                              'NET', _ipController.text.trim()),
                          child: const Text("IMPRIMIR TICKET AHORA"),
                        ),
                      )
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  // --- VISTA 2: IMPRESORA ESTÁNDAR ---
  Widget _buildStandardView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Symbols.print_connect, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Usa este modo para impresoras EPSON, HP, CANON o cualquier impresora configurada en tu celular.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white),
            icon: const Icon(Symbols.system_update_alt),
            label: const Text("ABRIR SISTEMA DE IMPRESIÓN"),
            onPressed: () {
              // Enviamos tipo 'STANDARD' y cadena vacía porque no necesita IP
              widget.onPrinterSelected('STANDARD', '');
            },
          )
        ],
      ),
    );
  }
}
