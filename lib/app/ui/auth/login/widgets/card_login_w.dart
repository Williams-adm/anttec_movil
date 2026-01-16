import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:flutter/material.dart';

class CardLoginW extends StatelessWidget {
  final List<Widget> children;

  const CardLoginW({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      // shape: RoundedRectangleBorder ya maneja borderSide none por defecto
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          24.0,
        ), // Un poco más redondeado (moderno)
      ),
      color: AppColors.primaryS,
      margin: const EdgeInsets.symmetric(horizontal: 24.0), // Más responsivo
      elevation: 10.0,
      shadowColor: Colors.black.withValues(alpha: 0.1), // Sombra más suave
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch, // Alineación completa
          children: children,
        ),
      ),
    );
  }
}
