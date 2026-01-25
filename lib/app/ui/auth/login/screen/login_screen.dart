import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// Imports de tu proyecto
import 'package:anttec_movil/app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:anttec_movil/app/ui/auth/login/styles/login_styles.dart';
import 'package:anttec_movil/app/ui/auth/login/widgets/email_input_w.dart';
import 'package:anttec_movil/app/ui/auth/login/widgets/password_input_w.dart';
import 'package:anttec_movil/app/ui/auth/login/widgets/login_widgets.dart';
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

  // Controladores
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Bandera para evitar sobrescribir lo que escribe el usuario
  bool _initialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // 1. Escuchar cambios del ViewModel (cuando termine de cargar credenciales)
    widget.viewModel.addListener(_viewModelListener);

    // 2. Intentar llenar inmediatamente (por si los datos ya estaban cargados en el ViewModel)
    _populateControllers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    widget.viewModel.removeListener(_viewModelListener);
    super.dispose();
  }

  void _viewModelListener() {
    // Manejo de errores de Login
    if (widget.viewModel.errorMessage != null && mounted) {
      ErrorDialogW.show(context, widget.viewModel.errorMessage!);
      widget.viewModel.clearErrorMessage();
    }

    // Cada vez que el ViewModel notifique (ej: terminó de leer SharedPreferences), intentamos llenar
    _populateControllers();
  }

  // 🔥 LÓGICA DE RECUÉRDAME (SharedPreferences)
  void _populateControllers() {
    // Si NO hemos llenado los datos aún Y el ViewModel tiene un email guardado...
    if (!_initialDataLoaded && widget.viewModel.savedEmail.isNotEmpty) {
      debugPrint(
          "📝 UI: Escribiendo datos recuperados en los inputs: ${widget.viewModel.savedEmail}");

      _emailController.text = widget.viewModel.savedEmail;
      _passwordController.text = widget.viewModel.savedPassword;

      _initialDataLoaded = true;

      // Forzamos actualización visual para que el texto aparezca inmediatamente
      if (mounted) setState(() {});
    }
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // ⚠️ IMPORTANTE PARA GOOGLE AUTOFILL:
    // NO ocultes el teclado (unfocus) todavía. Si quitas el foco, Android
    // puede pensar que cancelaste el llenado del formulario.
    // FocusScope.of(context).unfocus();

    // Guardamos el estado actual del formulario
    _formKey.currentState?.save();

    final success = await widget.viewModel.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      debugPrint("🚀 Login exitoso. Disparando Autofill Save...");

      // 🔥 ORDEN EXPLÍCITA A ANDROID: "Login exitoso, guarda estos datos"
      TextInput.finishAutofillContext(shouldSave: true);

      // Navegar al Home
      context.goNamed('home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginStyles.backgroundColor,
      body: LoaderW(
        isLoading: widget.viewModel.isLoading,
        child: SafeArea(
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  // 🔥 AutofillGroup conecta Email + Password para Google
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: LoginCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Título
                            Text(
                              "Iniciar Sesión",
                              textAlign: TextAlign.center,
                              style: LoginStyles.pageTitle,
                            ),

                            const SizedBox(height: 30),

                            // Campo Email
                            const LoginInputLabel("Correo Electrónico"),
                            LoginInputContainer(
                              child: EmailInputW(controller: _emailController),
                            ),

                            const SizedBox(height: 20),

                            // Campo Password
                            const LoginInputLabel("Contraseña"),
                            LoginInputContainer(
                              child: PasswordInputW(
                                controller: _passwordController,
                                onFieldSubmitted: _handleLogin,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Checkbox Recuérdame
                            LoginRememberMe(
                              value: widget.viewModel.rememberMe,
                              onChanged: (val) =>
                                  widget.viewModel.toggleRememberMe(val),
                            ),

                            const SizedBox(height: 25),

                            // Botón Ingresar
                            LoginButton(
                              isLoading: widget.viewModel.isLoading,
                              onPressed: _handleLogin,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
