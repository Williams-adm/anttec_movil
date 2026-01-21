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
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: variants.map((v) {
        final isSelected = v.id == selectedId;

        // Buscamos la característica de tipo 'color'
        final colorFeat = v.features.firstWhere(
          (f) => f.type == 'color',
          orElse: () => Feature(
            id: 0,
            option: '',
            type: '',
            value: '#cccccc',
            description: '',
          ),
        );

        // Lógica de conversión de Hex a Int
        String hexString = colorFeat.value.replaceAll('#', '');

        // ✅ CORRECCIÓN: Agregamos las llaves { } al bloque if
        if (hexString.length == 6) {
          hexString = "ff$hexString";
        }

        final colorInt = int.tryParse("0x$hexString");

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
                    color: (hexString.toLowerCase().endsWith('ffffff'))
                        ? Colors.black
                        : Colors.white,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
