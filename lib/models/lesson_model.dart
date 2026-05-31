import 'package:BillingueApp/models/gamification_model.dart';
import 'package:BillingueApp/services/gamification_service.dart';
import 'package:BillingueApp/services/hearts_service.dart';
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
  int _coins;                          // ← AJOUTER
  int _streakFreezes;                  // ← AJOUTER
  int _xpToday;                        // ← AJOUTER
  List<DailyChallenge> _dailyChallenges; // ← AJOUTER
  List<WeeklyQuest> _weeklyQuests;     // ← AJOUTER
  DateTime? _lastActiveDate;  
  DateTime? _lastHeartLostAt;    // ← AJOUTER
  DateTime? _penaltyEndAt;       // ← AJOUTER


  UserProgress({
    int xp = 0,
    int hearts = 5,
    int coins = 0,                          // ← AJOUTER
    int streak = 0,
    String avatar = 'assets/avatars/avatar.png',
    String nom = 'Joueur',
    String objectif = 'Regulier',
    Set<String>? completedLessons,
    int totalWordsLearned = 0,
    int totalErrors = 0,    
    int streakFreezes = 0,                  // ← AJOUTER
    int xpToday = 0,                        // ← AJOUTER
    List<DailyChallenge>? dailyChallenges, // ← AJOUTER
    List<WeeklyQuest>? weeklyQuests,     // ← AJOUTER
    DateTime? lastActiveDate,           // ← AJOUTER
    DateTime? lastHeartLostAt,        // ← AJOUTER
    DateTime? penaltyEndAt,             // ← AJOUTER

  })  : _xp = xp,
        _hearts = hearts,
        _streak = streak,
        _avatar = avatar,
        _nom = nom,
        _objectif = objectif,
        _completedLessons = completedLessons ?? {},
        _totalWordsLearned = totalWordsLearned,
        _totalErrors = totalErrors,
        _coins = coins,
        _streakFreezes = streakFreezes,
        _xpToday = xpToday,
        _dailyChallenges = dailyChallenges ??
            GamificationService.generateDailyChallenges(),
        _weeklyQuests = weeklyQuests ?? 
            GamificationService.generateWeeklyQuests(),
        _lastActiveDate = lastActiveDate,
        _lastHeartLostAt = lastHeartLostAt,
        _penaltyEndAt = penaltyEndAt;

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
  int get coins => _coins;
  int get streakFreezes => _streakFreezes;
  int get xpToday => _xpToday;
  List<DailyChallenge> get dailyChallenges => _dailyChallenges;
  List<WeeklyQuest> get weeklyQuests => _weeklyQuests;
  DateTime? get lastActiveDate => _lastActiveDate;
  DateTime? get lastHeartLostAt => _lastHeartLostAt;
  DateTime? get penaltyEndAt => _penaltyEndAt;

    bool get isPenaltyActive =>
      HeartsService.isPenaltyActive(_penaltyEndAt);

  int get penaltySecondsRemaining =>
      HeartsService.penaltySecondsRemaining(_penaltyEndAt);

  int get secondsUntilNextHeart =>
      HeartsService.secondsUntilNextHeart(
        currentHearts: _hearts,
        lastHeartLostAt: _lastHeartLostAt,
      );

  bool get heartsAreFull => _hearts >= 5;

    // Niveau calculé automatiquement
  UserLevel get level =>
      GamificationService.getLevelFromXP(_xp);
  double get levelProgress =>
      GamificationService.getLevelProgress(_xp);
  League get league =>
      GamificationService.getLeagueFromXP(_xp);



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

  set coins(int value) {
    _coins = value;
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

  void addError() {
    _totalErrors++;
    notifyListeners();
  }

  void syncHearts() {
    final newHearts = HeartsService.calculateCurrentHearts(
      savedHearts: _hearts,
      lastHeartLostAt: _lastHeartLostAt,
    );
    if (newHearts != _hearts) {
      _hearts = newHearts;
      notifyListeners();
    }
  }

  /// Perd un cœur avec gestion régénération + pénalité
  void loseHeart() {
    syncHearts(); // Regénère d'abord

    if (_hearts > 0) {
      _hearts--;
      _lastHeartLostAt = DateTime.now();
      _totalErrors++;

      // Pénalité si tous les cœurs perdus
      if (_hearts == 0) {
        _penaltyEndAt = DateTime.now().add(
          Duration(minutes: HeartsService.penaltyMinutes),
        );
      }
      notifyListeners();
    }
  }

  /// Recharge les cœurs (achat ou récompense)
  void refillHearts() {
    _hearts = 5;
    _lastHeartLostAt = null;
    _penaltyEndAt = null;
    notifyListeners();
  }

  bool buyStreakFreeze() {
    if (_coins >= 50) {
      _coins -= 50;
      _streakFreezes++;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool repairStreak() {
    if (_coins >= 100) {
      _coins -= 100;
      _streak = 1;
      notifyListeners();
      return true;
    }
    return false;
  }

  void checkAndUpdateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastActiveDate == null) {
      _streak = 1;
      _lastActiveDate = today;
      _xpToday = 0;
      notifyListeners();
      return;
    }

    final lastDay = DateTime(
      _lastActiveDate!.year,
      _lastActiveDate!.month,
      _lastActiveDate!.day,
    );
    final diff = today.difference(lastDay).inDays;

    if (diff == 0) {
      // Même jour : rien à faire
    } else if (diff == 1) {
      _streak++;
      _lastActiveDate = today;
    } else {
      if (_streakFreezes > 0) {
        _streakFreezes--;
        _lastActiveDate = today;
      } else {
        _streak = 1;
        _lastActiveDate = today;
      }
    }

    _xpToday = 0;
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
    required int coins,
    required int streakFreezes,
    required int xpToday,
    required List<DailyChallenge> dailyChallenges,
    required List<WeeklyQuest> weeklyQuests,
    DateTime? lastActiveDate,
    DateTime? lastHeartLostAt,
    DateTime? penaltyEndAt,
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
    _coins = coins;
    _streakFreezes = streakFreezes;
    _xpToday = xpToday;
    _dailyChallenges = dailyChallenges;
    _weeklyQuests = weeklyQuests;
    _lastActiveDate = lastActiveDate;
    _lastHeartLostAt = lastHeartLostAt;
    _penaltyEndAt = penaltyEndAt;
    notifyListeners();
  }
}