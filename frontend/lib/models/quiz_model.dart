// models/quiz_model.dart
// Represents a Quiz object from the backend

class QuizModel {
  final String id;
  final String title;
  final String description;
  final int timeLimit; // Time limit in minutes

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timeLimit,
  });

  // Create a QuizModel from the JSON map returned by the API
  // Note: MongoDB uses "_id" not "id"
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timeLimit: json['timeLimit'] ?? 10,
    );
  }
}
