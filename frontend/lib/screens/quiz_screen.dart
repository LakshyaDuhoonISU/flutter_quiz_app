// screens/quiz_screen.dart
// The quiz-taking screen — shows questions one by one using PageView
// Includes a countdown timer, radio button answers, and a submit button

import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../services/api_service.dart';
import '../widgets/question_card.dart';
import '../widgets/timer_widget.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuizModel quiz; // The quiz being taken
  final String username; // The student's username

  const QuizScreen({super.key, required this.quiz, required this.username});

  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuestionModel> _questions = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Controls which question page is currently visible
  final _pageController = PageController();
  int _currentPage = 0;

  // Tracks the student's selected answer for each question
  // Key = question index (0, 1, 2...), Value = selected option index (0, 1, 2, 3)
  final Map<int, int> _selectedAnswers = {};

  // Tracks how long the student has been actively answering
  // Started once questions finish loading, stopped on submit
  final Stopwatch _stopwatch = Stopwatch();

  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final data = await ApiService.getQuestions(widget.quiz.id);
      setState(() {
        _questions = data.map((json) => QuestionModel.fromJson(json)).toList();
        _isLoading = false;
      });
      // Start timing once questions are visible
      _stopwatch.start();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load questions.')),
        );
        Navigator.pop(context);
      }
    }
  }

  // Calculate the score by comparing selected answers to correct answers
  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      // If no answer was selected for question i, it counts as wrong
      if (_selectedAnswers[i] == _questions[i].correctAnswer) {
        score++;
      }
    }
    return score;
  }

  // Submit the quiz result to the backend, then navigate to ResultScreen
  Future<void> _submitQuiz() async {
    if (_isSubmitting) return; // Prevent submitting twice
    setState(() => _isSubmitting = true);

    _stopwatch.stop();
    final int timeTaken = _stopwatch.elapsed.inSeconds;
    final score = _calculateScore();
    final total = _questions.length;

    try {
      // Send the result to the backend API
      await ApiService.submitResult(
        widget.username,
        widget.quiz.id,
        score,
        total,
        timeTaken,
      );
    } catch (e) {
      // Even if saving fails, still show the result to the student
    }

    if (!mounted) return;

    // Replace QuizScreen with ResultScreen (student can't go back to the quiz)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: score,
          totalQuestions: total,
          timeTaken: timeTaken,
          quizId: widget.quiz.id,
          quizTitle: widget.quiz.title,
        ),
      ),
    );
  }

  // Called automatically by TimerWidget when the countdown reaches 0
  void _onTimeUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⏰ Time is up! Submitting your answers...')),
    );
    _submitQuiz();
  }

  void _goToNextPage() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void dispose() {
    _stopwatch.stop();
    _pageController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        // Show the countdown timer in the top-right corner
        // Only after questions are loaded (otherwise timeLimit would start ticking
        // before questions appear on screen)
        actions: [
          if (!_isLoading && _questions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: TimerWidget(
                  timeInMinutes: widget.quiz.timeLimit,
                  onTimeUp: _onTimeUp,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
          ? const Center(child: Text('No questions available for this quiz.'))
          : Column(
              children: [
                // Progress bar — shows how far through the quiz the student is
                LinearProgressIndicator(
                  value: (_currentPage + 1) / _questions.length,
                  backgroundColor: Colors.grey[200],
                  color: Colors.indigo,
                  minHeight: 6,
                ),

                // PageView renders one question at a time
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    // Disable swiping — student must use Next/Previous buttons
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _questions.length,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    itemBuilder: (context, index) {
                      return QuestionCard(
                        question: _questions[index],
                        questionNumber: index + 1,
                        totalQuestions: _questions.length,
                        selectedAnswer: _selectedAnswers[index],
                        onAnswerSelected: (answerIndex) {
                          // Save the selected answer for this question
                          setState(() {
                            _selectedAnswers[index] = answerIndex;
                          });
                        },
                      );
                    },
                  ),
                ),

                // Navigation buttons at the bottom
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Row(
                    children: [
                      // Previous button (hidden on first question)
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                            onPressed: _goToPreviousPage,
                          ),
                        ),

                      if (_currentPage > 0) const SizedBox(width: 12),

                      // Next button OR Submit button on the last question
                      Expanded(
                        child: _currentPage < _questions.length - 1
                            ? ElevatedButton.icon(
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('Next'),
                                onPressed: _goToNextPage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                ),
                              )
                            : ElevatedButton.icon(
                                // Show a spinner icon while submitting
                                icon: _isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.check_circle),
                                label: const Text('Submit Quiz'),
                                onPressed: _isSubmitting ? null : _submitQuiz,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
