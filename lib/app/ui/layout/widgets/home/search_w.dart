import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SearchW extends StatefulWidget {
  final TextEditingController controller;
  const SearchW({super.key, required this.controller});

  @override
  State<SearchW> createState() => _SearchWState();
}

class _SearchWState extends State<SearchW> {
  bool _hasText = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 12.0, right: 3, left: 3),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.lightdarkT,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: 'Buscar productos',
                hintStyle: TextStyle(color: AppColors.semidarkT),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Icon(Symbols.search, size: 30, weight: 500),
                filled: true,
                fillColor: _hasText ? AppColors.tertiaryS : AppColors.primaryS,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateColor);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateColor);
  }

  void _updateColor() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });
  }
}
