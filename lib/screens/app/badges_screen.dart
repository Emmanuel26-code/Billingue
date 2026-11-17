import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/lesson_model.dart';
import '../../services/badge_service.dart';

class BadgesScreen extends StatelessWidget {
  final UserProgress progress;

  const BadgesScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final badges = BadgeService().getBadges(progress);
    final earned = badges.where((b) => b.earned).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.primary,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      20, 14, 20, 28),
                  child: Column(children: [
                    Row(children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('🏅 Mes Badges',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900)),
                    ]),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                        children: [
                          Column(children: [
                            Text('$earned',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight:
                                        FontWeight.w900)),
                            Text('Obtenus',
                                style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.8),
                                    fontSize: 12)),
                          ]),
                          Container(
                              width: 1,
                              height: 40,
                              color:
                                  Colors.white.withValues(alpha: 0.3)),
                          Column(children: [
                            Text('${badges.length - earned}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight:
                                        FontWeight.w900)),
                            Text('À débloquer',
                                style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.8),
                                    fontSize: 12)),
                          ]),
                          Container(
                              width: 1,
                              height: 40,
                              color:
                                  Colors.white.withValues(alpha: 0.3)),
                          Column(children: [
                            Text(
                                '${earned > 0 ? (earned / badges.length * 100).round() : 0}%',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight:
                                        FontWeight.w900)),
                            Text('Complété',
                                style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.8),
                                    fontSize: 12)),
                          ]),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final badge = badges[i];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(
                        milliseconds: 300 + i * 50),
                    curve: Curves.easeOut,
                    builder: (_, v, child) => Opacity(
                      opacity: v,
                      child: Transform.scale(
                          scale: 0.8 + 0.2 * v, child: child),
                    ),
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: badge.earned
                            ? Colors.white
                            : Colors.grey.shade100,
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                          color: badge.earned
                              ? AppTheme.primary
                                  .withValues(alpha: 0.3)
                              : Colors.grey.shade200,
                          width: badge.earned ? 2 : 1,
                        ),
                        boxShadow: badge.earned
                            ? [
                                BoxShadow(
                                  color: AppTheme.primary
                                      .withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Opacity(
                              opacity: badge.earned ? 1 : 0.3,
                              child: Text(badge.emoji,
                                  style: const TextStyle(
                                      fontSize: 36)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              badge.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: badge.earned
                                    ? AppTheme.textDark
                                    : Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              badge.description,
                              style: TextStyle(
                                fontSize: 10,
                                color: badge.earned
                                    ? AppTheme.textGrey
                                    : Colors.grey.shade400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (badge.earned) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondary
                                      .withValues(alpha: 0.15),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text('Obtenu ✓',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight:
                                            FontWeight.w700,
                                        color: AppTheme
                                            .secondaryDark)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: badges.length,
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
            ),
          ),
        ],
      ),
    );
  }
}