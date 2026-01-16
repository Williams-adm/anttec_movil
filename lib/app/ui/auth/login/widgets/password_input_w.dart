import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class PasswordInputW extends StatefulWidget {
  final TextEditingController controller;
  // Opcional: Permite ejecutar la acción de login al dar Enter en el teclado
  final VoidCallback? onFieldSubmitted;

  const PasswordInputW({
    super.key,
    required this.controller,
    this.onFieldSubmitted,
  });

  @override
  State<PasswordInputW> createState() => _PasswordInputWState();
}

class _PasswordInputWState extends State<PasswordInputW> {
  bool _hasText = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_updateColor);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateColor);
    super.dispose();
  }

  void _updateColor() {
    final hasTextNow = widget.controller.text.isNotEmpty;
    if (_hasText != hasTextNow) {
      setState(() {
        _hasText = hasTextNow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      // --- UX MODERNA ---
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done, // Muestra botón "Check/Ir"
      autofillHints: const [
        AutofillHints.password,
      ], // Integración con gestor de contraseñas
      onFieldSubmitted: (_) => widget.onFieldSubmitted?.call(),
      // ------------------
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'La contraseña es requerida';
        }
        if (value.length < 6) {
          // Ajustado a estándar común (6 u 8)
          return 'Mínimo 6 caracteres';
        }
        return null;
      },
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: const TextStyle(color: AppColors.semidarkT),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primaryP, width: 2),
        ),
        filled: true,
        fillColor: _hasText ? AppColors.tertiaryS : Colors.grey.shade50,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
          // Color sutil para el icono
          icon: Icon(
            _obscure ? Symbols.visibility_off : Symbols.visibility,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
