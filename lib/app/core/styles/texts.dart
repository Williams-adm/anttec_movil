import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTexts {
  /// Textos en general light ( L )
  static const body1L = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w300,
    color: AppColors.extradarkT,
  );
  static const body2L = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    color: AppColors.extradarkT,
  );
  static const body3L = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: AppColors.extradarkT,
  );

  /// Textos en general Normal
  static const body1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.extradarkT,
  );
  static const body2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.extradarkT,
  );
  static const body3 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.extradarkT,
  );

  /// Textos en general Medium ( M )
  static const body1M = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.extradarkT,
  );
  static const body2M = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.extradarkT,
  );
  static const body3M = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.extradarkT,
  );
}