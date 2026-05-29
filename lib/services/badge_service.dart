import '../models/lesson_model.dart';

class Badge {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final bool earned;

  const Badge({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.earned,
  });
}

class BadgeService {
  static final BadgeService _instance = BadgeService._internal();
  factory BadgeService() => _instance;
  BadgeService._internal();

  List<Badge> getBadges(UserProgress progress) {
    return [
      // XP
      Badge(
        id: 'xp_100',
        emoji: '⚡',
        title: 'Premier 100 XP',
        description: 'Atteins 100 XP',
        earned: progress.xp >= 100,
      ),
      Badge(
        id: 'xp_500',
        emoji: '🔋',
        title: '500 XP',
        description: 'Atteins 500 XP',
        earned: progress.xp >= 500,
      ),
      Badge(
        id: 'xp_1000',
        emoji: '💎',
        title: '1000 XP',
        description: 'Atteins 1000 XP',
        earned: progress.xp >= 1000,
      ),

      // Leçons
      Badge(
        id: 'first_lesson',
        emoji: '🎓',
        title: 'Première Leçon',
        description: 'Complète ta première leçon',
        earned: progress.completedLessons.isNotEmpty,
      ),
      Badge(
        id: 'five_lessons',
        emoji: '📚',
        title: '5 Leçons',
        description: 'Complète 5 leçons',
        earned: progress.completedLessons.length >= 5,
      ),
      Badge(
        id: 'all_lessons',
        emoji: '🏆',
        title: 'Expert Baoulé',
        description: 'Complète toutes les leçons',
        earned: progress.completedLessons.length >= 11,
      ),

      // Série
      Badge(
        id: 'streak_3',
        emoji: '🔥',
        title: '3 Jours de suite',
        description: 'Apprends 3 jours de suite',
        earned: progress.streak >= 3,
      ),
      Badge(
        id: 'streak_7',
        emoji: '🌟',
        title: '7 Jours de suite',
        description: 'Apprends 7 jours de suite',
        earned: progress.streak >= 7,
      ),
      Badge(
        id: 'streak_30',
        emoji: '👑',
        title: '30 Jours de suite',
        description: 'Un mois sans interruption !',
        earned: progress.streak >= 30,
      ),

      // Mots
      Badge(
        id: 'words_50',
        emoji: '📖',
        title: '50 Mots appris',
        description: 'Apprends 50 mots en Baoulé',
        earned: progress.totalWordsLearned >= 50,
      ),
      Badge(
        id: 'words_100',
        emoji: '🗣️',
        title: '100 Mots appris',
        description: 'Apprends 100 mots en Baoulé',
        earned: progress.totalWordsLearned >= 100,
      ),

      // Spéciaux
      Badge(
        id: 'no_error',
        emoji: '💯',
        title: 'Parfait',
        description: 'Termine une leçon sans erreur',
        earned: progress.totalErrors == 0 &&
            progress.completedLessons.isNotEmpty,
      ),
      Badge(
        id: 'ci_pride',
        emoji: '🇨🇮',
        title: 'Fierté Ivoirienne',
        description: 'Apprends ta première salutation',
        earned:
            progress.isLessonCompleted('greetings'),
      ),
    ];
  }

  // Vérifie si un nouveau badge a été débloqué
  List<Badge> checkNewBadges(
      UserProgress oldProgress, UserProgress newProgress) {
    final oldBadges = getBadges(oldProgress)
        .where((b) => b.earned)
        .map((b) => b.id)
        .toSet();
    final newBadges =
        getBadges(newProgress).where((b) => b.earned).toList();
    return newBadges
        .where((b) => !oldBadges.contains(b.id))
        .toList();
  }
}