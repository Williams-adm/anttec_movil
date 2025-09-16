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
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El correo es obligatorio';
        }
        // Expresión regular para validar un email
        const pattern =
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})+$";
        final regExp = RegExp(pattern);

        if (!regExp.hasMatch(value)) {
          return 'Correo inválido';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'vendedor@empresa.com',
        hintStyle: TextStyle(color: AppColors.semidarkT),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        fillColor: _hasText ? AppColors.tertiaryS : Colors.transparent,
        filled: true,
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
