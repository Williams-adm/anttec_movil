import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/app/ui/product/screen/products_screen.dart';

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
    // 1. Estado de Carga Inicial (Obteniendo Token)
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Estado de Error (Sin Token)
    if (_token == null || _token!.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error: No se encontró sesión activa'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text("Ir al Login"),
              )
            ],
          ),
        ),
      );
    }

    // 3. Pantalla Principal
    return Scaffold(
      // Llamamos a ProductsScreen donde está el Buscador y la Lista
      body: ProductsScreen(token: _token!),

      // BOTÓN FLOTANTE CHAT (IA)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/chat');
        },
        backgroundColor: const Color(0xFF7E33A3),
        tooltip: 'Asistente IA',
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
    );
  }
}
