import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:anttec_movil/data/repositories/auth/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final LocalAuthentication _auth = LocalAuthentication();

  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;
  bool _canCheckBiometrics = false;

  String _savedEmail = '';
  String _savedPassword = '';

  LoginViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _initViewModel();
  }

  // --- Getters ---
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  bool get canCheckBiometrics => _canCheckBiometrics;
  String get savedEmail => _savedEmail;
  String get savedPassword => _savedPassword;

  // --- Inicialización ---
  Future<void> _initViewModel() async {
    await _checkBiometricsSupport();
    await _loadSavedCredentials();
  }

  // Verifica si el hardware soporta biometría y si está configurada
  Future<void> _checkBiometricsSupport() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();

      _canCheckBiometrics = canAuthenticateWithBiometrics || isDeviceSupported;
      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Error verificando soporte biométrico: $e");
      _canCheckBiometrics = false;
    }
  }

  // --- Lógica de Autenticación Biométrica ---
  Future<bool> authenticate() async {
    try {
      // Primero validamos si hay alguna seguridad activa (PIN, Huella, etc.)
      final List<BiometricType> availableBiometrics =
          await _auth.getAvailableBiometrics();

      // Si el equipo soporta biometría pero Wilson no ha registrado su dedo en ajustes
      if (availableBiometrics.isEmpty) {
        _errorMessage = "No tienes huellas registradas en este equipo.";
        notifyListeners();
        return false;
      }

      return await _auth.authenticate(
        localizedReason: 'Identifícate para ingresar a ANTTEC',
        options: const AuthenticationOptions(
          stickyAuth:
              true, // Mantiene la autenticación si la app va a segundo plano
          biometricOnly:
              false, // PERMITE usar PIN/Patrón si la huella falla (Estilo Yape)
          useErrorDialogs: true, // Muestra errores del sistema automáticamente
        ),
      );
    } catch (e) {
      _errorMessage =
          "Error de seguridad: Verifica la configuración de tu equipo.";
      notifyListeners();
      return false;
    }
  }

  // --- Lógica de Login Tradicional ---
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
        final prefs = await SharedPreferences.getInstance();

        // Guardar token para las llamadas a la API de ventas
        if (result.token.isNotEmpty) {
          await prefs.setString('auth_token', result.token);
        }

        // Manejar el "Recuérdame"
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

  // --- Manejo de SharedPreferences ---
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_me') ?? false;

    if (remember) {
      _rememberMe = true;
      _savedEmail = prefs.getString('saved_email') ?? '';
      _savedPassword = prefs.getString('saved_password') ?? '';
      notifyListeners();
    }
  }

  Future<void> _handleRememberMe(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
    } else {
      await prefs.remove('remember_me');
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
    }
  }
}
