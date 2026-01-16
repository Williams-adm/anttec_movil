import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/core/styles/texts.dart';
import 'package:anttec_movil/app/core/styles/titles.dart';
import 'package:anttec_movil/app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:anttec_movil/app/ui/auth/login/widgets/card_login_w.dart';
import 'package:anttec_movil/app/ui/auth/login/widgets/email_input_w.dart';
import 'package:anttec_movil/app/ui/auth/login/widgets/password_input_w.dart';
import 'package:anttec_movil/app/ui/shared/widgets/error_dialog_w.dart';
import 'package:anttec_movil/app/ui/shared/widgets/loader_w.dart';

class LoginScreen extends StatefulWidget {
  final LoginViewModel viewModel;
  const LoginScreen({super.key, required this.viewModel});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Escuchar cambios en el ViewModel (errores, estados de carga)
    widget.viewModel.addListener(_viewModelListener);

    // LOGICA DE "RECUÉRDAME":
    // Si al iniciar la pantalla el ViewModel ya recuperó un correo, lo ponemos.
    if (widget.viewModel.savedEmail.isNotEmpty) {
      _emailController.text = widget.viewModel.savedEmail;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    widget.viewModel.removeListener(_viewModelListener);
    super.dispose();
  }

  void _viewModelListener() {
    // 1. Manejo de errores
    if (widget.viewModel.errorMessage != null && mounted) {
      ErrorDialogW.show(context, widget.viewModel.errorMessage!);
      widget.viewModel.clearErrorMessage();
    }

    // 2. Actualización tardía del email (si la carga fue asíncrona)
    if (widget.viewModel.savedEmail.isNotEmpty &&
        _emailController.text.isEmpty &&
        mounted) {
      _emailController.text = widget.viewModel.savedEmail;
    }
  }

  Future<void> _handleLogin() async {
    // Validación del formulario (Frontend)
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Ocultar teclado para mejor experiencia visual
    FocusScope.of(context).unfocus();

    final success = await widget.viewModel.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      context.goNamed('home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoaderW(
        isLoading: widget.viewModel.isLoading,
        child: SafeArea(
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // Icono de la marca
                    const Icon(
                      Icons.lock_person_rounded,
                      size: 80,
                      color: AppColors.primaryP,
                    ),
                    const SizedBox(height: 20),
                    Text("¡Bienvenido!", style: AppTitles.login),
                    Text(
                      "Ingresa tus credenciales para continuar",
                      style: AppTexts.body1.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 40),

                    CardLoginW(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildInputLabel("Correo Electrónico"),
                              EmailInputW(controller: _emailController),
                              const SizedBox(height: 20),
                              _buildInputLabel("Contraseña"),
                              PasswordInputW(controller: _passwordController),
                              const SizedBox(height: 10),
                              _buildRememberMe(),
                              const SizedBox(height: 30),
                              _buildSubmitButton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- Widgets Auxiliares Privados ---

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: AppTitles.h3),
    );
  }

  Widget _buildRememberMe() {
    return InkWell(
      onTap: () =>
          widget.viewModel.toggleRememberMe(!widget.viewModel.rememberMe),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: widget.viewModel.rememberMe,
            // CORRECCIÓN: 'val!' asegura que no sea nulo, eliminando el error del linter
            onChanged: (val) => widget.viewModel.toggleRememberMe(val!),
            activeColor: AppColors.primaryP,
          ),
          Text("Recuérdame", style: AppTexts.body1),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool isBusy = widget.viewModel.isLoading;

    return ElevatedButton(
      // Deshabilitamos el botón si está cargando
      onPressed: isBusy ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryP,
        // CORRECCIÓN: Usamos .withValues() (el nuevo estándar) en lugar de .withOpacity()
        disabledBackgroundColor: AppColors.primaryP.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 2,
      ),
      child: isBusy
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              "INGRESAR",
              style: AppTitles.h1.copyWith(
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
    );
  }
}
