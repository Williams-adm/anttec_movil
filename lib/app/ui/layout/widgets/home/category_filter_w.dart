import 'package:flutter/material.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/core/styles/texts.dart';
import 'package:anttec_movil/data/services/api/v1/model/category/category_model.dart';

class CategoryFilterW extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<dynamic> brands;
  final Function(int? categoryId, int? brandId) onFilterChanged;

  const CategoryFilterW({
    super.key,
    required this.categories,
    required this.brands,
    required this.onFilterChanged,
  });

  @override
  State<CategoryFilterW> createState() => _CategoryFilterWState();
}

class _CategoryFilterWState extends State<CategoryFilterW> {
  int? _selectedCategoryId;
  int? _selectedBrandId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. CATEGORÍAS (Scroll Horizontal)
        SizedBox(
          height: 50, // Altura fija para evitar saltos
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = widget.categories[index];
              final isSelected = _selectedCategoryId == category.id;

              return _ModernFilterChip(
                label: category.name,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    // Si ya está seleccionado, lo deseleccionamos (toggle)
                    if (_selectedCategoryId == category.id) {
                      _selectedCategoryId = null;
                      _selectedBrandId = null; // Limpiamos marca también
                    } else {
                      _selectedCategoryId = category.id;
                      _selectedBrandId =
                          null; // Reiniciamos marca al cambiar categoría
                    }
                  });
                  widget.onFilterChanged(_selectedCategoryId, _selectedBrandId);
                },
              );
            },
          ),
        ),

        // 2. MARCAS (Solo visible si hay una categoría seleccionada y hay marcas)
        // Usamos AnimatedSize para que la aparición sea suave
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: (_selectedCategoryId != null && widget.brands.isNotEmpty)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12), // Espacio entre filas
                    SizedBox(
                      height:
                          40, // Altura un poco menor para las marcas (sub-filtro)
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: widget.brands.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final brand = widget.brands[index];
                          // Manejo seguro de ID y Nombre (igual que antes)
                          final dynamic rawId =
                              (brand is Map) ? brand['id'] : brand.id;
                          final dynamic rawName =
                              (brand is Map) ? brand['name'] : brand.name;
                          final int brandId =
                              int.tryParse(rawId.toString()) ?? 0;
                          final String brandName =
                              rawName?.toString() ?? "General";

                          final isSelected = _selectedBrandId == brandId;

                          return _ModernFilterChip(
                            label: brandName,
                            isSelected: isSelected,
                            isSubFilter: true, // Estilo ligeramente diferente
                            onTap: () {
                              setState(() {
                                if (_selectedBrandId == brandId) {
                                  _selectedBrandId = null;
                                } else {
                                  _selectedBrandId = brandId;
                                }
                              });
                              widget.onFilterChanged(
                                  _selectedCategoryId, _selectedBrandId);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(), // Ocupa 0 espacio si no se muestra
        ),
      ],
    );
  }
}

// --- WIDGET PERSONALIZADO PARA EL CHIP ---
class _ModernFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool
      isSubFilter; // Para diferenciar Categoría (Principal) de Marca (Secundario)

  const _ModernFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isSubFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos colores según si es filtro principal o secundario
    final Color activeColor = AppColors.primaryP; // Tu color principal
    final Color inactiveBg = Colors.white;
    final Color inactiveText = Colors.grey[700]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: isSubFilter ? 12 : 16, vertical: isSubFilter ? 6 : 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveBg,
          borderRadius: BorderRadius.circular(30), // Bordes totalmente redondos
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  // Sombra suave cuando está activo
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  // Sombra muy sutil cuando está inactivo
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: isSubFilter
              ? AppTexts.body2M.copyWith(
                  // Estilo más pequeño para marcas
                  color: isSelected ? Colors.white : inactiveText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
                )
              : AppTexts.body1M.copyWith(
                  // Estilo normal para categorías
                  color: isSelected ? Colors.white : inactiveText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
        ),
      ),
    );
  }
}
