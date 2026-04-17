class UserModel {
  final String username;
  final String role; // 'admin' or 'staff'

  UserModel({required this.username, required this.role});

  bool get isAdmin => role == 'admin';
}