import 'package:flutter/material.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';

class EmailInputW extends StatefulWidget {
  final TextEditingController controller;

  const EmailInputW({super.key, required this.controller});

  @override
  State<EmailInputW> createState() => _EmailInputWState();
}

class _EmailInputWState extends State<EmailInputW> {
  @override
  void initState() {
    super.initState();
    // Escuchamos cambios para que el color de fondo (fillColor) se actualice al escribir o cargar
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
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El correo es obligatorio';
        }
        const pattern =
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
        if (!RegExp(pattern).hasMatch(value)) {
          return 'Formato de correo inválido';
        }
        return null;
      },
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: 'ejemplo@empresa.com',
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
        // ✅ Si hay texto (manual o cargado), se pone azul. Si no, blanco.
        fillColor: widget.controller.text.isNotEmpty
            ? const Color(0xFFE8F0FE)
            : Colors.white,
      ),
    );
  }
}
