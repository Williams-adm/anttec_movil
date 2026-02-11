import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SearchW extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final VoidCallback? onClear;

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
  // Para controlar el foco (cambio de color al tocar)
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;

    // Listeners
    widget.controller.addListener(_updateTextState);
    _focusNode.addListener(_updateFocusState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateTextState);
    _focusNode.removeListener(_updateFocusState);
    _focusNode.dispose();
    super.dispose();
  }

  void _updateTextState() {
    if (mounted) {
      setState(() {
        _hasText = widget.controller.text.isNotEmpty;
      });
    }
  }

  void _updateFocusState() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definimos colores según estado
    final borderColor =
        _isFocused ? AppColors.primaryP : Colors.grey.withValues(alpha: 0.2);
    final bgColor = _isFocused
        ? Colors.white
        : const Color(0xFFF5F5F5); // Gris muy suave si no está en foco

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30.0), // Cápsula
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: _isFocused
            ? [
                // Sombra suave solo cuando está enfocado
                BoxShadow(
                  color: AppColors.primaryP.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: TextField(
        // Usamos TextField directo para más control visual
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        cursorColor: AppColors.primaryP,
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
          border: InputBorder.none, // Quitamos borde default
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),

          // LUPA (Izquierda)
          prefixIcon: Icon(
            Symbols.search,
            size: 24,
            color: _isFocused ? AppColors.primaryP : Colors.grey[600],
          ),

          // BOTÓN "X" (Derecha) - Animado
          suffixIcon: AnimatedOpacity(
            opacity: _hasText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: _hasText
                ? IconButton(
                    splashRadius: 20, // Efecto splash pequeño
                    icon: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // Fondo circular gris
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Symbols.close,
                          size: 14, color: Colors.white),
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      // Quitamos foco al limpiar para que se vea la animación de salida
                      _focusNode.unfocus();
                      if (widget.onClear != null) {
                        widget.onClear!();
                      } else if (widget.onChanged != null) {
                        widget.onChanged!("");
                      }
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
