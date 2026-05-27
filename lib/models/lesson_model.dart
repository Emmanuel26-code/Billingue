import 'package:flutter/foundation.dart';

enum QuestionType {
  multipleChoice,
  trueFalse,
  pronunciation,
}

class CourseCard {
  final String baoule;
  final String francais;
  final String? exemple;
  final String? exempeFr;

  const CourseCard({
    required this.baoule,
    required this.francais,
    this.exemple,
    this.exempeFr,
  });
}

class QuestionModel {
  final String id;
  final QuestionType type;
  final String instruction;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  const QuestionModel({
    required this.id,
    required this.type,
    required this.instruction,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}

class LessonModel {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final int xpReward;
  final bool isUnlocked;
  final List<CourseCard> courseCards;
  final List<QuestionModel> questions;

  const LessonModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.xpReward,
    this.isUnlocked = false,
    required this.courseCards,
    required this.questions,
  });

  /// Filtre les questions selon l'objectif de temps
  List<QuestionModel> getQuestionsForObjectif(String objectif) {
    switch (objectif) {
      case 'Moyens':
        // 5 min → 3 QCM max, pas de prononciation
        final qcm = questions
            .where((q) => q.type == QuestionType.multipleChoice)
            .take(3)
            .toList();
        return qcm;
      case 'Regulier':
        // 10 min → 5 QCM + 1 prononciation
        final qcm = questions
            .where((q) => q.type == QuestionType.multipleChoice)
            .take(5)
            .toList();
        final prono = questions
            .where((q) => q.type == QuestionType.pronunciation)
            .take(1)
            .toList();
        return [...qcm, ...prono];
      case 'Sérieux':
        // 15 min → toutes QCM + 2 prononciations
        final qcm = questions
            .where((q) => q.type == QuestionType.multipleChoice)
            .toList();
        final prono = questions
            .where((q) => q.type == QuestionType.pronunciation)
            .take(2)
            .toList();
        return [...qcm, ...prono];
      case 'Intense':
      default:
        // 20 min → toutes les questions
        return questions;
    }
  }
}

class UserProgress extends ChangeNotifier {
  int _xp;
  int _hearts;
  int _streak;
  String _avatar;
  String _nom;
  String _objectif;
  Set<String> _completedLessons;
  int _totalWordsLearned;
  int _totalErrors;

  UserProgress({
    int xp = 0,
    int hearts = 5,
    int streak = 0,
    String avatar = 'assets/avatars/avatar.png',
    String nom = 'Joueur',
    String objectif = 'Regulier',
    Set<String>? completedLessons,
    int totalWordsLearned = 0,
    int totalErrors = 0,
  })  : _xp = xp,
        _hearts = hearts,
        _streak = streak,
        _avatar = avatar,
        _nom = nom,
        _objectif = objectif,
        _completedLessons = completedLessons ?? {},
        _totalWordsLearned = totalWordsLearned,
        _totalErrors = totalErrors;

  // Getters
  int get xp => _xp;
  int get hearts => _hearts;
  int get streak => _streak;
  String get avatar => _avatar;
  String get nom => _nom;
  String get objectif => _objectif;
  Set<String> get completedLessons => _completedLessons;
  int get totalWordsLearned => _totalWordsLearned;
  int get totalErrors => _totalErrors;

  // Setters avec notification
  set xp(int value) {
    _xp = value;
    notifyListeners();
  }

  set hearts(int value) {
    _hearts = value;
    notifyListeners();
  }

  set streak(int value) {
    _streak = value;
    notifyListeners();
  }

  set avatar(String value) {
    _avatar = value;
    notifyListeners();
  }

  set nom(String value) {
    _nom = value;
    notifyListeners();
  }

  set objectif(String value) {
    _objectif = value;
    notifyListeners();
  }

  set totalWordsLearned(int value) {
    _totalWordsLearned = value;
    notifyListeners();
  }

  set totalErrors(int value) {
    _totalErrors = value;
    notifyListeners();
  }

  bool isLessonCompleted(String id) => _completedLessons.contains(id);

  void completeLesson(String id, int wordsLearned) {
    _completedLessons.add(id);
    _totalWordsLearned += wordsLearned;
    notifyListeners();
  }

  void addXP(int amount) {
    _xp += amount;
    notifyListeners();
  }

  void loseHeart() {
    if (_hearts > 0) {
      _hearts--;
      notifyListeners();
    }
  }

  void addError() {
    _totalErrors++;
    notifyListeners();
  }

  void updateAll({
    required int xp,
    required int hearts,
    required int streak,
    required String avatar,
    required String nom,
    required String objectif,
    required Set<String> completedLessons,
    required int totalWordsLearned,
    required int totalErrors,
  }) {
    _xp = xp;
    _hearts = hearts;
    _streak = streak;
    _avatar = avatar;
    _nom = nom;
    _objectif = objectif;
    _completedLessons = completedLessons;
    _totalWordsLearned = totalWordsLearned;
    _totalErrors = totalErrors;
    notifyListeners();
  }
}