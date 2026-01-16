import 'package:anttec_movil/data/repositories/auth/auth_repository.dart';
import 'package:anttec_movil/data/repositories/category/category_repository.dart';
import 'package:anttec_movil/data/services/api/v1/brand_service.dart'; // Importa tu servicio de marcas
import 'package:anttec_movil/data/services/api/v1/model/category/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LayoutHomeViewmodel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final CategoryRepository _categoryRepository;

  // 1. Instancia del servicio de marcas
  final BrandService _brandService = BrandService();

  final _secureStorage = const FlutterSecureStorage();

  bool _isloading = false;
  String? _errorMessage;

  List<CategoryModel> _categories = [];
  // 2. Lista para almacenar las marcas
  List<dynamic> _brands = [];

  String? _profileName;

  LayoutHomeViewmodel({
    required AuthRepository authRepository,
    required CategoryRepository categoryRepository,
  }) : _authRepository = authRepository,
       _categoryRepository = categoryRepository;

  List<CategoryModel> get categories => _categories;
  // 3. Getter para las marcas
  List<dynamic> get brands => _brands;

  String? get errorMessage => _errorMessage;
  bool get isloading => _isloading;
  String? get profileName => _profileName;

  Future<void> loadCategories() async {
    _isloading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 4. Carga paralela: Traemos categorías y marcas al mismo tiempo
      final results = await Future.wait([
        _categoryRepository.categoryAll(), // Index 0
        _brandService.getAllBrands(), // Index 1
      ]);

      // Procesar Categorías
      final categoryResult = results[0];
      // Ajusta esto según lo que retorne tu repositorio (si es CategoryResponse o ya la lista)
      // Asumiendo que retorna el Response que tiene .data:
      _categories = (categoryResult as dynamic).data;

      // Procesar Marcas
      _brands = results[1] as List<dynamic>;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _categories = [];
      _brands = [];
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    _profileName = await _secureStorage.read(key: 'profile_name');
    notifyListeners();
  }

  Future<bool> logout() async {
    _isloading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.logout();
      return result.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }
}
