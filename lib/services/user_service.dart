import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'users';

  Future<void> createUser(UserModel user) async {
    await _db
        .collection(_collection)
        .doc(user.uid)
        .set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc =
          await _db.collection(_collection).doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, uid);
    } catch (e) {
      return null;
    }
  }

  // Sauvegarde complète de la progression
  Future<void> saveProgress({
    required String uid,
    required int xp,
    required int hearts,
    required int streak,
    required List<String> completedLessons,
    required int totalWordsLearned,
    required int totalErrors,
    int coins = 0,
    int streakFreezes = 0,
    int xpToday = 0,
    DateTime? lastHeartLostAt,
    DateTime? penaltyEndAt,
  }) async {
    await _db.collection(_collection).doc(uid).update({
      'xp': xp,
      'hearts': hearts,
      'streak': streak,
      'completedLessons': completedLessons,
      'totalWordsLearned': totalWordsLearned,
      'totalErrors': totalErrors,
      'coins': coins,
      'streakFreezes': streakFreezes,
      'xpToday': xpToday,
      'lastHeartLostAt': lastHeartLostAt != null
          ? Timestamp.fromDate(lastHeartLostAt!)
          : null,
      'penaltyEndAt': penaltyEndAt != null
          ? Timestamp.fromDate(penaltyEndAt!)
          : null,
    });
  }

  Future<void> updateAvatar({
    required String uid,
    required String avatar,
  }) async {
    await _db
        .collection(_collection)
        .doc(uid)
        .update({'avatar': avatar});
  }

  Future<void> updateObjectif({
    required String uid,
    required String objectif,
  }) async {
    await _db
        .collection(_collection)
        .doc(uid)
        .update({'objectif': objectif});
  }

  Future<void> completeLesson({
    required String uid,
    required String lessonId,
    required int xpGained,
    required int wordsLearned,
    required int errors,
  }) async {
    await _db.collection(_collection).doc(uid).update({
      'completedLessons': FieldValue.arrayUnion([lessonId]),
      'xp': FieldValue.increment(xpGained),
      'totalWordsLearned': FieldValue.increment(wordsLearned),
      'totalErrors': FieldValue.increment(errors),
    });
  }

  Stream<UserModel?> userStream(String uid) {
    return _db
        .collection(_collection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, uid);
    });
  }
}