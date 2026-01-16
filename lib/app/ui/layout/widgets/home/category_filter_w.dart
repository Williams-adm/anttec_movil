import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/core/styles/texts.dart';
import 'package:anttec_movil/app/ui/brand/widgets/brand_list_widget.dart'; // Tu widget de lista de marcas
import 'package:anttec_movil/data/services/api/v1/model/category/category_model.dart';
import 'package:flutter/material.dart';

class CategoryFilterW extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<dynamic> brands; // Recibimos las marcas aquí

  const CategoryFilterW({
    super.key,
    required this.categories,
    required this.brands,
  });

  @override
  State<CategoryFilterW> createState() => _CategoryFilterWState();
}

class _CategoryFilterWState extends State<CategoryFilterW> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- 1. LISTA HORIZONTAL DE CATEGORÍAS (CHIPS) ---
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          // Un poco de padding abajo para separar de las marcas
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            children: [
              for (int i = 0; i < widget.categories.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: ChipTheme(
                    data: ChipTheme.of(context).copyWith(
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: ChoiceChip(
                      label: Text(widget.categories[i].name),
                      selected: _selectedIndex == i,
                      onSelected: (bool selected) {
                        setState(() {
                          // Si tocas el que ya está seleccionado, se desmarca (null).
                          // Si tocas uno nuevo, se marca ese índice (i).
                          _selectedIndex = selected ? i : null;
                        });
                      },
                      selectedColor: AppColors.secondaryP,
                      backgroundColor: AppColors.secondaryS,
                      side: const BorderSide(color: Colors.transparent),
                      labelStyle: AppTexts.body2M.copyWith(
                        color: _selectedIndex == i
                            ? AppColors.primaryS
                            : AppColors.darkT,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // --- 2. LISTA DE MARCAS (Se muestra solo si hay selección) ---
        if (_selectedIndex != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              "Marcas disponibles:", // Opcional: Título pequeño
              style: AppTexts.body2M.copyWith(color: Colors.grey, fontSize: 12),
            ),
          ),

          // Aquí reutilizamos tu widget que ya tiene el ListView horizontal y botones
          BrandListWidget(brands: widget.brands),

          // Un espacio extra al final para que no pegue con lo siguiente
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
