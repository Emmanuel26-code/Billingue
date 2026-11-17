import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/lessons_data.dart';
import '../../models/lesson_model.dart';

class StatsScreen extends StatefulWidget {
  final UserProgress progress;
  const StatsScreen({super.key, required this.progress});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Calculs stats ──────────────────────────────────────────────────────────

  int get _totalLessons => LessonsData.allLessons.length;
  int get _completedLessons => widget.progress.completedLessons.length;
  double get _globalPct =>
      _totalLessons > 0 ? _completedLessons / _totalLessons : 0;

  String get _niveau {
    if (_globalPct == 0) return 'Débutant';
    if (_globalPct < 0.2) return 'Novice';
    if (_globalPct < 0.4) return 'Apprenti';
    if (_globalPct < 0.6) return 'Intermédiaire';
    if (_globalPct < 0.8) return 'Avancé';
    return 'Expert Baoulé';
  }

  String get _niveauEmoji {
    if (_globalPct == 0) return '🌱';
    if (_globalPct < 0.2) return '📚';
    if (_globalPct < 0.4) return '✏️';
    if (_globalPct < 0.6) return '🎯';
    if (_globalPct < 0.8) return '🚀';
    return '🏆';
  }

  Color get _niveauColor {
    if (_globalPct < 0.2) return Colors.grey;
    if (_globalPct < 0.4) return Colors.blue;
    if (_globalPct < 0.6) return AppTheme.primary;
    if (_globalPct < 0.8) return Colors.purple;
    return AppTheme.secondary;
  }

  String get _prochainNiveau {
    if (_globalPct == 0) return 'Novice';
    if (_globalPct < 0.2) return 'Apprenti';
    if (_globalPct < 0.4) return 'Intermédiaire';
    if (_globalPct < 0.6) return 'Avancé';
    if (_globalPct < 0.8) return 'Expert Baoulé';
    return '🎉 Niveau max atteint !';
  }

  double get _progressToNext {
    if (_globalPct < 0.2) return _globalPct / 0.2;
    if (_globalPct < 0.4) return (_globalPct - 0.2) / 0.2;
    if (_globalPct < 0.6) return (_globalPct - 0.4) / 0.2;
    if (_globalPct < 0.8) return (_globalPct - 0.6) / 0.2;
    return 1.0;
  }

  int get _totalMots {
    int total = 0;
    for (final lesson in LessonsData.allLessons) {
      if (widget.progress.isLessonCompleted(lesson.id)) {
        total += lesson.courseCards.length;
      }
    }
    return total;
  }

  int get _totalQuestions {
    int total = 0;
    for (final lesson in LessonsData.allLessons) {
      if (widget.progress.isLessonCompleted(lesson.id)) {
        total += lesson.questions.length;
      }
    }
    return total;
  }

