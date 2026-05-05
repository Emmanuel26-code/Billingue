import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../core/constants.dart';

class LessonController with ChangeNotifier {
  final LessonModel lesson;
  final UserProgress progress;

  int _currentIndex = 0;
  int _correctCount = 0;
  bool _answered = false;
  String? _selectedAnswer;
  bool _isCorrect = false;

  LessonController({required this.lesson, required this.progress});

  int get currentIndex => _currentIndex;
  int get totalQuestions => lesson.questions.length;
  QuestionModel get currentQuestion => lesson.questions[_currentIndex];
  bool get answered => _answered;
  String? get selectedAnswer => _selectedAnswer;
  bool get isCorrect => _isCorrect;
  int get correctCount => _correctCount;
  bool get isLastQuestion => _currentIndex == totalQuestions - 1;
  int get earnedXP => _correctCount * AppConstants.xpPerCorrect;
  int get accuracy => totalQuestions > 0
      ? ((_correctCount / totalQuestions) * 100).round()
      : 0;

  void selectAnswer(String answer) {
    if (_answered) return;
    _selectedAnswer = answer;
    _isCorrect = answer == currentQuestion.correctAnswer;
    _answered = true;
    if (!_isCorrect && progress.hearts > 0) progress.hearts--;
    if (_isCorrect) _correctCount++;
    notifyListeners();
  }

  /// Retourne true si on passe à la suivante, false si c'est la fin
  bool nextQuestion() {
    if (!_answered) return false;
    if (_currentIndex < totalQuestions - 1) {
      _currentIndex++;
      _answered = false;
      _selectedAnswer = null;
      _isCorrect = false;
      notifyListeners();
      return true;
    }
    progress.xp += earnedXP;
    progress.completeLesson(lesson.id);
    return false;
  }
}