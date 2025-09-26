import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/core/styles/texts.dart';
import 'package:anttec_movil/app/core/styles/titles.dart';
import 'package:anttec_movil/app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:anttec_movil/app/ui/auth/login/widgets/card_login_w.dart';
import 'package:anttec_movil/app/ui/auth/login/widgets/email_input_w.dart';
import 'package:anttec_movil/app/ui/auth/login/widgets/password_input_w.dart';
import 'package:anttec_movil/app/ui/shared/widgets/error_dialog_w.dart';
import 'package:anttec_movil/app/ui/shared/widgets/loader_w.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  final LoginViewmodel viewModel;

  const LoginScreen({super.key, required this.viewModel});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return LoaderW(
              isLoading: widget.viewModel.isloading,
              child: Center(
                child: CardLoginW(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      alignment: Alignment.center,
                      child: Text("Iniciar Sesión", style: AppTitles.login),
                    ),
                    Form(
                      //falta agregar validaciones nivel frontend como que sea de tipo email, cantidad de letras, etc
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Correo Electrónico", style: AppTitles.h3),
                          SizedBox(height: 10.0),
                          EmailInputW(controller: _emailController),
                          SizedBox(height: 20.0),
                          Text("Contraseña", style: AppTitles.h3),
                          SizedBox(height: 10.0),
                          PasswordInputW(controller: _passwordController),
                          Container(
                            margin: EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Recuérdame", style: AppTexts.body1),
                                Checkbox(
                                  value: widget.viewModel.rememberMe,
                                  onChanged: widget.viewModel.toggleRememberMe,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryP,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 30.0,
                                      vertical: 10.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                  child: Text(
                                    "INGRESAR",
                                    style: AppTitles.h1.copyWith(
                                      color: AppColors.primaryS,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    widget.viewModel.removeListener(_viewModelListener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await widget.viewModel.login(email, password);

      if (success && mounted) {
        context.goNamed('home');
      }
    }
  }

  void _viewModelListener() {
    final errorMessage = widget.viewModel.errorMessage;
    if (errorMessage != null) {
      ErrorDialogW.show(context, errorMessage);
    }
  }
}
