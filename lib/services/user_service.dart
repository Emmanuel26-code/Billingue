import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'users';

  // ── Créer un utilisateur ──────────────────────────────────────────────────
  Future<void> createUser(UserModel user) async {
    await _db
        .collection(_collection)
        .doc(user.uid)
        .set(user.toMap());
  }

  // ── Lire un utilisateur ───────────────────────────────────────────────────
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

  // ── Mettre à jour la progression ─────────────────────────────────────────
  Future<void> updateProgress({
    required String uid,
    required int xp,
    required int hearts,
    required int streak,
    required List<String> completedLessons,
  }) async {
    await _db.collection(_collection).doc(uid).update({
      'xp': xp,
      'hearts': hearts,
      'streak': streak,
      'completedLessons': completedLessons,
    });
  }

  // ── Mettre à jour l'avatar ────────────────────────────────────────────────
  Future<void> updateAvatar({
    required String uid,
    required String avatar,
  }) async {
    await _db
        .collection(_collection)
        .doc(uid)
        .update({'avatar': avatar});
  }

  // ── Mettre à jour l'objectif ─────────────────────────────────────────────
  Future<void> updateObjectif({
    required String uid,
    required String objectif,
  }) async {
    await _db
        .collection(_collection)
        .doc(uid)
        .update({'objectif': objectif});
  }

  // ── Sauvegarder leçon complétée ──────────────────────────────────────────
  Future<void> completeLesson({
    required String uid,
    required String lessonId,
    required int xpGained,
  }) async {
    await _db.collection(_collection).doc(uid).update({
      'completedLessons': FieldValue.arrayUnion([lessonId]),
      'xp': FieldValue.increment(xpGained),
    });
  }

  // ── Stream de l'utilisateur (temps réel) ─────────────────────────────────
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