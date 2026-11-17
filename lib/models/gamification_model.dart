// ── Niveaux ───────────────────────────────────────────────────────────────────
import 'dart:ui';

enum UserLevel {
  debutant,
  apprenti,
  intermediaire,
  avance,
  expert,
  maitre,
  legende,
}

extension UserLevelExt on UserLevel {
  String get label {
    switch (this) {
      case UserLevel.debutant:      return 'Débutant';
      case UserLevel.apprenti:      return 'Apprenti';
      case UserLevel.intermediaire: return 'Intermédiaire';
      case UserLevel.avance:        return 'Avancé';
      case UserLevel.expert:        return 'Expert';
      case UserLevel.maitre:        return 'Maître';
      case UserLevel.legende:       return 'Légende';
    }
  }

  String get emoji {
    switch (this) {
      case UserLevel.debutant:      return '🌱';
      case UserLevel.apprenti:      return '📚';
      case UserLevel.intermediaire: return '✏️';
      case UserLevel.avance:        return '🎯';
      case UserLevel.expert:        return '🚀';
      case UserLevel.maitre:        return '👑';
      case UserLevel.legende:       return '🌟';
    }
  }

  int get xpRequired {
    switch (this) {
      case UserLevel.debutant:      return 0;
      case UserLevel.apprenti:      return 100;
      case UserLevel.intermediaire: return 300;
      case UserLevel.avance:        return 600;
      case UserLevel.expert:        return 1000;
      case UserLevel.maitre:        return 2000;
      case UserLevel.legende:       return 5000;
    }
  }

  int get xpForNext {
    switch (this) {
      case UserLevel.debutant:      return 100;
      case UserLevel.apprenti:      return 300;
      case UserLevel.intermediaire: return 600;
      case UserLevel.avance:        return 1000;
      case UserLevel.expert:        return 2000;
      case UserLevel.maitre:        return 5000;
      case UserLevel.legende:       return 5000;
    }
  }
}

// ── Ligues ────────────────────────────────────────────────────────────────────
enum League {
  bronze,
  argent,
  or,
  platine,
  diamant,
  maitre,
  champion,
}

extension LeagueExt on League {
  String get label {
    switch (this) {
      case League.bronze:   return 'Bronze';
      case League.argent:   return 'Argent';
      case League.or:       return 'Or';
      case League.platine:  return 'Platine';
      case League.diamant:  return 'Diamant';
      case League.maitre:   return 'Maître';
      case League.champion: return 'Champion';
    }
  }

  String get emoji {
    switch (this) {
      case League.bronze:   return '🥉';
      case League.argent:   return '🥈';
      case League.or:       return '🥇';
      case League.platine:  return '💠';
      case League.diamant:  return '💎';
      case League.maitre:   return '👑';
      case League.champion: return '🏆';
    }
  }

  Color get color {
    switch (this) {
      case League.bronze:   return const Color(0xFFCD7F32);
      case League.argent:   return const Color(0xFFC0C0C0);
      case League.or:       return const Color(0xFFFFD700);
      case League.platine:  return const Color(0xFF00CED1);
      case League.diamant:  return const Color(0xFF87CEEB);
      case League.maitre:   return const Color(0xFF9B59B6);
      case League.champion: return const Color(0xFFFF6B00);
    }
  }
}

// ── Défi quotidien ────────────────────────────────────────────────────────────
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int target;
  int current;
  final int xpReward;
  final int coinsReward;
  bool completed;
  bool claimed; // récompense déjà réclamée

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.target,
    this.current = 0,
    required this.xpReward,
    required this.coinsReward,
    this.completed = false,
    this.claimed = false,
  });

  double get progress =>
      (current / target).clamp(0.0, 1.0);

  factory DailyChallenge.fromMap(Map<String, dynamic> m) {
    return DailyChallenge(
      id: m['id'],
      title: m['title'],
      description: m['description'],
      emoji: m['emoji'],
      target: m['target'],
      current: m['current'] ?? 0,
      xpReward: m['xpReward'],
      coinsReward: m['coinsReward'],
      completed: m['completed'] ?? false,
      claimed: m['claimed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'emoji': emoji,
    'target': target,
    'current': current,
    'xpReward': xpReward,
    'coinsReward': coinsReward,
    'completed': completed,
    'claimed': claimed,
  };
}

// ── Quête hebdomadaire ────────────────────────────────────────────────────────
class WeeklyQuest {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int target;
  int current;
  final int xpReward;
  final int coinsReward;
  bool completed;

  WeeklyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.target,
    this.current = 0,
    required this.xpReward,
    required this.coinsReward,
    this.completed = false,
  });

  double get progress =>
      (current / target).clamp(0.0, 1.0);

  factory WeeklyQuest.fromMap(Map<String, dynamic> m) {
    return WeeklyQuest(
      id: m['id'],
      title: m['title'],
      description: m['description'],
      emoji: m['emoji'],
      target: m['target'],
      current: m['current'] ?? 0,
      xpReward: m['xpReward'],
      coinsReward: m['coinsReward'],
      completed: m['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'emoji': emoji,
    'target': target,
    'current': current,
    'xpReward': xpReward,
    'coinsReward': coinsReward,
    'completed': completed,
  };
}

// ── Coffre ────────────────────────────────────────────────────────────────────
class RewardChest {
  final String id;
  final String type; // daily, weekly, event
  final String emoji;
  final String title;
  final int xpReward;
  final int coinsReward;
  bool claimed;
  final DateTime availableAt;

  RewardChest({
    required this.id,
    required this.type,
    required this.emoji,
    required this.title,
    required this.xpReward,
    required this.coinsReward,
    this.claimed = false,
    required this.availableAt,
  });

  bool get isAvailable =>
      !claimed && DateTime.now().isAfter(availableAt);
}

// ── Freeze de série ───────────────────────────────────────────────────────────
class StreakFreeze {
  int count;
  StreakFreeze({this.count = 0});
}