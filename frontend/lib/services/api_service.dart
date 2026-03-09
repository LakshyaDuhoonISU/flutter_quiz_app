// services/api_service.dart
// Handles ALL HTTP requests to the backend API
// Each method corresponds to one API endpoint

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  // ─────────────────────────────────────────────
  // BASE URL — change this depending on how you are testing:
  //
  //   Android Emulator : http://10.0.2.2:5000/api
  //   iOS Simulator    : http://localhost:5000/api
  //   Real Device      : http://<your-computer-local-IP>:5000/api
  //                      e.g. http://192.168.1.10:5000/api
  // ─────────────────────────────────────────────
  static const String baseUrl = 'http://localhost:3000/api';

  // Headers for open endpoints (login & register) — no token needed
  static const Map<String, String> _openHeaders = {
    'Content-Type': 'application/json',
  };

  // Build headers that include the stored JWT token
  // All protected API endpoints require this
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken() ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────
  // AUTH
  // ─────────────────────────────────────────────

  // Register a new user (admin or student)
  static Future<Map<String, dynamic>> register(
    String username,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _openHeaders,
      body: jsonEncode({
        'username': username,
        'password': password,
        'role': role,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Login — returns JWT token and user info on success
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _openHeaders,
      body: jsonEncode({'username': username, 'password': password}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ─────────────────────────────────────────────
  // QUIZZES
  // ─────────────────────────────────────────────

  // Get all quizzes (used by both students and admins)
  static Future<List<dynamic>> getQuizzes() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/quizzes'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    final err = jsonDecode(response.body);
    throw Exception(err['message'] ?? 'Failed to fetch quizzes');
  }

  // Create a new quiz — admin only
  static Future<Map<String, dynamic>> createQuiz(
    String title,
    String description,
    int timeLimit,
  ) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/quizzes'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'description': description,
        'timeLimit': timeLimit,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Update an existing quiz — admin only
  static Future<Map<String, dynamic>> updateQuiz(
    String quizId,
    String title,
    String description,
    int timeLimit,
  ) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/quizzes/$quizId'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'description': description,
        'timeLimit': timeLimit,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Delete a quiz — admin only
  static Future<Map<String, dynamic>> deleteQuiz(String quizId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/quizzes/$quizId'),
      headers: headers,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ─────────────────────────────────────────────
  // QUESTIONS
  // ─────────────────────────────────────────────

  // Get all questions for a specific quiz
  static Future<List<dynamic>> getQuestions(String quizId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/questions/$quizId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    final err = jsonDecode(response.body);
    throw Exception(err['message'] ?? 'Failed to fetch questions');
  }

  // Add a question to a quiz — admin only
  static Future<Map<String, dynamic>> addQuestion(
    String quizId,
    String questionText,
    List<String> options,
    int correctAnswer,
  ) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/questions'),
      headers: headers,
      body: jsonEncode({
        'quizId': quizId,
        'questionText': questionText,
        'options': options,
        'correctAnswer': correctAnswer,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Update an existing question — admin only
  static Future<Map<String, dynamic>> updateQuestion(
    String questionId,
    String questionText,
    List<String> options,
    int correctAnswer,
  ) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/questions/$questionId'),
      headers: headers,
      body: jsonEncode({
        'questionText': questionText,
        'options': options,
        'correctAnswer': correctAnswer,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Delete a single question — admin only
  static Future<Map<String, dynamic>> deleteQuestion(String questionId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/questions/$questionId'),
      headers: headers,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ─────────────────────────────────────────────
  // RESULTS
  // ─────────────────────────────────────────────

  // Submit a student's quiz result after they finish
  static Future<Map<String, dynamic>> submitResult(
    String username,
    String quizId,
    int score,
    int totalQuestions,
    int timeTaken,
  ) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/results'),
      headers: headers,
      body: jsonEncode({
        'username': username,
        'quizId': quizId,
        'score': score,
        'totalQuestions': totalQuestions,
        'timeTaken': timeTaken,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Get all past results for a specific student
  static Future<List<dynamic>> getUserResults(String username) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/results/user/$username'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    final err = jsonDecode(response.body);
    throw Exception(err['message'] ?? 'Failed to fetch results');
  }

  // Get leaderboard for a quiz (sorted highest score first)
  static Future<List<dynamic>> getLeaderboard(String quizId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/results/leaderboard/$quizId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    final err = jsonDecode(response.body);
    throw Exception(err['message'] ?? 'Failed to fetch leaderboard');
  }
}
