import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anttec_movil/data/repositories/auth/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;

  String _savedEmail = '';
  String _savedPassword = '';

  LoginViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _loadSavedCredentials(); // Carga datos al iniciar
  }

  // Getters
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  String get savedEmail => _savedEmail;
  String get savedPassword => _savedPassword;

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = "Por favor, completa todos los campos.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result =
          await _authRepository.login(email: email, password: password);

      if (result.success) {
        // 🔥 GUARDADO LOCAL CON SHAREDPREFERENCES
        debugPrint(
            "💾 Intentando guardar credenciales... Checkbox activo: $_rememberMe");
        await _handleRememberMe(email, password);

        return true;
      } else {
        _errorMessage = result.message;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  // --- CARGA DE DATOS (SharedPreferences) ---
  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final remember = prefs.getBool('remember_me') ?? false;
      final email = prefs.getString('saved_email');
      final password = prefs.getString('saved_password');

      debugPrint(
          "📂 Cargando datos locales -> Remember: $remember, Email: $email");

      if (remember && email != null && password != null) {
        _rememberMe = true;
        _savedEmail = email;
        _savedPassword = password;

        // 🔥 AVISAR A LA PANTALLA PARA QUE LLENE LOS CAMPOS
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Error cargando SharedPreferences: $e");
    }
  }

  // --- GUARDADO DE DATOS (SharedPreferences) ---
  Future<void> _handleRememberMe(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
      debugPrint("✅ Datos guardados EXITOSAMENTE en disco.");
    } else {
      await prefs.remove('remember_me');
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      debugPrint("🗑️ Datos borrados del disco.");
    }
  }
}
