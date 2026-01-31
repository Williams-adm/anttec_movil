import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _initialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);
    _populateControllers();

    // 🚀 EFECTO YAPE: Salta si ya está vinculado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoBiometric();
    });
  }

  Future<void> _checkAutoBiometric() async {
    if (widget.viewModel.rememberMe && widget.viewModel.savedEmail.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 600));
      _handleBiometricLogin(isAuto: true);
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
    if (widget.viewModel.errorMessage != null && mounted) {
      ErrorDialogW.show(context, widget.viewModel.errorMessage!);
      widget.viewModel.clearErrorMessage();
    }
    _populateControllers();
  }

  void _populateControllers() {
    if (!_initialDataLoaded && widget.viewModel.savedEmail.isNotEmpty) {
      _emailController.text = widget.viewModel.savedEmail;
      _initialDataLoaded = true;
      if (mounted) setState(() {});
    }
  }

  Future<void> _handleBiometricLogin({bool isAuto = false}) async {
    if (!isAuto && widget.viewModel.savedEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Ingresa tu clave y vincula tu huella primero.")),
      );
      return;
    }

    final success = await widget.viewModel.authenticate();
    if (success && mounted) {
      _emailController.text = widget.viewModel.savedEmail;
      _passwordController.text = widget.viewModel.savedPassword;
      _handleLogin();
    }
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();

    final success = await widget.viewModel.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      TextInput.finishAutofillContext(shouldSave: true);
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
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: LoginCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text("Iniciar Sesión",
                                textAlign: TextAlign.center,
                                style: LoginStyles.pageTitle),
                            const SizedBox(height: 30),
                            const LoginInputLabel("Correo Electrónico"),
                            LoginInputContainer(
                                child:
                                    EmailInputW(controller: _emailController)),
                            const SizedBox(height: 20),
                            const LoginInputLabel("Contraseña"),
                            LoginInputContainer(
                              child: PasswordInputW(
                                controller: _passwordController,
                                onFieldSubmitted: _handleLogin,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // ✅ CORREGIDO: Eliminamos el operador ?? redundante
                            LoginRememberMe(
                              value: widget.viewModel.rememberMe,
                              onChanged: (val) =>
                                  widget.viewModel.toggleRememberMe(val),
                            ),
                            const SizedBox(height: 25),
                            Row(
                              children: [
                                Expanded(
                                  child: LoginButton(
                                    isLoading: widget.viewModel.isLoading,
                                    onPressed: _handleLogin,
                                  ),
                                ),
                                if (widget.viewModel.canCheckBiometrics) ...[
                                  const SizedBox(width: 12),
                                  _buildFingerprintButton(),
                                ]
                              ],
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

  Widget _buildFingerprintButton() {
    return Material(
      color: LoginStyles.buttonColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _handleBiometricLogin(isAuto: false),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: LoginStyles.buttonColor.withValues(alpha: 0.5)),
          ),
          child: const Icon(Icons.fingerprint,
              color: LoginStyles.buttonColor, size: 32),
        ),
      ),
    );
  }
}
