import 'package:anttec_movil/data/repositories/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  // Almacenamiento seguro para Token y Contraseña
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;
  bool _isDisposed = false;

  String _savedEmail = '';
  String _savedPassword = '';

  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    _loadSavedCredentials();
  }

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  String get savedEmail => _savedEmail;
  String get savedPassword => _savedPassword;

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
        // --- CORRECCIÓN AQUÍ ---
        // Tu modelo LoginResponse tiene el token directo, no dentro de 'data'.
        final token = result.token;

        if (token.isNotEmpty) {
          // Guardamos el token para las futuras peticiones (Home, Perfil, etc)
          await _storage.write(key: 'auth_token', value: token);
        }

        // Guardamos credenciales para "Recuérdame"
        await _handleRememberMe(email, password);

        return true;
      } else {
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

  // --- MÉTODOS PRIVADOS ---

  Future<void> _loadSavedCredentials() async {
    // Para el remember_me es mejor usar secure storage si guardamos contraseña
    final email = await _storage.read(key: 'saved_email');
    final password = await _storage.read(key: 'saved_password');
    final remember = await _storage.read(key: 'remember_me');

    if (remember == 'true' && email != null && password != null) {
      _rememberMe = true;
      _savedEmail = email;
      _savedPassword = password;
      notifyListeners();
    }
  }

  Future<void> _handleRememberMe(String email, String password) async {
    if (_rememberMe) {
      await _storage.write(key: 'remember_me', value: 'true');
      await _storage.write(key: 'saved_email', value: email);
      await _storage.write(key: 'saved_password', value: password);
    } else {
      // Borramos todo si el usuario desmarca la opción
      await _storage.delete(key: 'remember_me');
      await _storage.delete(key: 'saved_email');
      await _storage.delete(key: 'saved_password');
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
