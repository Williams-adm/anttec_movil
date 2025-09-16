import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:flutter/material.dart';

abstract class AppTitles {
  /// Texto para el login
  static const login = TextStyle(
    fontSize: 33,
    fontWeight: FontWeight.w600,
    color: AppColors.extradarkT,
  );

  /// Textos para títulos
  static const h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.darkT,
  );
  static const h2 = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w600,
    color: AppColors.darkT,
  );
  static const h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.darkT,
  );
}