import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson_model.dart';

class HeartsService {
  static final HeartsService _i = HeartsService._internal();
  factory HeartsService() => _i;
  HeartsService._internal();

  static const int maxHearts = 5;
  static const int regenMinutes = 30; // 1 cœur toutes les 30 min
  static const int penaltyMinutes = 10; // Pénalité 10 min sans leçon

  /// Calcule les cœurs actuels selon le temps écoulé
  static int calculateCurrentHearts({
    required int savedHearts,
    required DateTime? lastHeartLostAt,
  }) {
    if (savedHearts >= maxHearts) return maxHearts;
    if (lastHeartLostAt == null) return savedHearts;

    final now = DateTime.now();
    final elapsed = now.difference(lastHeartLostAt).inMinutes;
    final regenerated = (elapsed / regenMinutes).floor();
    return (savedHearts + regenerated).clamp(0, maxHearts);
  }

  /// Temps restant avant le prochain cœur (en secondes)
  static int secondsUntilNextHeart({
    required int currentHearts,
    required DateTime? lastHeartLostAt,
  }) {
    if (currentHearts >= maxHearts) return 0;
    if (lastHeartLostAt == null) return regenMinutes * 60;

    final now = DateTime.now();
    final elapsed = now.difference(lastHeartLostAt).inSeconds;
    final secondsPerHeart = regenMinutes * 60;
    final remainder = elapsed % secondsPerHeart;
    return secondsPerHeart - remainder;
  }

  /// Applique la pénalité quand tous les cœurs sont perdus
  static Map<String, dynamic> applyPenalty() {
    return {
      'penaltyEndAt': DateTime.now()
          .add(Duration(minutes: penaltyMinutes)),
      'penaltyMinutes': penaltyMinutes,
    };
  }

  /// Vérifie si la pénalité est encore active
  static bool isPenaltyActive(DateTime? penaltyEndAt) {
    if (penaltyEndAt == null) return false;
    return DateTime.now().isBefore(penaltyEndAt);
  }

  /// Temps restant de pénalité en secondes
  static int penaltySecondsRemaining(DateTime? penaltyEndAt) {
    if (penaltyEndAt == null) return 0;
    final remaining =
        penaltyEndAt.difference(DateTime.now()).inSeconds;
    return remaining.clamp(0, penaltyMinutes * 60);
  }

  /// Sauvegarde dans Firestore
  Future<void> saveHeartsData({
    required String uid,
    required int hearts,
    required DateTime? lastHeartLostAt,
    required DateTime? penaltyEndAt,
  }) async {
    final data = <String, dynamic>{
      'hearts': hearts,
      'lastHeartLostAt': lastHeartLostAt != null
          ? Timestamp.fromDate(lastHeartLostAt)
          : null,
      'penaltyEndAt': penaltyEndAt != null
          ? Timestamp.fromDate(penaltyEndAt)
          : null,
    };
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(data);
  }
}