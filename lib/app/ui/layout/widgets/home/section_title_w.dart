import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/core/styles/texts.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SectionTitleW extends StatelessWidget {
  final String title;

  const SectionTitleW({super.key, this.title = "Productos"});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTexts.body1M.copyWith(color: AppColors.extradarkT),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryS,
              padding: EdgeInsets.only(left: 12.0, right: 6.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Row(
              children: [
                Text(
                  "Filtros",
                  style: AppTexts.body1M.copyWith(color: AppColors.darkT),
                ),
                SizedBox(width: 8.0),
                Icon(Symbols.filter_alt, size: 24, color: AppColors.darkT),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
