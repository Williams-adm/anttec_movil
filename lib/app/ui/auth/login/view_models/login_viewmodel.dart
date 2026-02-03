import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:anttec_movil/data/repositories/auth/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;
  String _savedEmail = '';
  String _savedPassword = '';

  LoginViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository {
    loadSavedCredentials();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;
  String get savedEmail => _savedEmail;
  String get savedPassword => _savedPassword;

  Future<void> loadSavedCredentials() async {
    try {
      final flag = await _storage.read(key: 'remember_me_flag');
      if (flag == 'true') {
        _savedEmail = await _storage.read(key: 'saved_email') ?? '';
        _savedPassword = await _storage.read(key: 'saved_password') ?? '';
        _rememberMe = true;
      } else {
        _savedEmail = '';
        _savedPassword = '';
        _rememberMe = false;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error storage: $e");
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result =
          await _authRepository.login(email: email, password: password);

      if (result.success) {
        // 🔒 SEGURIDAD: Validar Rol de Administrador
        if (!result.roles.contains('admin')) {
          _errorMessage =
              "Acceso denegado: No tienes permisos de administrador.";
          _isLoading = false;
          notifyListeners();
          return false; // ⛔ Detenemos el login aquí
        }

        // ✅ Si es admin, continuamos...
        TextInput.finishAutofillContext(shouldSave: true);

        if (result.token.isNotEmpty) {
          await _storage.write(key: 'auth_token', value: result.token);
        }

        if (_rememberMe) {
          await _storage.write(key: 'remember_me_flag', value: 'true');
          await _storage.write(key: 'saved_email', value: email);
          await _storage.write(key: 'saved_password', value: password);
        } else {
          await _storage.delete(key: 'remember_me_flag');
          await _storage.delete(key: 'saved_email');
          await _storage.delete(key: 'saved_password');
        }
        return true;
      } else {
        _errorMessage = result.message;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '').trim();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await loadSavedCredentials();
    debugPrint("🚪 Sesión cerrada en disco.");
  }

  void toggleRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
