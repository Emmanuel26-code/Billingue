import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/lessons_data.dart';
import '../../models/lesson_model.dart';
import '../../widgets/avatar_picker.dart';
import 'stats_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserProgress progress;
  const ProfileScreen({super.key, required this.progress});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _openAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AvatarPicker(
        currentAvatar: widget.progress.avatar,
        onSelected: (avatar) {
          setState(() => widget.progress.avatar = avatar);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.progress.completedLessons.length;
    final total = LessonsData.allLessons.length;
    final pct = total > 0 ? (done / total * 100).round() : 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [

          // ── Header orange ─────────────────────────────────
          Container(
            color: AppTheme.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  children: [
                    // Avatar cliquable
                    GestureDetector(
                      onTap: _openAvatarPicker,
                      child: Stack(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Container(
                              key: ValueKey(widget.progress.avatar),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: ClipOval(
                                 child: Image.asset(
                                   widget.progress.avatar,
                                   width: 70,
                                   height: 70,
                                   fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Icône crayon
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppTheme.primary, width: 2),
                              ),
                              child: Icon(
                                Icons.edit_rounded,
                                size: 13,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.progress.nom,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Apprenant Baoulé 🇨🇮',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  // ── Stats ───────────────────────────────────
                  Row(children: [
                    _Box('${widget.progress.xp}', 'XP total',
                        AppTheme.primary, '⚡'),
                    const SizedBox(width: 10),
                    _Box('${widget.progress.streak}', 'Série',
                        AppTheme.primary, '🔥'),
                    const SizedBox(width: 10),
                    _Box('$pct%', 'Complété',
                        AppTheme.secondary, '🏆'),
                  ]),
                  const SizedBox(height: 16),

                  // ── Progression globale ──────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Progression globale',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '$done/$total leçons',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(
                                begin: 0,
                                end: total > 0 ? done / total : 0),
                            duration:
                                const Duration(milliseconds: 800),
                            builder: (_, v, __) =>
                                LinearProgressIndicator(
                              value: v,
                              backgroundColor: Colors.grey.shade100,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      AppTheme.primary),
                              minHeight: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Menu ────────────────────────────────────
                  _Item('🖼️', const Color(0xFFEEF0FF), 'Changer d\'avatar',
                      null, _openAvatarPicker),
                  _Item('📊', const Color(0xFFFFF0E5), 'Mes statistiques', null, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StatsScreen(progress: widget.progress),
                        ),
                      );
                    }),
                  _Item('🔔', const Color(0xFFE5F9EE), 'Notifications',
                      null, () {}),
                  _Item('🌍', const Color(0xFFE5F0FF), 'Langue',
                      null, () {}),
                  _Item('🚪', const Color(0xFFFFF0F0), 'Déconnexion',
                      AppTheme.danger, () {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _Box extends StatelessWidget {
  final String val;
  final String lbl;
  final Color color;
  final String icon;

  const _Box(this.val, this.lbl, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(val,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color)),
          const SizedBox(height: 3),
          Text(lbl,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String icon;
  final Color bg;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;

  const _Item(this.icon, this.bg, this.label, this.labelColor, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Text(icon,
                    style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: labelColor ?? AppTheme.textDark)),
          ),
          Icon(Icons.arrow_forward_ios,
              size: 14, color: Colors.grey.shade400),
        ]),
      ),
    );
  }
}