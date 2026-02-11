import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SearchW extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged; // ✅ Callback cuando escribe
  final VoidCallback? onClear; // ✅ Callback cuando limpia

  const SearchW({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  State<SearchW> createState() => _SearchWState();
}

class _SearchWState extends State<SearchW> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    // Escuchar cambios para mostrar/ocultar la X
    widget.controller.addListener(_updateState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) {
      setState(() {
        _hasText = widget.controller.text.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 12.0, right: 3, left: 3),
      decoration: BoxDecoration(
        // Color cambia ligeramente si hay texto
        color: _hasText ? AppColors.tertiaryS : AppColors.primaryS,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightdarkT.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              onChanged: widget.onChanged, // ✅ Conectamos al padre
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                hintStyle: const TextStyle(color: AppColors.semidarkT),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Symbols.search, size: 28, weight: 500),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),

                // ✅ Botón "X" para limpiar
                suffixIcon: _hasText
                    ? IconButton(
                        icon: const Icon(Symbols.close,
                            size: 20, color: Colors.grey),
                        onPressed: () {
                          widget.controller.clear();
                          if (widget.onClear != null) {
                            widget.onClear!();
                          } else if (widget.onChanged != null) {
                            // Si no hay onClear, enviamos vacío al onChanged
                            widget.onChanged!("");
                          }
                        },
                      )
                    : null,
                filled: true,
                fillColor:
                    Colors.transparent, // El color lo maneja el Container
              ),
            ),
          ),
        ],
      ),
    );
  }
}