  // Catégories maîtrisées
  List<Map<String, dynamic>> get _categories {
    return LessonsData.allLessons.map((lesson) {
      final done = widget.progress.isLessonCompleted(lesson.id);
      return {
        'title': lesson.title,
        'emoji': lesson.emoji,
        'done': done,
        'xp': lesson.xpReward,
        'mots': lesson.courseCards.length,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          slivers: [

            // ── Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.primary,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: Column(
                      children: [
                        // Top bar
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_back,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Mes Statistiques',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Niveau actuel
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _niveauEmoji,
                                style: const TextStyle(fontSize: 48),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _niveau,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Niveau actuel',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Barre vers prochain niveau
                              if (_globalPct < 1.0) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _niveau,
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.7),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      _prochainNiveau,
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.7),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(
                                        begin: 0, end: _progressToNext),
                                    duration: const Duration(
                                        milliseconds: 1000),
                                    curve: Curves.easeOut,
                                    builder: (_, v, __) =>
                                        LinearProgressIndicator(
                                      value: v,
                                      backgroundColor:
                                          Colors.white.withValues(alpha: 0.2),
                                      valueColor:
                                          const AlwaysStoppedAnimation
                                              <Color>(Colors.white),
                                      minHeight: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${(_progressToNext * 100).round()}% vers $_prochainNiveau',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 11,
                                  ),
                                ),
                              ] else
                                Text(
                                  '🎉 Tu as atteint le niveau maximum !',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Stats chiffres ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('📊 Chiffres clés'),
                    const SizedBox(height: 12),
                    Row(children: [
                      _StatCard(
                        icon: '⚡',
                        value: '${widget.progress.xp}',
                        label: 'XP Total',
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        icon: '🔥',
                        value: '${widget.progress.streak}',
                        label: 'Jours de série',
                        color: Colors.orange,
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      _StatCard(
                        icon: '📖',
                        value: '$_totalMots',
                        label: 'Mots appris',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        icon: '✅',
                        value: '$_totalQuestions',
                        label: 'Quiz réussis',
                        color: AppTheme.secondary,
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      _StatCard(
                        icon: '🎓',
                        value:
                            '$_completedLessons/$_totalLessons',
                        label: 'Leçons terminées',
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        icon: '❤️',
                        value: '${widget.progress.hearts}',
                        label: 'Vies restantes',
                        color: AppTheme.danger,
                      ),
                    ]),
                  ],
                ),
              ),
            ),

            // ── Progression globale ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('🗺️ Progression globale'),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(_globalPct * 100).round()}% complété',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '$_completedLessons/$_totalLessons leçons',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textGrey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: _globalPct),
                              duration:
                                  const Duration(milliseconds: 1200),
                              curve: Curves.easeOut,
                              builder: (_, v, __) =>
                                  LinearProgressIndicator(
                                value: v,
                                backgroundColor: Colors.grey.shade100,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        _niveauColor),
                                minHeight: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Détail par catégorie ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: const _SectionTitle('📚 Détail par unité'),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final cat = _categories[i];
                  final done = cat['done'] as bool;
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration:
                        Duration(milliseconds: 400 + i * 80),
                    curve: Curves.easeOut,
                    builder: (_, v, child) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - v)),
                        child: child,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(
                          20, 0, 20, 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: done
                              ? AppTheme.secondary.withValues(alpha: 0.4)
                              : AppTheme.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Emoji
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: done
                                  ? AppTheme.secondary
                                      .withValues(alpha: 0.1)
                                  : Colors.grey.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                cat['emoji'] as String,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat['title'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: done
                                        ? AppTheme.textDark
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${cat['mots']} mots • ${cat['xp']} XP',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Status
                          done
                              ? Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondary
                                        .withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: AppTheme.secondary,
                                          size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Maîtrisé',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'À faire',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _categories.length,
              ),
            ),

            // ── Conseil personnalisé ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withValues(alpha: 0.08),
                        AppTheme.primary.withValues(alpha: 0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Text('💡',
                            style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        const Text(
                          'Conseil personnalisé',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Text(
                        _conseil,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textDark,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _conseil {
    if (_completedLessons == 0) {
      return 'Commence par la leçon "Salutations" pour apprendre à dire bonjour en Baoulé ! C\'est la base de toute conversation. 👋';
    } else if (_completedLessons < 3) {
      return 'Bon début ! Continue avec les pronoms et la famille pour construire tes premières phrases en Baoulé. Tu progresses bien ! 💪';
    } else if (_completedLessons < 6) {
      return 'Tu maîtrises les bases ! Attaque-toi maintenant aux chiffres et à la nourriture pour enrichir ton vocabulaire. 🍽️';
    } else if (_completedLessons < _totalLessons) {
      return 'Excellent niveau ! Plus que quelques unités pour devenir un vrai expert Baoulé. Continue sur ta lancée ! 🚀';
    } else {
      return 'Félicitations ! Tu as maîtrisé tout le contenu disponible. Tu es maintenant un Expert Baoulé ! Reviens bientôt pour de nouvelles leçons. 🏆🇨🇮';
    }
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppTheme.textDark,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}