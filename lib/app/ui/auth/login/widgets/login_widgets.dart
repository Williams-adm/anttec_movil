import 'package:flutter/material.dart';
import 'package:anttec_movil/app/ui/auth/login/styles/login_styles.dart';

// 1. LA TARJETA BLANCA (CONTENEDOR)
class LoginCard extends StatelessWidget {
  final Widget child;
  const LoginCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: LoginStyles.cardDecoration,
      child: child,
    );
  }
}

// 2. EL LABEL (TEXTO ARRIBA DEL INPUT)
class LoginInputLabel extends StatelessWidget {
  final String label;
  const LoginInputLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(label, style: LoginStyles.inputLabel),
    );
  }
}

// 3. CONTAINER GRIS PARA LOS INPUTS
class LoginInputContainer extends StatelessWidget {
  final Widget child;
  const LoginInputContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LoginStyles.inputContainerDecoration,
      child: child,
    );
  }
}

// 4. EL CHECKBOX "RECUÉRDAME"
class LoginRememberMe extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const LoginRememberMe({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Recuérdame", style: LoginStyles.rememberMeText),
        const SizedBox(width: 8),
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: (val) => onChanged(val!),
            activeColor: LoginStyles.textColor,
            side: const BorderSide(color: LoginStyles.textColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}

// 5. EL BOTÓN MORADO
class LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const LoginButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: LoginStyles.buttonColor,
          disabledBackgroundColor:
              LoginStyles.buttonColor.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text("INGRESAR", style: LoginStyles.buttonText),
      ),
    );
  }
}
