import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  final _authService = AuthService();

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  bool login(String username, String password) {
    _user = _authService.login(username, password);
    notifyListeners();
    return _user != null;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}