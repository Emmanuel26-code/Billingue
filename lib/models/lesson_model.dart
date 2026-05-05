enum QuestionType { multipleChoice }

class LessonModel {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final int xpReward;
  final bool isUnlocked;
  final List<QuestionModel> questions;

  const LessonModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.xpReward,
    this.isUnlocked = false,
    required this.questions,
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

class UserProgress {
  int xp;
  int hearts;
  int streak;
  Set<String> completedLessons;

  UserProgress({
    this.xp = 0,
    this.hearts = 5,
    this.streak = 0,
    Set<String>? completedLessons,
  }) : completedLessons = completedLessons ?? {};

  bool isLessonCompleted(String id) => completedLessons.contains(id);
  void completeLesson(String id) => completedLessons.add(id);
}