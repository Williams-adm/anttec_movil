import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:flutter/material.dart';

class EmailInputW extends StatefulWidget {
  final TextEditingController controller;

  const EmailInputW({super.key, required this.controller});

  @override
  State<EmailInputW> createState() => _EmailInputWState();
}

class _EmailInputWState extends State<EmailInputW> {
  bool _hasText = false;

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

  // Optimización: Solo redibuja si el estado realmente cambia
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
      // --- UX MODERNA ---
      keyboardType: TextInputType.emailAddress, // Muestra el '@' en el teclado
      textInputAction: TextInputAction.next, // Muestra botón "Siguiente"
      autofillHints: const [
        AutofillHints.email,
      ], // Permite autocompletar del sistema
      // ------------------
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El correo es obligatorio';
        }
        // Regex optimizado para email
        const pattern =
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
        final regExp = RegExp(pattern);

        if (!regExp.hasMatch(value)) {
          return 'Formato de correo inválido';
        }
        return null;
      },
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: 'ejemplo@empresa.com',
        hintStyle: const TextStyle(color: AppColors.semidarkT),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primaryP, width: 2),
        ),
        filled: true,
        // Color cambia dinámicamente según si hay texto
        fillColor: _hasText ? AppColors.tertiaryS : Colors.grey.shade50,
      ),
    );
  }
}
