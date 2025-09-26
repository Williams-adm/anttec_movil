import 'package:anttec_movil/app/core/styles/texts.dart';
import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color(0xffD9D9D9),
            borderRadius: BorderRadius.circular(10),
          ),
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 30),
          height: 560,
          child: Center(
            child: Container(
              width: 280, // Tamaño del cuadrado
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, // Color del borde
                  width: 1, // Grosor del borde
                ),
              ),
            ),
          ),
        ),
        Text(
          "Apunta la cámara hacia el código de barras para agregar el producto rápidamente",
          textAlign: TextAlign.center,
          style: AppTexts.body2,
        ),
      ],
    );
  }
}
