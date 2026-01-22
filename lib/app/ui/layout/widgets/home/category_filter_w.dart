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
        // 1. CATEGORÍAS
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            children: widget.categories.map((category) {
              final isSelected = _selectedCategoryId == category.id;
              return Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: ChoiceChip(
                  label: Text(category.name),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: AppColors.secondaryP,
                  backgroundColor: AppColors.secondaryS,
                  side: const BorderSide(color: Colors.transparent),
                  labelStyle: AppTexts.body2M.copyWith(
                    color: isSelected ? AppColors.primaryS : AppColors.darkT,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedCategoryId = selected ? category.id : null;
                      _selectedBrandId =
                          null; // Reiniciar marca al cambiar categoría
                    });
                    widget.onFilterChanged(
                      _selectedCategoryId,
                      _selectedBrandId,
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // 2. MARCAS (SOLO SI HAY CATEGORÍA)
        if (_selectedCategoryId != null && widget.brands.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              "Filtrar por Marca:",
              style: AppTexts.body2M.copyWith(color: Colors.grey, fontSize: 12),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              children: widget.brands.map((brand) {
                // 🔥 CORRECCIÓN CRÍTICA: Manejo seguro de ID y Nombre
                final dynamic rawId = (brand is Map) ? brand['id'] : brand.id;
                final dynamic rawName = (brand is Map)
                    ? brand['name']
                    : brand.name;

                final int brandId = int.tryParse(rawId.toString()) ?? 0;
                final String brandName = rawName?.toString() ?? "General";

                final isSelected = _selectedBrandId == brandId;

                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: ChoiceChip(
                    label: Text(brandName),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: const Color(0xFFE0E0E0),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.shade300,
                    ),
                    labelStyle: AppTexts.body2M.copyWith(
                      color: isSelected ? Colors.black : Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedBrandId = selected ? brandId : null;
                      });
                      widget.onFilterChanged(
                        _selectedCategoryId,
                        _selectedBrandId,
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
