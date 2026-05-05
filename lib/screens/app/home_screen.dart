import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/lessons_data.dart';
import '../../models/lesson_model.dart';
import '../../widgets/lesson_card.dart';
import 'lesson_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserProgress progress;
  final VoidCallback? onChanged;

  const HomeScreen({super.key, required this.progress, this.onChanged});

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
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
        pageBuilder: (_, anim, __) =>
            LessonScreen(lesson: lesson, progress: widget.progress),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
    setState(() {});
    widget.onChanged?.call();
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
                    total: total),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
              child: Row(children: [
                const Text('Unités',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
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
                final completed =
                    widget.progress.isLessonCompleted(lesson.id);
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

  const _Header(
      {required this.progress, required this.done, required this.total});

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
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Billingue',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    Text('Apprends le Baoulé chaque jour',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85))),
                  ]),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Text('🧑🏾',
                        style: TextStyle(fontSize: 22)),
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
              ]),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Progression',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                Text('$done/$total leçons',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: total > 0 ? done / total : 0,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12)),
      ]),
    );
  }
}