import 'dart:math';
import 'package:BillingueApp/models/gamification_model.dart';
import 'package:flutter/material.dart' hide Badge;
import '../../core/theme.dart';
import '../../models/lesson_model.dart';
import '../../services/gamification_service.dart';
import '../../services/user_service.dart';
import '../../services/notification_service.dart';
import '../../services/badge_service.dart';
import '../../data/lessons_data.dart';
import '../../widgets/badge_notification.dart';
import 'main_screen.dart';

class ResultScreen extends StatefulWidget {
  final LessonModel lesson;
  final int correctCount;
  final int totalQuestions;
  final int earnedXP;
  final int accuracy;
  final UserProgress progress;
  final String uid;
  final int errorCount;

  /// Badges déjà obtenus avant la leçon (pour annoncer les nouveaux).
  final Set<String> badgesBefore;

  /// true si la leçon est terminée pour la première fois.
  final bool firstCompletion;

  const ResultScreen({
    super.key,
    required this.lesson,
    required this.correctCount,
    required this.totalQuestions,
    required this.earnedXP,
    required this.accuracy,
    required this.progress,
    required this.uid,
    required this.errorCount,
    this.badgesBefore = const {},
    this.firstCompletion = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _main;
  late AnimationController _confetti;
  late AnimationController _xpCtrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<double> _xp;
  final List<_Particle> _particles = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 55; i++) {
      _particles.add(_Particle(_rnd));
    }
    _main = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800));
    _confetti = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2500));
    _xpCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200));
    _scale = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
            parent: _main, curve: Curves.elasticOut));
    _fade = CurvedAnimation(
        parent: _main,
        curve: const Interval(0, 0.5));
    _xp = Tween<double>(
            begin: 0,
            end: widget.earnedXP.toDouble())
        .animate(CurvedAnimation(
            parent: _xpCtrl, curve: Curves.easeOut));
    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _main.forward();
    if (widget.accuracy >= 70) _confetti.repeat();
    await Future.delayed(const Duration(milliseconds: 600));
    _xpCtrl.forward();

    // Mise à jour défis et quêtes
    GamificationService.updateChallengesAfterLesson(
      challenges: widget.progress.dailyChallenges,
      quests: widget.progress.weeklyQuests,
      xpEarned: widget.earnedXP,
      wordsLearned: widget.lesson.courseCards.length,
      isPerfect: widget.accuracy == 100,
      streak: widget.progress.streak,
    );

    // Vérifie la série
    widget.progress.checkAndUpdateStreak();

    // Sauvegarde Firestore
    if (widget.uid.isNotEmpty) {
      await UserService().completeLesson(
        uid: widget.uid,
        lessonId: widget.lesson.id,
        xpGained: widget.earnedXP,
        wordsLearned: widget.lesson.courseCards.length,
        errors: widget.errorCount,
      );
      await GamificationService().saveGamificationData(
        uid: widget.uid,
        coins: widget.progress.coins,
        streakFreezes: widget.progress.streakFreezes,
        dailyChallenges: widget.progress.dailyChallenges,
        weeklyQuests: widget.progress.weeklyQuests,
        league: widget.progress.league.label,
      );

      // Notification de félicitation
      await NotificationService()
          .showCongrats(widget.lesson.title);
    }

    if (!mounted) return;
    await _announceNewLesson();
    await _announceNewBadges();
  }

  /// « Nouvelle leçon disponible » : la leçon suivante vient d'être débloquée.
  /// (La 2e leçon est ouverte d'office, donc on ne l'annonce pas.)
  Future<void> _announceNewLesson() async {
    if (!widget.firstCompletion) return;
    final all = LessonsData.allLessons;
    final i = all.indexWhere((l) => l.id == widget.lesson.id);
    if (i < 1 || i + 1 >= all.length) return;
    final next = all[i + 1];
    if (widget.progress.isLessonCompleted(next.id)) return;

    await NotificationService().showNewLesson(next.title);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('📚 Nouvelle leçon disponible : ${next.title}'),
      backgroundColor: AppTheme.primary,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  /// « Badge obtenu » : bannière dans l'app + notification système.
  Future<void> _announceNewBadges() async {
    final earned = BadgeService()
        .getBadges(widget.progress)
        .where((b) => b.earned && !widget.badgesBefore.contains(b.id));
    for (final Badge badge in earned) {
      if (!mounted) return;
      showBadgeNotification(context, badge);
      await NotificationService().showBadgeEarned(badge.emoji, badge.title);
      // Une bannière à la fois.
      await Future.delayed(const Duration(milliseconds: 3500));
    }
  }

  @override
  void dispose() {
    _main.dispose();
    _confetti.dispose();
    _xpCtrl.dispose();
    super.dispose();
  }

  String get _emoji {
    if (widget.accuracy >= 90) return '🏆';
    if (widget.accuracy >= 70) return '🌟';
    if (widget.accuracy >= 50) return '👏';
    return '💪';
  }

  String get _msg {
    if (widget.accuracy >= 90) return 'Parfait !';
    if (widget.accuracy >= 70) return 'Bien joué !';
    if (widget.accuracy >= 50) return 'Pas mal !';
    return 'Continue d\'essayer !';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          if (widget.accuracy >= 70)
            AnimatedBuilder(
              animation: _confetti,
              builder: (_, __) => CustomPaint(
                painter: _ConfettiPainter(
                    particles: _particles,
                    t: _confetti.value),
                child: const SizedBox.expand(),
              ),
            ),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  ScaleTransition(
                    scale: _scale,
                    child: Text(_emoji,
                        style:
                            const TextStyle(fontSize: 88)),
                  ),
                  const SizedBox(height: 16),
                  Text(_msg,
                      style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(
                      'Leçon "${widget.lesson.title}" terminée !',
                      style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.textGrey)),
                  const SizedBox(height: 44),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24),
                    child: Row(children: [
                      _StatBox(
                        icon: '⚡',
                        label: 'XP gagnés',
                        child: AnimatedBuilder(
                          animation: _xp,
                          builder: (_, __) => Text(
                            '+${_xp.value.round()}',
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StatBox(
                        icon: '🎯',
                        label: 'Précision',
                        child: Text('${widget.accuracy}%',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: widget.accuracy >= 70
                                    ? AppTheme.secondary
                                    : AppTheme.danger)),
                      ),
                      const SizedBox(width: 10),
                      _StatBox(
                        icon: '✅',
                        label: 'Correctes',
                        child: Text(
                            '${widget.correctCount}/${widget.totalQuestions}',
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.secondary)),
                      ),
                    ]),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        24, 0, 24, 32),
                    child: Column(children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => MainScreen(
                                      progress:
                                          widget.progress,
                                      uid: widget.uid,
                                    )),
                            (_) => false,
                          ),
                          child: const Text('Continuer 🚀'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: Text('Refaire la leçon',
                            style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight:
                                    FontWeight.w700)),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String icon;
  final String label;
  final Widget child;
  const _StatBox(
      {required this.icon,
      required this.label,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(children: [
          Text(icon,
              style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          child,
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textGrey),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _Particle {
  final double x;
  final double speed;
  final double size;
  final Color color;
  final double rot;

  _Particle(Random r)
      : x = r.nextDouble(),
        speed = 0.3 + r.nextDouble() * 0.7,
        size = 6 + r.nextDouble() * 9,
        rot = r.nextDouble() * 4,
        color = [
          AppTheme.primary,
          AppTheme.secondary,
          const Color(0xFFF4D03F),
          AppTheme.danger,
          Colors.purple,
          Colors.blue,
        ][r.nextInt(6)];
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  const _ConfettiPainter(
      {required this.particles, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final y =
          (t * p.speed * size.height * 1.5) % (size.height + 20);
      paint.color = p.color.withValues(alpha: 1 - t * 0.5);
      canvas.save();
      canvas.translate(p.x * size.width, y);
      canvas.rotate(t * p.rot * pi * 2);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.5),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}