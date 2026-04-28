import 'package:flutter/material.dart';
import 'repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final IAuthRepository _authRepository;

  AuthController(this._authRepository);

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  String _userName = '';
  String _userEmail = '';
  final String _userToken = '';
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userToken => _userToken;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    final response = await _authRepository.login(email, password);

    if (response.success && response.data != null) {
      _isLoggedIn = true;
      _userEmail = response.data!.email;
      _userName = response.data!.name;
    } else {
      _errorMessage = response.message ?? 'Login failed. Please try again.';
    }

    _setLoading(false);
  }

  Future<void> signup(String name, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    final response = await _authRepository.register(name, email, password);

    if (response.success && response.data != null) {
      _isLoggedIn = true;
      _userEmail = response.data!.email;
      _userName = response.data!.name;
    } else {
      _errorMessage = response.message ?? 'Signup failed. Please try again.';
    }

    _setLoading(false);
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
