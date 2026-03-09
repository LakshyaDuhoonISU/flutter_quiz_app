// screens/history_screen.dart
// Shows a student's previous quiz attempts

import 'package:flutter/material.dart';
import '../models/result_model.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  final String username;

  const HistoryScreen({super.key, required this.username});

  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ResultModel> _results = [];
  bool _isLoading = true;

  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getUserResults(widget.username);
      setState(() {
        _results = data.map((json) => ResultModel.fromJson(json)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load history.')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Format seconds as "Xm Ys"
  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Quiz History'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "You haven't taken any quizzes yet.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                final int percentage = result.totalQuestions > 0
                    ? (result.score / result.totalQuestions * 100).round()
                    : 0;

                // Color based on score
                final Color scoreColor = percentage >= 80
                    ? Colors.green
                    : percentage >= 50
                    ? Colors.orange
                    : Colors.red;

                // Show just the date part from the ISO timestamp
                // e.g. "2026-03-06T10:30:00.000Z" → "2026-03-06"
                final String dateStr = result.createdAt.length >= 10
                    ? result.createdAt.substring(0, 10)
                    : result.createdAt;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    // Score circle on the left
                    leading: CircleAvatar(
                      backgroundColor: scoreColor.withAlpha(40),
                      child: Text(
                        '$percentage%',
                        style: TextStyle(
                          color: scoreColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      result.quizTitle, // quiz title from populated quizId
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Date: $dateStr  •  ⏱ ${_formatTime(result.timeTaken)}',
                    ),
                    // Score on the right
                    trailing: Text(
                      '${result.score}/${result.totalQuestions}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: scoreColor,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
