import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/core/styles/texts.dart';
import 'package:anttec_movil/data/services/api/v1/model/category/category_model.dart';
import 'package:flutter/material.dart';

class CategoryFilterW extends StatefulWidget {
  final List<CategoryModel> categories;

  const CategoryFilterW({super.key, required this.categories});
  @override
  State<CategoryFilterW> createState() => _CategoryFilterWState();
}

class _CategoryFilterWState extends State<CategoryFilterW> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < widget.categories.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: ChipTheme(
                  data: ChipTheme.of(context).copyWith(
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Cambia aquí el radio
                    ),
                  ),
                  child: ChoiceChip(
                    label: Text(widget.categories[i].name),
                    selected: _selectedIndex == i,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedIndex = selected ? i : null;
                      });
                    },
                    selectedColor: AppColors.secondaryP,
                    backgroundColor: AppColors.secondaryS,
                    side: BorderSide(color: Colors.transparent),
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
    );
  }
}
