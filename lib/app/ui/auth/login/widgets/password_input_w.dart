import 'package:flutter/material.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:material_symbols_icons/symbols.dart';

class PasswordInputW extends StatefulWidget {
  final TextEditingController controller;
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
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    // Escuchamos el controlador para actualizar el estado visual (fillColor)
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      onFieldSubmitted: (_) => widget.onFieldSubmitted?.call(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'La contraseña es requerida';
        }
        if (value.length < 6) {
          return 'Mínimo 6 caracteres';
        }
        return null;
      },
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primaryP, width: 2),
        ),
        filled: true,
        // ✅ Sincronización de color corregida
        fillColor: widget.controller.text.isNotEmpty
            ? const Color(0xFFE8F0FE)
            : Colors.white,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
          icon: Icon(
            _obscure ? Symbols.visibility_off : Symbols.visibility,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
