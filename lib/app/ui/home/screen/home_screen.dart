import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:anttec_movil/app/ui/product/screen/products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _secureStorage = const FlutterSecureStorage();
  String? _token;
  bool _loading = true; // Variable para controlar el estado de carga

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (mounted) {
        setState(() {
          _token = token;
          _loading = false; // Terminó de cargar
        });
      }
    } catch (e) {
      // Si hay error, dejamos de cargar para mostrar el mensaje
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Estado de Carga
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Estado de Error (No hay token)
    if (_token == null || _token!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Error: No se encontró token de sesión')),
      );
    }

    // 3. Estado de Éxito
    return Scaffold(body: ProductsScreen(token: _token!));
  }
}
