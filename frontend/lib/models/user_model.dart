// models/user_model.dart
// Represents a User object returned by the login API

class UserModel {
  final String id;
  final String username;
  final String role; // "admin" or "student"

  UserModel({required this.id, required this.username, required this.role});

  // Create a UserModel from the JSON map returned by the login API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? 'student',
    );
  }
}
