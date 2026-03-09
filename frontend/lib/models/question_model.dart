// models/question_model.dart
// Represents a Question object from the backend

class QuestionModel {
  final String id;
  final String quizId;
  final String questionText;
  final List<String> options; // e.g. ["Paris", "London", "Berlin", "Rome"]
  final int correctAnswer; // Index of the correct option (0-based)

  QuestionModel({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });

  // Create a QuestionModel from a JSON map
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['_id'] ?? '',
      quizId: json['quizId'] ?? '',
      questionText: json['questionText'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
    );
  }
}
