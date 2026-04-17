import '../models/user_model.dart';

class AuthService {
  // Hardcoded credentials
  static const _users = [
    {'username': 'admin', 'password': 'admin123', 'role': 'admin'},
    {'username': 'staff', 'password': 'staff123', 'role': 'staff'},
  ];

  UserModel? login(String username, String password) {
    final match = _users.where(
          (u) => u['username'] == username && u['password'] == password,
    );
    if (match.isEmpty) return null;
    return UserModel(
      username: match.first['username']!,
      role: match.first['role']!,
    );
  }
}