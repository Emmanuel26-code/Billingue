import 'lesson_model.dart';

class UserModel {
  final String uid;
  final String nom;
  final String prenom;
  final String email;
  final String age;
  final String avatar;
  final String objectif;
  final int xp;
  final int hearts;
  final int streak;
  final List<String> completedLessons;
  final int totalWordsLearned;
  final int totalErrors;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.age,
    this.avatar = 'assets/avatars/avatar.png',
    this.objectif = 'Regulier',
    this.xp = 0,
    this.hearts = 5,
    this.streak = 0,
    this.completedLessons = const [],
    this.totalWordsLearned = 0,
    this.totalErrors = 0,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? '',
      avatar: map['avatar'] ?? 'assets/avatars/avatar.png',
      objectif: map['objectif'] ?? 'Regulier',
      xp: map['xp'] ?? 0,
      hearts: map['hearts'] ?? 5,
      streak: map['streak'] ?? 0,
      completedLessons:
          List<String>.from(map['completedLessons'] ?? []),
      totalWordsLearned: map['totalWordsLearned'] ?? 0,
      totalErrors: map['totalErrors'] ?? 0,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'age': age,
      'avatar': avatar,
      'objectif': objectif,
      'xp': xp,
      'hearts': hearts,
      'streak': streak,
      'completedLessons': completedLessons,
      'totalWordsLearned': totalWordsLearned,
      'totalErrors': totalErrors,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? nom,
    String? prenom,
    String? email,
    String? age,
    String? avatar,
    String? objectif,
    int? xp,
    int? hearts,
    int? streak,
    List<String>? completedLessons,
    int? totalWordsLearned,
    int? totalErrors,
  }) {
    return UserModel(
      uid: uid,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      age: age ?? this.age,
      avatar: avatar ?? this.avatar,
      objectif: objectif ?? this.objectif,
      xp: xp ?? this.xp,
      hearts: hearts ?? this.hearts,
      streak: streak ?? this.streak,
      completedLessons: completedLessons ?? this.completedLessons,
      totalWordsLearned:
          totalWordsLearned ?? this.totalWordsLearned,
      totalErrors: totalErrors ?? this.totalErrors,
      createdAt: createdAt,
    );
  }

  UserProgress toUserProgress() {
    return UserProgress(
      xp: xp,
      hearts: hearts,
      streak: streak,
      avatar: avatar,
      nom: '$prenom $nom',
      objectif: objectif,
      completedLessons: completedLessons.toSet(),
      totalWordsLearned: totalWordsLearned,
      totalErrors: totalErrors,
    );
  }
}