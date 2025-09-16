import 'package:flutter/widgets.dart';

abstract final class AppColors {
  /// P hace referencia a los colores primarios
  static const primaryP = Color(0xff753089); //P-800
  static const secondaryP = Color(0xff803398); //P-700
  static const tertiaryP = Color(0xffDFB8EF); //P-300
  static const background = Color(0xffFBF6FD); //P-100 (F6ECFB)
  static const degraded = Color(0xff1E0C23); //P-950

  /// S hace referencia a los colores secundarios
  static const primaryS = Color(0xffFFFFFF); //S-50
  static const secondaryS = Color(0xffDCDCDC); //S-200
  static const tertiaryS = Color(0xffEFEFEF); //S-100

  /// T hace referencia a los colores de texto
  static const extradarkT = Color(0xff292929); //S-950
  static const darkT = Color(0xff464646); //S-800
  static const semidarkT = Color(0xff656565); //S-600
  static const lightdarkT = Color(0xff989898); //S-400
}