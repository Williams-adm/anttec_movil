import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/core/styles/texts.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:anttec_movil/app/ui/brand/brand_page.dart';

class SectionTitleW extends StatelessWidget {
  final String title;
  final VoidCallback? onFilterTap;

  const SectionTitleW({
    super.key,
    this.title = "Productos",
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🟦 Título con más peso visual
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTexts.body1M.copyWith(
                  color: AppColors.extradarkT,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 3,
                width: 25,
                decoration: BoxDecoration(
                  color: AppColors.primaryP,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            ],
          ),

          // 🟨 Botón de filtros estilo "Cápsula"
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BrandPage()),
              );
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    // ✅ CORREGIDO: .withValues(alpha: ...)
                    color: AppColors.secondaryS.withValues(alpha: 0.5),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                    // ✅ CORREGIDO: .withValues(alpha: ...)
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    "Filtros",
                    style: AppTexts.body1M.copyWith(
                      color: AppColors.darkT,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      // ✅ CORREGIDO: .withValues(alpha: ...)
                      color: AppColors.secondaryS.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Symbols.tune,
                      size: 16,
                      color: AppColors.darkT,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
