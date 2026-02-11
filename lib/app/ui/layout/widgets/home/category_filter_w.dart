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
      crossAxisAlignment:
          CrossAxisAlignment.center, // Centra los hijos en la columna
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. CATEGORÍAS
        SizedBox(
          height: 50,
          child: Center(
            // Envolvemos en Center para cuando los items son pocos
            child: ListView.separated(
              shrinkWrap: true, // Importante: ajusta el ancho al contenido
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
                      if (_selectedCategoryId == category.id) {
                        _selectedCategoryId = null;
                        _selectedBrandId = null;
                      } else {
                        _selectedCategoryId = category.id;
                        _selectedBrandId = null;
                      }
                    });
                    widget.onFilterChanged(
                        _selectedCategoryId, _selectedBrandId);
                  },
                );
              },
            ),
          ),
        ),

        // 2. MARCAS
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: (_selectedCategoryId != null && widget.brands.isNotEmpty)
              ? Column(
                  children: [
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: Center(
                        // Centra la lista de marcas
                        child: ListView.separated(
                          shrinkWrap:
                              true, // Ajusta el ancho para que Center funcione
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: widget.brands.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final brand = widget.brands[index];
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
                              isSubFilter: true,
                              onTap: () {
                                setState(() {
                                  _selectedBrandId =
                                      (_selectedBrandId == brandId)
                                          ? null
                                          : brandId;
                                });
                                widget.onFilterChanged(
                                    _selectedCategoryId, _selectedBrandId);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ModernFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSubFilter;

  const _ModernFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isSubFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppColors.primaryP;
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
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: isSubFilter
              ? AppTexts.body2M.copyWith(
                  color: isSelected ? Colors.white : inactiveText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
                )
              : AppTexts.body1M.copyWith(
                  color: isSelected ? Colors.white : inactiveText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
        ),
      ),
    );
  }
}
