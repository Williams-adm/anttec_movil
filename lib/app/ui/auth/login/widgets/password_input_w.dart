import 'package:flutter/material.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
// Asegúrate de tener esta librería o usa Icons.visibility nativo
import 'package:material_symbols_icons/symbols.dart';

class PasswordInputW extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onFieldSubmitted; // Para dar Enter y entrar

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
      // --- CONFIGURACIÓN PARA GOOGLE AUTOFILL ---
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done, // Botón de "Ir" o "Check"
      autofillHints: const [AutofillHints.password], // 🔥 Clave para Smart Lock
      onFieldSubmitted: (_) => widget.onFieldSubmitted?.call(),
      // ------------------------------------------
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
        fillColor: _hasText ? const Color(0xFFE8F0FE) : Colors.transparent,
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
