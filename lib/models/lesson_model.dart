enum QuestionType { multipleChoice, trueFalse, pronunciation }

// --- Carte de cours (phase apprentissage) ---
class CourseCard {
  final String baoule;
  final String francais;
  final String? exemple;        // Phrase d'exemple optionnelle
  final String? exempeFr;       // Traduction de l'exemple

  const CourseCard({
    required this.baoule,
    required this.francais,
    this.exemple,
    this.exempeFr,
  });
}

// --- Question de quiz ---
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

// --- Leçon complète (cours + quiz) ---
class LessonModel {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final int xpReward;
  final bool isUnlocked;
  final List<CourseCard> courseCards;   // Phase cours
  final List<QuestionModel> questions;  // Phase quiz

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
}

// --- Progression utilisateur ---
class UserProgress {
  int xp;
  int hearts;
  int streak;
  String avatar;
  String nom;  // ← AJOUTER
  Set<String> completedLessons;

  UserProgress({
    this.xp = 0,
    this.hearts = 5,
    this.streak = 0,
    this.avatar = 'assets/avatars/avatar.png',
    this.nom = 'Joueur',   // ← AJOUTER


    Set<String>? completedLessons,
  }) : completedLessons = completedLessons ?? {};

  bool isLessonCompleted(String id) => completedLessons.contains(id);
  void completeLesson(String id) => completedLessons.add(id);
}