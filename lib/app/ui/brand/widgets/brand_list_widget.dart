import 'package:flutter/material.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/core/styles/texts.dart';

class BrandListWidget extends StatelessWidget {
  final List<dynamic> brands;

  const BrandListWidget({super.key, required this.brands});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: brands.length,
        // Misma separación que en categorías
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final brand = brands[index];

          return ChipTheme(
            data: ChipTheme.of(context).copyWith(
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  10,
                ), // Radio 10 igual a categorías
              ),
            ),
            child: ActionChip(
              label: Text(brand['name'] ?? 'Sin nombre'),
              onPressed: () {},
              // --- ESTILOS IGUALES A CATEGORÍAS ---
              backgroundColor: AppColors.secondaryS,
              side: const BorderSide(color: Colors.transparent),
              labelStyle: AppTexts.body2M.copyWith(color: AppColors.darkT),
              pressElevation: 0,
            ),
          );
        },
      ),
    );
  }
}
