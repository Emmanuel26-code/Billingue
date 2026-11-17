import 'package:BillingueApp/screens/app/revision_screen.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/lessons_data.dart';
import '../../models/lesson_model.dart';
import '../../widgets/lesson_card.dart';
import 'course_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserProgress progress;
  final String uid;

  const HomeScreen({
    super.key,
    required this.progress,
    required this.uid,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    // Synchronise les cœurs régénérés à chaque ouverture
    widget.progress.syncHearts();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();

    // Écoute les changements automatiques
    widget.progress.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    widget.progress.removeListener(_onProgressChanged);
    _ctrl.dispose();
    super.dispose();
  }

  void _onProgressChanged() {
    if (mounted) setState(() {});
  }

  List<LessonModel> get _lessons {
    final list = List<LessonModel>.from(LessonsData.allLessons);
    for (int i = 0; i < list.length; i++) {
      final done = widget.progress.isLessonCompleted(list[i].id);
      if (i == 0 || done) {
        if (i + 1 < list.length) {
          list[i + 1] = LessonModel(
            id: list[i + 1].id,
            title: list[i + 1].title,
            subtitle: list[i + 1].subtitle,
            emoji: list[i + 1].emoji,
            xpReward: list[i + 1].xpReward,
            isUnlocked: true,
            courseCards: list[i + 1].courseCards,
            questions: list[i + 1].questions,
          );
        }
      }
    }
    return list;
  }

  void _open(LessonModel lesson) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => CourseScreen(
          lesson: lesson,
          progress: widget.progress,
          uid: widget.uid,
        ),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lessons = _lessons;
    final done = widget.progress.completedLessons.length;
    final total = LessonsData.allLessons.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _anim,
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0, -0.15), end: Offset.zero)
                    .animate(_anim),
                child: _Header(
                  progress: widget.progress,
                  done: done,
                  total: total,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RevisionScreen(
                      progress: widget.progress,
                      uid: widget.uid,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.shade400,
                        Colors.purple.shade700,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                          child: Text('🔄', style: TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mode Révision',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                          Text(
                            'Révise les leçons déjà apprises',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 16),
                  ]),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
              child: Row(children: [
                const Text('Unités',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$total leçons',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary)),
                ),
              ]),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final lesson = lessons[i];
                final completed = widget.progress.isLessonCompleted(lesson.id);
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 350 + i * 80),
                  curve: Curves.easeOut,
                  builder: (_, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                        offset: Offset(0, 20 * (1 - v)), child: child),
                  ),
                  child: LessonCard(
                    lesson: lesson,
                    isCompleted: completed,
                    index: i,
                    onTap: () => _open(lesson),
                  ),
                );
              },
              childCount: lessons.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final UserProgress progress;
  final int done;
  final int total;

  const _Header({
    required this.progress,
    required this.done,
    required this.total,
  });

  // XP max pour le niveau actuel
  int get _xpMax {
    if (progress.xp < 100) return 100;
    if (progress.xp < 300) return 300;
    if (progress.xp < 600) return 600;
    if (progress.xp < 1000) return 1000;
    return 2000;
  }

  // XP de départ du niveau actuel
  int get _xpMin {
    if (progress.xp < 100) return 0;
    if (progress.xp < 300) return 100;
    if (progress.xp < 600) return 300;
    if (progress.xp < 1000) return 600;
    return 1000;
  }

  double get _xpProgress {
    final range = _xpMax - _xpMin;
    final current = progress.xp - _xpMin;
    return (current / range).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Billingue',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                      Text('Objectif : ${progress.objectif}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.85))),
                    ],
                  ),
                  // Avatar mis à jour automatiquement
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage: AssetImage(progress.avatar),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(children: [
                _Chip('⚡', '${progress.xp} XP'),
                const SizedBox(width: 8),
                _Chip('🔥', '${progress.streak} jours'),
                const SizedBox(width: 8),
                _Chip('❤️', '${progress.hearts} vies'),
                const SizedBox(width: 8),
                _Chip('📖', '${progress.totalWordsLearned} mots'),
              ]),
              const SizedBox(height: 12),

              // Barre XP dynamique
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('XP : ${progress.xp} / $_xpMax',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  Text('$done/$total leçons',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _xpProgress,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Text('🎯 Défis du jour',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(
                  '${progress.dailyChallenges.where((c) => c.completed).length}/${progress.dailyChallenges.length} complétés',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11),
                ),
              ]),
              const SizedBox(height: 6),
              Row(
                children: progress.dailyChallenges.map((c) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: c.completed
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String icon;
  final String label;
  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11)),
      ]),
    );
  }
}
