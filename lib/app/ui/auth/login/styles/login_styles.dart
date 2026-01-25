import 'package:flutter/material.dart';
import 'package:anttec_movil/app/core/styles/titles.dart';
import 'package:anttec_movil/app/core/styles/texts.dart';

abstract class LoginStyles {
  // --- COLORES ---
  static const Color backgroundColor = Color(0xFFF5F5F5); // Gris fondo
  static const Color cardColor = Colors.white;
  static const Color inputBackground = Color(0xFFE0E0E0);
  static const Color buttonColor = Color(0xFF7B2CBF); // Morado
  static const Color titleColor = Color(0xFF444444);
  static const Color labelColor = Color(0xFF333333);
  static const Color textColor = Colors.black87;

  // --- DIMENSIONES ---
  static const double cardRadius = 24.0;
  static const double inputRadius = 12.0;

  // --- TEXT STYLES ---
  static TextStyle pageTitle = AppTitles.h1.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: titleColor,
  );

  static TextStyle inputLabel = AppTitles.h3.copyWith(
    fontWeight: FontWeight.bold,
    color: labelColor,
  );

  static TextStyle buttonText = AppTitles.h2.copyWith(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  static TextStyle rememberMeText = AppTexts.body1.copyWith(
    fontWeight: FontWeight.w500,
    color: textColor,
  );

  // --- DECORACIONES ---
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(cardRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 10),
      )
    ],
  );

  static BoxDecoration inputContainerDecoration = BoxDecoration(
    color: inputBackground,
    borderRadius: BorderRadius.circular(inputRadius),
  );
}
