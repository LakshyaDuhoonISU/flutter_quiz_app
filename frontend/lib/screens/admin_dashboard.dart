// screens/admin_dashboard.dart
// Admin screen — create, edit, delete quizzes, add questions, view leaderboard

import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'leaderboard_screen.dart';
import 'login_screen.dart';
import 'manage_questions_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<QuizModel> _quizzes = [];
  bool _isLoading = true;

  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getQuizzes();
      setState(() {
        _quizzes = data.map((json) => QuizModel.fromJson(json)).toList();
      });
    } catch (e) {
      _showMessage('Failed to load quizzes.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ─────────────────────────────────────────────
  // Dialog: Create or Edit a Quiz
  // Pass quiz=null to create, or quiz=someQuiz to edit
  // ─────────────────────────────────────────────
  Future<void> _showQuizDialog({QuizModel? quiz}) async {
    // Pre-fill fields if editing an existing quiz
    final titleCtrl = TextEditingController(text: quiz?.title ?? '');
    final descCtrl = TextEditingController(text: quiz?.description ?? '');
    final timeLimitCtrl = TextEditingController(
      text: quiz?.timeLimit.toString() ?? '10',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(quiz == null ? 'Create New Quiz' : 'Edit Quiz'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quiz title
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              // Description
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              // Time limit (numbers only)
              TextField(
                controller: timeLimitCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Time Limit (minutes)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: Text(quiz == null ? 'Create' : 'Save'),
            onPressed: () async {
              final title = titleCtrl.text.trim();
              final desc = descCtrl.text.trim();
              final timeLimit = int.tryParse(timeLimitCtrl.text.trim()) ?? 10;

              if (title.isEmpty || desc.isEmpty) {
                _showMessage('Please fill in all fields');
                return;
              }

              Navigator.pop(context); // Close the dialog

              if (quiz == null) {
                // Admin is creating a new quiz
                await ApiService.createQuiz(title, desc, timeLimit);
                _showMessage('Quiz created successfully!');
              } else {
                // Admin is editing an existing quiz
                await ApiService.updateQuiz(quiz.id, title, desc, timeLimit);
                _showMessage('Quiz updated!');
              }

              _fetchQuizzes(); // Refresh the list
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Confirmation dialog before deleting a quiz
  // ─────────────────────────────────────────────
  Future<void> _deleteQuiz(QuizModel quiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: Text(
          'Are you sure you want to delete "${quiz.title}"?\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.deleteQuiz(quiz.id);
      _showMessage('"${quiz.title}" deleted.');
      _fetchQuizzes();
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      // Floating button to create a new quiz
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuizDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Quiz'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quizzes.isEmpty
          ? const Center(
              child: Text(
                'No quizzes yet.\nTap + to create one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchQuizzes,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
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
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title row with time badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  quiz.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${quiz.timeLimit} min',
                                  style: const TextStyle(
                                    color: Colors.indigo,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            quiz.description,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const Divider(height: 20),
                          // Action buttons
                          Row(
                            children: [
                              // Edit quiz
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Edit Quiz',
                                onPressed: () => _showQuizDialog(quiz: quiz),
                              ),
                              // Delete quiz
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'Delete Quiz',
                                onPressed: () => _deleteQuiz(quiz),
                              ),
                              // Manage questions (view, add, edit, delete)
                              IconButton(
                                icon: const Icon(
                                  Icons.quiz,
                                  color: Colors.green,
                                ),
                                tooltip: 'Manage Questions',
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ManageQuestionsScreen(quiz: quiz),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // View leaderboard
                              OutlinedButton.icon(
                                icon: const Icon(Icons.leaderboard, size: 16),
                                label: const Text('Leaderboard'),
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
