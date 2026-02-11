import 'package:flutter/material.dart';
import 'package:anttec_movil/data/services/api/v1/model/product/product_detail_response.dart';

class ColorSelector extends StatelessWidget {
  final List<VariantOption> variants;
  final int selectedId;
  final Color primaryColor;
  final Function(int) onVariantSelected;

  const ColorSelector({
    super.key,
    required this.variants,
    required this.selectedId,
    required this.primaryColor,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 🛠️ DEBUG: Mira tu consola para ver si llegan datos
    debugPrint("ColorSelector recibió: ${variants.length} variantes");

    if (variants.isEmpty) {
      return const Text("Sin opciones", style: TextStyle(color: Colors.grey));
    }

    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: variants.map((v) {
        final isSelected = v.id == selectedId;

        // 1. Búsqueda insensible a mayúsculas ('Color' == 'color') y segura
        Feature? colorFeat;
        try {
          colorFeat = v.features.firstWhere(
            (f) => f.type.toLowerCase() == 'color',
            orElse: () => Feature(
              id: 0,
              option: 'Unknown',
              type: 'color',
              value: '#CCCCCC', // Color por defecto (Gris)
              description: '',
            ),
          );
        } catch (e) {
          // Fallback por si la lista features es nula o vacía de una forma inesperada
          colorFeat = Feature(
            id: 0,
            option: 'Unknown',
            type: 'color',
            value: '#CCCCCC',
            description: '',
          );
        }

        // 2. Limpieza robusta del Hexadecimal
        Color circleColor;
        try {
          String hex = colorFeat.value.replaceAll('#', '').trim();
          if (hex.length == 6) {
            hex = "FF$hex"; // Agregar opacidad 100% si falta
          }
          // Asegurarse de que sea un hex válido
          if (RegExp(r'^[0-9a-fA-F]{8}$').hasMatch(hex)) {
            circleColor = Color(int.parse("0x$hex"));
          } else {
            circleColor = Colors.grey.shade300;
          }
        } catch (e) {
          debugPrint("Error parseando color '${colorFeat.value}': $e");
          circleColor = Colors.grey.shade300; // Color de error visual
        }

        // Detectar si es un color claro para ponerle borde oscuro
        // computeLuminance devuelve entre 0.0 (negro) y 1.0 (blanco)
        final isLightColor = circleColor.computeLuminance() > 0.5;

        return GestureDetector(
          onTap: () => onVariantSelected(v.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: isSelected ? 42 : 36,
            height: isSelected ? 42 : 36,
            padding:
                const EdgeInsets.all(2), // Margen para el borde de selección
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
                border: Border.all(
                  color: Colors.black12, // Borde sutil para todos
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 20,
                      // Si el color es claro, el check debe ser oscuro, y viceversa
                      color: isLightColor ? Colors.black87 : Colors.white,
                    )
                  : null,
            ),
          ),
        );
      }).toList(), // ✅ IMPORTANTE: Convertir a lista
    );
  }
}
