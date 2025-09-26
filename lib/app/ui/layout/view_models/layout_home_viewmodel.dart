import 'package:anttec_movil/data/repositories/auth/auth_repository.dart';
import 'package:anttec_movil/data/repositories/category/category_repository.dart';
import 'package:anttec_movil/data/services/api/v1/model/category/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LayoutHomeViewmodel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final CategoryRepository _categoryRepository;
  final _secureStorage = const FlutterSecureStorage();

  bool _isloading = false;
  String? _errorMessage;
  List<CategoryModel> _categories = [];

  String? _profileName;
  LayoutHomeViewmodel({
    required AuthRepository authRepository,
    required CategoryRepository categoryRepository,
  }) : _authRepository = authRepository,
       _categoryRepository = categoryRepository;

  List<CategoryModel> get categories => _categories;
  String? get errorMessage => _errorMessage;
  bool get isloading => _isloading;

  String? get profileName => _profileName;

  Future<void> loadCategories() async {
    _isloading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _categoryRepository.categoryAll();
      _categories = result.data;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _categories = [];
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
