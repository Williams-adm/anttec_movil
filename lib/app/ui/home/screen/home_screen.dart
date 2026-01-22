import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:anttec_movil/app/ui/product/screen/products_screen.dart';
import 'package:anttec_movil/app/ui/chat/screen/chat_screen.dart';

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
      body: ProductsScreen(token: _token!),

      // ✅ CORREGIDO: 'child' ahora está al final
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
        backgroundColor: const Color(0xFF7E33A3),
        tooltip: 'Asistente IA', // Tooltip va antes que child
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
    );
  }
}
