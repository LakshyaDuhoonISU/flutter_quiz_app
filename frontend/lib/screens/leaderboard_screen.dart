// screens/leaderboard_screen.dart
// Shows the top scores for a specific quiz, sorted highest first

import 'package:flutter/material.dart';
import '../models/result_model.dart';
import '../services/api_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;

  const LeaderboardScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<ResultModel> _leaderboard = [];
  bool _isLoading = true;

  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getLeaderboard(widget.quizId);
      setState(() {
        _leaderboard = data.map((json) => ResultModel.fromJson(json)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load leaderboard.')),
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

  // Returns a medal emoji for top 3, or a plain rank number for the rest
  Widget _rankBadge(int rank) {
    if (rank == 1) return const Text('🥇', style: TextStyle(fontSize: 26));
    if (rank == 2) return const Text('🥈', style: TextStyle(fontSize: 26));
    if (rank == 3) return const Text('🥉', style: TextStyle(fontSize: 26));
    return CircleAvatar(
      radius: 15,
      backgroundColor: Colors.grey[200],
      child: Text(
        '$rank',
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Leaderboard', style: TextStyle(fontSize: 18)),
            Text(
              widget.quizTitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _leaderboard.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.leaderboard, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No results yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _leaderboard.length,
              itemBuilder: (context, index) {
                final result = _leaderboard[index];
                final int rank = index + 1;
                final int percentage = result.totalQuestions > 0
                    ? (result.score / result.totalQuestions * 100).round()
                    : 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: rank <= 3 ? 3 : 1,
                  color: rank == 1 ? Colors.amber.shade50 : null,
                  child: ListTile(
                    leading: _rankBadge(rank),
                    title: Text(
                      result.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '⏱ ${_formatTime(result.timeTaken)}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${result.score}/${result.totalQuestions}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
