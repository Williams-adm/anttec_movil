import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:anttec_movil/app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:anttec_movil/app/ui/auth/login/widgets/email_input_w.dart';
import 'package:anttec_movil/app/ui/auth/login/widgets/password_input_w.dart';
import 'package:anttec_movil/app/ui/auth/login/widgets/login_widgets.dart';
import 'package:anttec_movil/app/ui/shared/widgets/loader_w.dart';
import 'package:anttec_movil/app/ui/cart/controllers/cart_provider.dart';

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
    widget.viewModel.addListener(_populateFields);
    _populateFields();
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_populateFields);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _populateFields() {
    if (_emailController.text.isEmpty &&
        widget.viewModel.savedEmail.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _emailController.text = widget.viewModel.savedEmail;
            _passwordController.text = widget.viewModel.savedPassword;
          });
        }
      });
    }
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await widget.viewModel.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      context.read<CartProvider>().fetchCart(silent: true);
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
                      _buildHeader(size),
                      _buildLoginForm(size),
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

  // ✅ AQUÍ ESTÁ EL CAMBIO PARA SUBIR EL LOGO
  Widget _buildHeader(Size size) {
    return Container(
      width: double.infinity,
      height: size.height * 0.45,
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xFF5E1674), Color(0xFF4A115B)]),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Padding(
        // padding top: 8% de la altura de la pantalla (más cerca del borde superior)
        padding: EdgeInsets.only(top: size.height * 0.08),
        child: Align(
          alignment:
              Alignment.topCenter, // Alineamos arriba en lugar de centrar
          child: Image.asset(
            'assets/img/logo.png',
            height: 200, // Ajusté ligeramente el tamaño para que encaje mejor
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(Size size) {
    return Positioned(
      top: size.height * 0.28,
      left: 20,
      right: 20,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              children: [
                const Text("Iniciar Sesión",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 30),
                EmailInputW(controller: _emailController),
                const SizedBox(height: 20),
                PasswordInputW(
                    controller: _passwordController,
                    onFieldSubmitted: _handleLogin),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoginRememberMe(
                      value: widget.viewModel.rememberMe,
                      onChanged: (val) {
                        widget.viewModel.toggleRememberMe(val == true);
                      },
                    ),
                  ],
                ),

                // Mensaje de Error (Rojo)
                if (widget.viewModel.errorMessage != null) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.viewModel.errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 30),
                LoginButton(
                    isLoading: widget.viewModel.isLoading,
                    onPressed: _handleLogin),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
