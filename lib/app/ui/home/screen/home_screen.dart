import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart'; // ✅ Importar GoRouter
import 'package:anttec_movil/app/ui/product/screen/products_screen.dart';

// No necesitamos importar chat_screen aqui porque usaremos la ruta '/chat'

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _secureStorage = const FlutterSecureStorage();
  String? _token;
  bool _loading = true;

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
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_token == null || _token!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Error: No se encontró token de sesión')),
      );
    }

    return Scaffold(
      // Aquí llamamos a la pantalla que tiene la lista (y el error de navegación)
      body: ProductsScreen(token: _token!),

      // ✅ BOTÓN FLOTANTE CHAT (Optimizado)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Usamos push para ir al chat sin borrar el home
          context.push('/chat');
        },
        backgroundColor: const Color(0xFF7E33A3),
        tooltip: 'Asistente IA',
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
    );
  }
}
