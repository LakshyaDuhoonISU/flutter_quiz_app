import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../services/api_service.dart';

class ManageQuestionsScreen extends StatefulWidget {
  final QuizModel quiz;
  const ManageQuestionsScreen({super.key, required this.quiz});

  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  List<QuestionModel> _questions = [];
  bool _loading = true;

  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _loading = true);
    try {
      final raw = await ApiService.getQuestions(widget.quiz.id);
      if (!mounted) return;
      setState(() {
        _questions = raw
            .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _questions = [];
        _loading = false;
      });
    }
  }

  // ──────────────────────────────────────────────────────────
  // ADD / EDIT question dialog
  // Pass an existing question to pre-fill for editing.
  // ──────────────────────────────────────────────────────────
  void _showQuestionDialog({QuestionModel? question}) {
    final isEditing = question != null;
    final questionController = TextEditingController(
      text: isEditing ? question.questionText : '',
    );
    final optionControllers = List.generate(
      4,
      (i) => TextEditingController(
        text: isEditing && i < question.options.length
            ? question.options[i]
            : '',
      ),
    );
    int selectedCorrect = isEditing ? question.correctAnswer : 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Question' : 'Add Question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Question Text'),
                ),
                const SizedBox(height: 12),
                ...List.generate(4, (i) {
                  return Row(
                    children: [
                      Radio<int>(
                        value: i,
                        groupValue: selectedCorrect,
                        onChanged: (v) =>
                            setDialogState(() => selectedCorrect = v!),
                      ),
                      Expanded(
                        child: TextField(
                          controller: optionControllers[i],
                          decoration: InputDecoration(
                            labelText: 'Option ${i + 1}',
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 6),
                Text(
                  'Select the radio button next to the correct answer.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final qText = questionController.text.trim();
                final opts = optionControllers
                    .map((c) => c.text.trim())
                    .toList();

                if (qText.isEmpty || opts.any((o) => o.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields.')),
                  );
                  return;
                }

                Navigator.pop(ctx);

                if (isEditing) {
                  await ApiService.updateQuestion(
                    question.id,
                    qText,
                    opts,
                    selectedCorrect,
                  );
                } else {
                  await ApiService.addQuestion(
                    widget.quiz.id,
                    qText,
                    opts,
                    selectedCorrect,
                  );
                }
                _loadQuestions();
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // DELETE a single question with confirmation
  // ──────────────────────────────────────────────────────────
  void _deleteQuestion(QuestionModel question) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Question'),
        content: Text(
          'Delete "${question.questionText}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.deleteQuestion(question.id);
              await _loadQuestions();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions — ${widget.quiz.title}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuestionDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Question'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
          ? const Center(
              child: Text(
                'No questions yet.\nTap "Add Question" to create one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _questions.length,
              itemBuilder: (ctx, i) {
                final q = _questions[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question number + text
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.indigo,
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                q.questionText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Options list
                        ...q.options.asMap().entries.map((e) {
                          final isCorrect = e.key == q.correctAnswer;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Icon(
                                  isCorrect
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 16,
                                  color: isCorrect ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Expanded(child: Text(e.value)),
                              ],
                            ),
                          );
                        }),
                        const Divider(height: 16),
                        // Edit and Delete buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showQuestionDialog(question: q),
                              icon: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.blue,
                              ),
                              label: const Text(
                                'Edit',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _deleteQuestion(q),
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
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
    );
  }
}
