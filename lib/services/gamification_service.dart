import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gamification_model.dart';
import '../models/lesson_model.dart';

class GamificationService {
  static final GamificationService _i =
      GamificationService._internal();
  factory GamificationService() => _i;
  GamificationService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Niveau ────────────────────────────────────────────────────────────────
  static UserLevel getLevelFromXP(int xp) {
    if (xp >= 5000) return UserLevel.legende;
    if (xp >= 2000) return UserLevel.maitre;
    if (xp >= 1000) return UserLevel.expert;
    if (xp >= 600)  return UserLevel.avance;
    if (xp >= 300)  return UserLevel.intermediaire;
    if (xp >= 100)  return UserLevel.apprenti;
    return UserLevel.debutant;
  }

  static double getLevelProgress(int xp) {
    final level = getLevelFromXP(xp);
    if (level == UserLevel.legende) return 1.0;
    final current = level.xpRequired;
    final next = level.xpForNext;
    return ((xp - current) / (next - current)).clamp(0.0, 1.0);
  }

  // ── Ligue ─────────────────────────────────────────────────────────────────
  static League getLeagueFromXP(int xp) {
    if (xp >= 5000) return League.champion;
    if (xp >= 2000) return League.maitre;
    if (xp >= 1000) return League.diamant;
    if (xp >= 500)  return League.platine;
    if (xp >= 200)  return League.or;
    if (xp >= 100)  return League.argent;
    return League.bronze;
  }

  // ── XP avec bonus ─────────────────────────────────────────────────────────
  static int calculateXP({
    required int baseXP,
    required int correctCount,
    required int totalQuestions,
    required int timeSeconds,
    required int streak,
  }) {
    double multiplier = 1.0;

    // Bonus précision
    final accuracy = correctCount / totalQuestions;
    if (accuracy == 1.0) multiplier += 0.5;      // +50% parfait
    else if (accuracy >= 0.9) multiplier += 0.3; // +30%
    else if (accuracy >= 0.7) multiplier += 0.1; // +10%

    // Bonus vitesse (moins de 30 secondes par question)
    final avgTime = timeSeconds / totalQuestions;
    if (avgTime < 10) multiplier += 0.3;
    else if (avgTime < 20) multiplier += 0.15;

    // Bonus série
    if (streak >= 30) multiplier += 0.5;
    else if (streak >= 7) multiplier += 0.3;
    else if (streak >= 3) multiplier += 0.1;

    return (baseXP * multiplier).round();
  }

  // ── Pièces ────────────────────────────────────────────────────────────────
  static int calculateCoins({
    required int xpEarned,
    required bool isPerfect,
  }) {
    int coins = (xpEarned * 0.5).round();
    if (isPerfect) coins += 10;
    return coins;
  }

  // ── Défis quotidiens ──────────────────────────────────────────────────────
  static List<DailyChallenge> generateDailyChallenges() {
    final now = DateTime.now();
    // Seed basé sur le jour pour cohérence
    final seed = now.day + now.month * 31;

    final allChallenges = [
      DailyChallenge(
        id: 'xp_50',
        title: 'Collecteur d\'XP',
        description: 'Gagne 50 XP aujourd\'hui',
        emoji: '⚡',
        target: 50,
        xpReward: 20,
        coinsReward: 10,
      ),
      DailyChallenge(
        id: 'lessons_2',
        title: 'Apprenant assidu',
        description: 'Complète 2 leçons',
        emoji: '📚',
        target: 2,
        xpReward: 30,
        coinsReward: 15,
      ),
      DailyChallenge(
        id: 'perfect',
        title: 'Perfectionniste',
        description: 'Obtiens 100% dans une leçon',
        emoji: '💯',
        target: 1,
        xpReward: 50,
        coinsReward: 25,
      ),
      DailyChallenge(
        id: 'words_10',
        title: 'Vocabulaire',
        description: 'Apprends 10 nouveaux mots',
        emoji: '🔤',
        target: 10,
        xpReward: 25,
        coinsReward: 12,
      ),
      DailyChallenge(
        id: 'streak',
        title: 'Série en feu',
        description: 'Maintiens ta série aujourd\'hui',
        emoji: '🔥',
        target: 1,
        xpReward: 15,
        coinsReward: 8,
      ),
    ];

    // Sélectionne 3 défis basés sur le jour
    final indices = [
      seed % allChallenges.length,
      (seed + 2) % allChallenges.length,
      (seed + 4) % allChallenges.length,
    ];

    return indices.map((i) => allChallenges[i]).toList();
  }

