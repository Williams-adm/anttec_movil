import 'package:anttec_movil/data/repositories/auth/auth_repository.dart';
import 'package:flutter/material.dart';

class LoginViewmodel extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _rememberMe = false;

  bool _isloading = false;
  String? _errorMessage;

  LoginViewmodel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  String? get errorMessage => _errorMessage;

  bool get isloading => _isloading;
  bool get rememberMe => _rememberMe;

  Future<bool> login(String email, String password) async {
    _isloading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );
      return result.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }
}
