import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../core/constants.dart';

class LessonController with ChangeNotifier {
  final LessonModel lesson;
  final UserProgress progress;
  late final List<QuestionModel> _questions;

  int _currentIndex = 0;
  int _correctCount = 0;
  int _errorCount = 0;
  bool _answered = false;
  String? _selectedAnswer;
  bool _isCorrect = false;

  LessonController({
    required this.lesson,
    required this.progress,
  }) {
    _questions =
        lesson.getQuestionsForObjectif(progress.objectif);
  }

  int get currentIndex => _currentIndex;
  int get totalQuestions => _questions.length;
  QuestionModel get currentQuestion =>
      _questions[_currentIndex];
  bool get answered => _answered;
  String? get selectedAnswer => _selectedAnswer;
  bool get isCorrect => _isCorrect;
  int get correctCount => _correctCount;
  int get errorCount => _errorCount;
  bool get isLastQuestion =>
      _currentIndex == totalQuestions - 1;
  int get earnedXP =>
      _correctCount * AppConstants.xpPerCorrect;
  int get accuracy => totalQuestions > 0
      ? ((_correctCount / totalQuestions) * 100).round()
      : 0;

  void selectAnswer(String answer) {
    if (_answered) return;
    _selectedAnswer = answer;
    _isCorrect = answer == currentQuestion.correctAnswer;
    _answered = true;
    if (_isCorrect) {
      _correctCount++;
    } else {
      _errorCount++;
      progress.loseHeart(); // compte aussi l'erreur
    }
    notifyListeners();
  }

  /// Retourne true → question suivante
  /// Retourne false → leçon terminée
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
    // Leçon terminée — l'XP n'est créditée qu'ici, en même temps que la
    // sauvegarde Firestore (result_screen). Quitter en cours = 0 XP.
    progress.addXP(earnedXP);
    progress.completeLesson(
      lesson.id,
      lesson.courseCards.length,
    );
    return false;
  }

  /// Pour la prononciation — marque comme correct et passe
  void markPronunciationCorrect() {
    if (!_answered) {
      _selectedAnswer = currentQuestion.correctAnswer;
      _isCorrect = true;
      _answered = true;
      _correctCount++;
      notifyListeners();
    }
  }

  /// Pour la prononciation — marque comme échoué
  void markPronunciationFailed() {
    if (!_answered) {
      _answered = true;
      _isCorrect = false;
      _errorCount++;
      progress.loseHeart(); // compte aussi l'erreur
      notifyListeners();
    }
  }
}