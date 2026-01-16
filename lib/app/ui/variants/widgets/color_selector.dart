import 'package:flutter/material.dart';
// Importamos el modelo que me acabas de pasar
import 'package:anttec_movil/data/services/api/v1/model/product/product_detail_response.dart';

class ColorSelector extends StatelessWidget {
  // Cambiado de Variant a VariantOption según tu modelo
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Color",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: variants.map((v) {
            final isSelected = v.id == selectedId;

            // Buscamos la característica de tipo 'color'
            // Usamos .firstWhere de forma segura
            final colorFeat = v.features.firstWhere(
              (f) => f.type == 'color',
              orElse: () => Feature(
                id: 0,
                option: '',
                type: '',
                value: '#cccccc', // Gris por defecto si no hay color
                description: '',
              ),
            );

            // Convertimos el hex (#ffffff) a formato Flutter (0xffffffff)
            final colorHex = colorFeat.value.replaceAll('#', '0xff');
            final colorInt = int.tryParse(colorHex);

            return GestureDetector(
              onTap: () => onVariantSelected(v.id),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorInt != null ? Color(colorInt) : Colors.grey,
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.black12,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 20,
                        // Si el círculo es blanco, el check debe ser negro
                        color: colorHex == '0xffffffff'
                            ? Colors.black
                            : Colors.white,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
