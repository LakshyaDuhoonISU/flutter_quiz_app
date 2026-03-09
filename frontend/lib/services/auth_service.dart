// services/auth_service.dart
// Handles storing and reading user login data on the device
// Uses SharedPreferences — a simple key-value storage that persists between app sessions

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Keys used to store values — using constants avoids typos
  static const String _tokenKey = 'token';
  static const String _usernameKey = 'username';
  static const String _roleKey = 'role';

  // Save the token, username, and role after a successful login
  static Future<void> saveUserData(
    String token,
    String username,
    String role,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_roleKey, role);
  }

  // Get the stored JWT token (null if not logged in)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get the stored username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // Get the stored role ("admin" or "student")
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // Check if the user is logged in (has a non-empty token saved)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all saved data — used when logging out
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
