import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';

// Estilos
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/core/styles/texts.dart';

// Controlador y Modal
import 'package:anttec_movil/app/ui/product/controllers/products_controller.dart';
// ⚠️ Asegúrate de importar el modal correctamente
import 'package:anttec_movil/app/ui/layout/widgets/home/advanced_filter_modal.dart';

class SectionTitleW extends StatelessWidget {
  final String title;

  const SectionTitleW({
    super.key,
    this.title = "Productos",
  });

  @override
  Widget build(BuildContext context) {
    // Obtenemos el controlador para leer los filtros actuales (usamos watch para reaccionar a cambios)
    final controller = context.watch<ProductsController>();

    // Detectamos si hay filtros activos para cambiar el estilo del botón
    final bool hasActiveFilters = controller.currentBrand != null ||
        controller.currentCategory != null ||
        controller.currentMinPrice != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🟦 Título de la Sección
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

          // 🟨 Botón de Filtros (Abre AdvancedFilterModal)
          InkWell(
            onTap: () async {
              // 1. Mostrar el Modal Bottom Sheet
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true, // Permite que el modal sea alto
                backgroundColor: Colors
                    .transparent, // Transparente para ver bordes redondeados
                builder: (context) => AdvancedFilterModal(
                  // Pasamos los valores actuales para mantener el estado
                  selectedBrand: controller.currentBrand,
                  selectedCategory: controller.currentCategory,
                  minPrice: controller.currentMinPrice,
                  maxPrice: controller.currentMaxPrice,
                  orderBy: controller.currentOrderBy,
                  orderDir: controller.currentOrderDir,
                ),
              );

              // 2. Si el usuario aplicó cambios (result != null), actualizamos el controlador
              if (result != null) {
                controller.applyAdvancedFilters(
                  brand: result['brand'],
                  category: result['category'],
                  minPrice: result['minPrice'],
                  maxPrice: result['maxPrice'],
                  orderBy: result['orderBy'],
                  orderDir: result['orderDir'],
                );
              }
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                // Si hay filtros activos, el fondo es un tono suave del color primario
                color: hasActiveFilters
                    ? AppColors.primaryP.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  // Si hay filtros activos, el borde es del color primario
                  color: hasActiveFilters
                      ? AppColors.primaryP
                      : AppColors.secondaryS.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
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
                      // Texto cambia de color si está activo
                      color: hasActiveFilters
                          ? AppColors.primaryP
                          : AppColors.darkT,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: hasActiveFilters
                          ? AppColors.primaryP
                          : AppColors.secondaryS.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Symbols.tune,
                      size: 16,
                      // Icono cambia a blanco si el fondo del círculo es oscuro (primario)
                      color: hasActiveFilters ? Colors.white : AppColors.darkT,
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
