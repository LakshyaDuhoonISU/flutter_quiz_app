// widgets/question_card.dart
// Displays a single quiz question with selectable answer options (radio buttons)
// This widget is used inside the PageView in QuizScreen

import 'package:flutter/material.dart';
import '../models/question_model.dart';

class QuestionCard extends StatelessWidget {
  final QuestionModel question; // The question data to display
  final int questionNumber; // Display number, e.g. 1, 2, 3
  final int totalQuestions; // Total number of questions in the quiz
  final int?
  selectedAnswer; // The currently selected option index (null = none)
  final Function(int) onAnswerSelected; // Called when student taps an option

  const QuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question counter, e.g. "Question 2 of 5"
          Text(
            'Question $questionNumber of $totalQuestions',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 12),

          // The question text
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Display each option as a highlighted card with a radio button
          ...List.generate(question.options.length, (index) {
            final bool isSelected = selectedAnswer == index;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: isSelected ? 3 : 1,
              // Highlight the selected option
              color: isSelected ? Colors.indigo.shade50 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? Colors.indigo : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: RadioListTile<int>(
                value: index,
                groupValue: selectedAnswer, // The currently selected value
                activeColor: Colors.indigo,
                title: Text(
                  question.options[index],
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    // Notify the parent screen which option was chosen
                    onAnswerSelected(value);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