  // ── Quêtes hebdomadaires ──────────────────────────────────────────────────
  static List<WeeklyQuest> generateWeeklyQuests() {
    return [
      WeeklyQuest(
        id: 'xp_500',
        title: 'Guerrier XP',
        description: 'Gagne 500 XP cette semaine',
        emoji: '⚡',
        target: 500,
        xpReward: 100,
        coinsReward: 50,
      ),
      WeeklyQuest(
        id: 'lessons_5',
        title: 'Marathon de leçons',
        description: 'Complète 5 leçons',
        emoji: '🎓',
        target: 5,
        xpReward: 150,
        coinsReward: 75,
      ),
      WeeklyQuest(
        id: 'streak_7',
        title: '7 jours consécutifs',
        description: 'Apprends 7 jours de suite',
        emoji: '🔥',
        target: 7,
        xpReward: 200,
        coinsReward: 100,
      ),
    ];
  }

  // ── Coffres ───────────────────────────────────────────────────────────────
  static List<RewardChest> generateChests() {
    final now = DateTime.now();
    return [
      RewardChest(
        id: 'daily_${now.day}',
        type: 'daily',
        emoji: '🎁',
        title: 'Coffre Quotidien',
        xpReward: 25,
        coinsReward: 15,
        availableAt: DateTime(now.year, now.month, now.day),
      ),
      RewardChest(
        id: 'weekly_${now.weekOfYear}',
        type: 'weekly',
        emoji: '🏆',
        title: 'Coffre Hebdomadaire',
        xpReward: 100,
        coinsReward: 60,
        availableAt: DateTime(
          now.year,
          now.month,
          now.day - now.weekday + 1,
        ),
      ),
    ];
  }

  // ── Sauvegarde Firestore ───────────────────────────────────────────────────
  Future<void> saveGamificationData({
    required String uid,
    required int coins,
    required int streakFreezes,
    required List<DailyChallenge> dailyChallenges,
    required List<WeeklyQuest> weeklyQuests,
    required String league,
  }) async {
    await _db.collection('users').doc(uid).update({
      'coins': coins,
      'streakFreezes': streakFreezes,
      'dailyChallenges':
          dailyChallenges.map((c) => c.toMap()).toList(),
      'weeklyQuests':
          weeklyQuests.map((q) => q.toMap()).toList(),
      'league': league,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  // ── Mise à jour des défis après leçon ────────────────────────────────────
  static void updateChallengesAfterLesson({
    required List<DailyChallenge> challenges,
    required List<WeeklyQuest> quests,
    required int xpEarned,
    required int wordsLearned,
    required bool isPerfect,
    required int streak,
  }) {
    for (final c in challenges) {
      if (c.completed) continue;
      switch (c.id) {
        case 'xp_50':
          c.current = (c.current + xpEarned).clamp(0, c.target);
          break;
        case 'lessons_2':
          c.current = (c.current + 1).clamp(0, c.target);
          break;
        case 'perfect':
          if (isPerfect) c.current = 1;
          break;
        case 'words_10':
          c.current =
              (c.current + wordsLearned).clamp(0, c.target);
          break;
        case 'streak':
          if (streak >= 1) c.current = 1;
          break;
      }
      if (c.current >= c.target) c.completed = true;
    }

    for (final q in quests) {
      if (q.completed) continue;
      switch (q.id) {
        case 'xp_500':
          q.current = (q.current + xpEarned).clamp(0, q.target);
          break;
        case 'lessons_5':
          q.current = (q.current + 1).clamp(0, q.target);
          break;
        case 'streak_7':
          q.current = streak.clamp(0, q.target);
          break;
      }
      if (q.current >= q.target) q.completed = true;
    }
  }
}

extension on DateTime {
  int get weekOfYear {
    final startOfYear = DateTime(year, 1, 1);
    final diff = difference(startOfYear);
    return (diff.inDays / 7).ceil();
  }
}