import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/core/styles/titles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class ErrorDialogW {
  static Future<void> show(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog.adaptive(
        backgroundColor: Colors.white,
        title: Text(
          message,
          style: AppTitles.h1.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.redAccent,
          ),
        ),
        icon: Icon(Symbols.dangerous, color: Colors.red, size: 60.0),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => context.pop(),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      AppColors.secondaryP,
                    ),
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                  child: Text(
                    'Cerrar',
                    style: AppTitles.h3.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryS,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
