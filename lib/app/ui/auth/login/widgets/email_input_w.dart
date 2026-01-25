import 'package:flutter/material.dart';
// Si tienes colores personalizados, mantén tu import.
// Si no, puedes usar Colors.blue o el que prefieras directamente.
import 'package:anttec_movil/app/core/styles/colors.dart';

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
      // --- CONFIGURACIÓN PARA GOOGLE AUTOFILL ---
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email], // 🔥 Clave para Smart Lock
      // ------------------------------------------
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El correo es obligatorio';
        }
        // Regex robusto para email
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
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        // Bordes suaves y redondeados
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide
              .none, // Quitamos borde por defecto si usas container externo
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
        // Color de fondo dinámico (opcional, ajusta según tu gusto)
        fillColor: _hasText ? const Color(0xFFE8F0FE) : Colors.transparent,
      ),
    );
  }
}
