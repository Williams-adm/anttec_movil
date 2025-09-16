import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class PasswordInputW extends StatefulWidget {
  final TextEditingController controller;

  const PasswordInputW({super.key, required this.controller});

  @override
  State<PasswordInputW> createState() => _PasswordInputWState();
}

class _PasswordInputWState extends State<PasswordInputW> {
  bool _hasText = false;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Contraseña requerida';
        }
        if (value.length < 8) {
          return 'La contraseña debe tener al menos 8 caracteres';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: '**********',
        hintStyle: TextStyle(color: AppColors.semidarkT),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        filled: true,
        fillColor: _hasText ? AppColors.tertiaryS : Colors.transparent,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
          icon: Icon(_obscure ? Symbols.visibility_off : Symbols.visibility),
        ),
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
