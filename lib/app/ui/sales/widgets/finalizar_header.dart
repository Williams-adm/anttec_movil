import 'package:flutter/material.dart';

class FinalizarHeader extends StatelessWidget {
  const FinalizarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Finalizar venta',
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }
}
