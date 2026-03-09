// models/result_model.dart
// Represents a quiz Result object from the backend

class ResultModel {
  final String username;
  // quizId can be either a plain String ID, or a full Map if the backend
  // "populated" it (filled in quiz details from the database)
  final dynamic quizId;
  final int score;
  final int totalQuestions;
  // Time taken in seconds to complete the quiz
  final int timeTaken;
  final String createdAt;

  ResultModel({
    required this.username,
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.timeTaken,
    required this.createdAt,
  });

  // Create a ResultModel from a JSON map
  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      username: json['username'] ?? '',
      quizId: json['quizId'],
      score: json['score'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      timeTaken: json['timeTaken'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }

  // Helper: get the quiz title if quizId was populated (is a full quiz object)
  String get quizTitle {
    if (quizId is Map) {
      return quizId['title'] ?? 'Unknown Quiz';
    }
    return 'Quiz';
  }
}
