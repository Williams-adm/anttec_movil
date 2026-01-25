import 'package:flutter/material.dart';

abstract class ScanStyles {
  // --- COLORES ---
  static const Color backgroundColor = Colors.black;
  static const Color accentColor = Colors.blueAccent;
  static const Color white = Colors.white;

  // Usamos withValues para Flutter moderno (reemplazo de withOpacity)
  static final Color overlayColor = Colors.black.withValues(alpha: 0.5);
  static const Color loaderBackgroundColor = Colors.black87;
  static const Color galleryButtonBackground = Colors.black26;
  static const Color galleryButtonBorder = Colors.white54;

  // --- DIMENSIONES Y BORDES ---
  static const double scannerBorderRadius = 12.0;
  static const double scannerBorderLength = 30.0;
  static const double scannerBorderWidth = 4.0;
  static const Size scanWindowSize = Size(280, 280);

  // --- SOMBRAS ---
  static const List<Shadow> textShadows = [
    Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black),
  ];

  // --- TEXT STYLES ---
  static const TextStyle instructionText = TextStyle(
    color: white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    shadows: textShadows,
  );

  static const TextStyle modeText = TextStyle(
    color: accentColor,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static const TextStyle loadingText =
      TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w400);
}
