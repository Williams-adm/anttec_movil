import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/ui/product/controllers/products_controller.dart';

class ActiveFiltersW extends StatelessWidget {
  const ActiveFiltersW({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos al controlador
    final controller = context.watch<ProductsController>();

    // Lista de chips a mostrar
    final List<Widget> activeChips = [];

    // 1. Chip de Rango de Precio
    if (controller.currentMinPrice != null ||
        controller.currentMaxPrice != null) {
      final min = controller.currentMinPrice?.round() ?? 0;
      final max = controller.currentMaxPrice?.round() ?? "∞";
      activeChips.add(_buildChip(
        label: "Precio: S/ $min - $max",
        onDeleted: () {
          // Mantenemos el resto, borramos precio
          controller.applyAdvancedFilters(
            brand: controller.currentBrand,
            category: controller.currentCategory,
            subcategory: controller.currentSubcategory,
            orderBy: controller.currentOrderBy,
            orderDir: controller.currentOrderDir,
            minPrice: null, // Borrar
            maxPrice: null, // Borrar
          );
        },
      ));
    }

    // 2. Chip de Ordenamiento
    if (controller.currentOrderBy != null) {
      String label = "Ordenado";
      if (controller.currentOrderBy == 'price') {
        label = controller.currentOrderDir == 'asc'
            ? "Menor Precio"
            : "Mayor Precio";
      } else if (controller.currentOrderBy == 'name') {
        label = "Nombre (A-Z)";
      }

      activeChips.add(_buildChip(
        label: label,
        onDeleted: () {
          controller.applyAdvancedFilters(
            brand: controller.currentBrand,
            category: controller.currentCategory,
            subcategory: controller.currentSubcategory,
            minPrice: controller.currentMinPrice,
            maxPrice: controller.currentMaxPrice,
            orderBy: null, // Borrar
            orderDir: null, // Borrar
          );
        },
      ));
    }

    // 3. Chip de Marca
    if (controller.currentBrand != null) {
      // Como solo tenemos el ID en el controller, mostramos un texto genérico
      // O idealmente pasaríamos el nombre si lo tuviéramos.
      activeChips.add(_buildChip(
        label: "Marca Seleccionada",
        onDeleted: () {
          controller.applyAdvancedFilters(
            category: controller.currentCategory,
            subcategory: controller.currentSubcategory,
            minPrice: controller.currentMinPrice,
            maxPrice: controller.currentMaxPrice,
            orderBy: controller.currentOrderBy,
            orderDir: controller.currentOrderDir,
            brand: null, // Borrar
          );
        },
      ));
    }

    // 4. Chip de Categoría (Opcional, si quieres permitir borrarla desde aquí)
    if (controller.currentCategory != null) {
      activeChips.add(_buildChip(
        label: "Categoría",
        onDeleted: () {
          controller.applyAdvancedFilters(
            brand: controller.currentBrand,
            minPrice: controller.currentMinPrice,
            maxPrice: controller.currentMaxPrice,
            orderBy: controller.currentOrderBy,
            orderDir: controller.currentOrderDir,
            category: null, // Borrar
          );
        },
      ));
    }

    // Si no hay filtros, no mostramos nada
    if (activeChips.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Botón "Borrar Todo"
                InkWell(
                  onTap: () => controller.clearFilters(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Symbols.close, size: 16, color: Colors.red),
                        SizedBox(width: 4),
                        Text(
                          "Borrar",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Resto de chips
                ...activeChips.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: c,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({required String label, required VoidCallback onDeleted}) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: AppColors.primaryP,
      deleteIcon: const Icon(Symbols.close, size: 16, color: Colors.white),
      onDeleted: onDeleted,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}
