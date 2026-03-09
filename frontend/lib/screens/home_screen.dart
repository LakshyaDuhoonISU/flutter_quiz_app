// screens/home_screen.dart
// Student home screen — shows the list of available quizzes

import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'quiz_screen.dart';
import 'leaderboard_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<QuizModel> _quizzes = []; // Holds all quizzes fetched from the API
  bool _isLoading = true; // Shows a spinner while loading
  String _username = ''; // Logged-in student's username

  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load the stored username from SharedPreferences
    final username = await AuthService.getUsername();
    setState(() => _username = username ?? '');
    await _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getQuizzes();
      setState(() {
        // Convert each JSON map to a QuizModel object
        _quizzes = data.map((json) => QuizModel.fromJson(json)).toList();
      });
    } catch (e) {
      _showMessage('Failed to load quizzes. Check your connection.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout(); // Clear saved token from SharedPreferences
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, $_username!'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // History button — shows student's past quiz results
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'My History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HistoryScreen(username: _username),
              ),
            ),
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quizzes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No quizzes available yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              // Pull down to refresh the quiz list
              onRefresh: _fetchQuizzes,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = _quizzes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quiz title
                          Text(
                            quiz.title,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Quiz description
                          Text(
                            quiz.description,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 10),
                          // Time limit badge
                          Row(
                            children: [
                              const Icon(
                                Icons.timer,
                                size: 16,
                                color: Colors.indigo,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${quiz.timeLimit} minutes',
                                style: const TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Action buttons row
                          Row(
                            children: [
                              // Start Quiz button
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Start Quiz'),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuizScreen(
                                        quiz: quiz,
                                        username: _username,
                                      ),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Leaderboard button
                              OutlinedButton.icon(
                                icon: const Icon(Icons.leaderboard, size: 18),
                                label: const Text('Ranks'),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LeaderboardScreen(
                                      quizId: quiz.id,
                                      quizTitle: quiz.title,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
