import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:anttec_movil/app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:anttec_movil/app/ui/auth/login/widgets/email_input_w.dart';
import 'package:anttec_movil/app/ui/auth/login/widgets/password_input_w.dart';
import 'package:anttec_movil/app/ui/auth/login/widgets/login_widgets.dart';
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
    // Escuchamos al ViewModel para reaccionar cuando cargue datos de SecureStorage
    widget.viewModel.addListener(_populateControllers);
    _populateControllers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    widget.viewModel.removeListener(_populateControllers);
    super.dispose();
  }

  void _populateControllers() {
    // Si el ViewModel tiene datos y los controladores están vacíos, rellenamos
    if (widget.viewModel.savedEmail.isNotEmpty &&
        _emailController.text.isEmpty) {
      // Usamos WidgetsBinding para asegurar que la UI ya terminó de procesar el frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _emailController.text = widget.viewModel.savedEmail;
            _passwordController.text = widget.viewModel.savedPassword;
          });
          debugPrint("🚀 UI: Campos rellenados con éxito");
        }
      });
    }
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();

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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return LoaderW(
              isLoading: widget.viewModel.isLoading,
              child: SingleChildScrollView(
                child: SizedBox(
                  height: size.height,
                  child: Stack(
                    children: [
                      // HEADER MORADO
                      Container(
                        width: double.infinity,
                        height: size.height * 0.45,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF5E1674), Color(0xFF4A115B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: size.height * 0.04),
                            child: Image.asset(
                              'assets/img/logo.png',
                              height: 220,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // TARJETA DE LOGIN
                      Positioned(
                        top: size.height * 0.28,
                        left: 20,
                        right: 20,
                        child: AutofillGroup(
                          child: Form(
                            key: _formKey,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "Iniciar Sesión",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  const LoginInputLabel("Correo Electrónico"),
                                  const SizedBox(height: 8),
                                  EmailInputW(controller: _emailController),
                                  const SizedBox(height: 20),
                                  const LoginInputLabel("Contraseña"),
                                  const SizedBox(height: 8),
                                  PasswordInputW(
                                    controller: _passwordController,
                                    onFieldSubmitted: _handleLogin,
                                  ),
                                  const SizedBox(height: 15),
                                  // CHECKBOX RECUÉRDAME
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LoginRememberMe(
                                        value: widget.viewModel.rememberMe,
                                        onChanged: (val) {
                                          // ✅ CORRECCIÓN: Se elimina el ?? false que causaba el error
                                          widget.viewModel
                                              .toggleRememberMe(val == true);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
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
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
