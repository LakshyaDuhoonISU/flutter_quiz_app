// widgets/timer_widget.dart
// A countdown timer that shows time remaining during a quiz
// When the time reaches 0, it calls the onTimeUp callback

import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final int timeInMinutes; // Quiz time limit in minutes
  final VoidCallback onTimeUp; // Called when countdown reaches 0

  const TimerWidget({
    super.key,
    required this.timeInMinutes,
    required this.onTimeUp,
  });

  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _secondsRemaining; // Total seconds left
  Timer? _timer; // The periodic timer object

  void initState() {
    super.initState();
    // Convert minutes to seconds for the countdown
    _secondsRemaining = widget.timeInMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    // Timer.periodic fires every 1 second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        // Time is up — stop the timer and notify the parent
        timer.cancel();
        widget.onTimeUp();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void dispose() {
    // Always cancel the timer when the widget is removed to avoid memory leaks
    _timer?.cancel();
    super.dispose();
  }

  // Format total seconds as MM:SS string, e.g. 125 seconds → "02:05"
  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    // padLeft(2, '0') adds a leading zero when needed (e.g. "9" → "09")
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget build(BuildContext context) {
    // Turn red when 30 seconds or less remain to warn the student
    final bool isUrgent = _secondsRemaining <= 30;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red : Colors.indigo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            _formatTime(_secondsRemaining),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
