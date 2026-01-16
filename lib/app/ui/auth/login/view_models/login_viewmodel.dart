import 'package:anttec_movil/data/repositories/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  // Estado privado
  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;
  bool _isDisposed = false;
  String _savedEmail = '';

  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    _loadSavedCredentials();
  }

  // Getters
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  String get savedEmail => _savedEmail;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _setErrorMessage("Por favor, completa todos los campos.");
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      if (result.success) {
        await _handleRememberMe(email);
        return true;
      } else {
        // --- CORRECCIÓN AQUÍ ---
        // Eliminamos '?? "Credenciales incorrectas"' porque result.message no es nulo.
        _setErrorMessage(result.message);
        return false;
      }
    } catch (e) {
      _setErrorMessage(_handleError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void toggleRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void clearErrorMessage() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // --- LÓGICA PRIVADA ---

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_me') ?? false;
    if (remember) {
      _rememberMe = true;
      _savedEmail = prefs.getString('saved_email') ?? '';
      notifyListeners();
    }
  }

  Future<void> _handleRememberMe(String email) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_email', email);
    } else {
      await prefs.remove('remember_me');
      await prefs.remove('saved_email');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  String _handleError(dynamic e) {
    final error = e.toString().toLowerCase();
    if (error.contains('socketexception') || error.contains('network')) {
      return "No hay conexión a internet.";
    }
    return e.toString().replaceFirst('Exception: ', '');
  }
}
