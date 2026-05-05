import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/lessons_data.dart';
import '../../models/lesson_model.dart';

class ProfileScreen extends StatelessWidget {
  final UserProgress progress;
  const ProfileScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final done = progress.completedLessons.length;
    final total = LessonsData.allLessons.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          Container(
            color: AppTheme.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: const Text('🧑🏾',
                        style: TextStyle(fontSize: 36)),
                  ),
                  const SizedBox(height: 10),
                  const Text('Kofi Atta',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text('kofi@email.com',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13)),
                ]),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Row(children: [
                  _Box('${progress.xp}', 'XP total', AppTheme.primary),
                  const SizedBox(width: 10),
                  _Box('${progress.streak}', 'Série (jours)', AppTheme.primary),
                  const SizedBox(width: 10),
                  _Box('$done/$total', 'Leçons', AppTheme.secondary),
                ]),
                const SizedBox(height: 18),
                _Item('🎯', const Color(0xFFFFF0E5), 'Mon objectif', null, () {}),
                _Item('🔔', const Color(0xFFE5F9EE), 'Notifications', null, () {}),
                _Item('🌍', const Color(0xFFE5F0FF), 'Langue', null, () {}),
                _Item('🚪', const Color(0xFFFFF0F0), 'Déconnexion',
                    AppTheme.danger, () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                }),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final String val;
  final String lbl;
  final Color color;
  const _Box(this.val, this.lbl, this.color);

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
          Text(val,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color)),
          const SizedBox(height: 4),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 18))),
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