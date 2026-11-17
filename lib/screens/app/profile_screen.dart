import 'package:BillingueApp/screens/app/badges_screen.dart';
import 'package:BillingueApp/screens/app/gamification_screen.dart';
import 'package:BillingueApp/screens/app/logout_screen.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/lessons_data.dart';
import '../../models/lesson_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/avatar_picker.dart';
import '../auth/welcome_screen.dart';
import 'stats_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserProgress progress;
  final String uid;

  const ProfileScreen({
    super.key,
    required this.progress,
    required this.uid,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    widget.progress.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    widget.progress.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _onProgressChanged() {
    if (mounted) setState(() {});
  }

  void _openAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AvatarPicker(
        currentAvatar: widget.progress.avatar,
        onSelected: (avatar) async {
          // Met à jour partout automatiquement via ChangeNotifier
          widget.progress.avatar = avatar;
          // Sauvegarde dans Firestore
          await UserService().updateAvatar(
            uid: widget.uid,
            avatar: avatar,
          );
        },
      ),
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    if (value) {
      await NotificationService().requestPermission();
      await NotificationService().scheduleReminders(widget.progress.objectif);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rappels activés pour ${widget.progress.objectif} !',
            ),
            backgroundColor: AppTheme.secondary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } else {
      await NotificationService().cancelAll();
    }
  }

  Future<void> _logout() async {
    // Sauvegarde la progression avant déconnexion
    await UserService().saveProgress(
      uid: widget.uid,
      xp: widget.progress.xp,
      hearts: widget.progress.hearts,
      streak: widget.progress.streak,
      completedLessons: widget.progress.completedLessons.toList(),
      totalWordsLearned: widget.progress.totalWordsLearned,
      totalErrors: widget.progress.totalErrors,
    );

    // Déconnexion Firebase
    await AuthService().signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.progress.completedLessons.length;
    final total = LessonsData.allLessons.length;
    final pct = total > 0 ? (done / total * 100).round() : 0;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 118, 21),
      body: Column(
        children: [
          // Header orange
          Container(
            color: const Color.fromARGB(255, 255, 118, 21),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(children: [
                  GestureDetector(
                    onTap: _openAvatarPicker,
                    child: Stack(children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Container(
                          key: ValueKey(widget.progress.avatar),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6), width: 3),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              widget.progress.avatar,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppTheme.primary, width: 2),
                          ),
                          child: Icon(Icons.edit_rounded,
                              size: 13, color: AppTheme.primary),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Text(widget.progress.nom,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text('Apprenant Baoulé 🇨🇮',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                ]),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // Stats
                Row(children: [
                  _Box('${widget.progress.xp}', 'XP total', AppTheme.primary,
                      '⚡'),
                  const SizedBox(width: 10),
                  _Box('${widget.progress.streak}', 'Série', AppTheme.primary,
                      '🔥'),
                  const SizedBox(width: 10),
                  _Box('$pct%', 'Complété', AppTheme.secondary, '🏆'),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _Box('${widget.progress.totalWordsLearned}', 'Mots appris',
                      Colors.blue, '📖'),
                  const SizedBox(width: 10),
                  _Box('${widget.progress.hearts}', 'Vies', Colors.red, '❤️'),
                  const SizedBox(width: 10),
                  _Box('${widget.progress.totalErrors}', 'Erreurs totales',
                      Colors.orange, '❌'),
                ]),
                const SizedBox(height: 16),

                // Progression
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Progression globale',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                          Text('$done/$total leçons',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.textGrey)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: total > 0 ? done / total : 0,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primary),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Menu
                _Item('📊', const Color(0xFFFFF0E5), 'Mes statistiques', null,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => StatsScreen(progress: widget.progress)),
                  );
                }),

                _Item('🎮', const Color(0xFFEEF0FF), 'Gamification', null, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GamificationScreen(
                        progress: widget.progress,
                        uid: widget.uid,
                      ),
                    ),
                  );
                }),

                _Item('🏅', const Color(0xFFFFF8E1), 'Mes badges', null, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BadgesScreen(progress: widget.progress),
                    ),
                  );
                }),

                // Notifications avec toggle
                Container(
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
                          color: const Color(0xFFE5F9EE),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Center(
                          child: Text('🔔', style: TextStyle(fontSize: 18))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Notifications',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          Text(
                            _notificationsEnabled
                                ? 'Rappels activés · ${widget.progress.objectif}'
                                : 'Rappels désactivés',
                            style: TextStyle(
                                fontSize: 11,
                                color: _notificationsEnabled
                                    ? AppTheme.secondary
                                    : Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _notificationsEnabled,
                      onChanged: _toggleNotifications,
                      activeThumbColor: AppTheme.primary,
                    ),
                  ]),
                ),

                _Item('🌍', const Color(0xFFE5F0FF), 'Langue', null, () {}),

                // Déconnexion propre
                _Item('🚪', const Color(0xFFFFF0F0), 'Déconnexion',
                    AppTheme.danger, () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: const Text('Déconnexion ?',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      content: const Text(
                          'Ta progression est sauvegardée. Tu pourras te reconnecter à tout moment.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Annuler',
                              style: TextStyle(color: AppTheme.primary)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Déconnecter',
                              style: TextStyle(color: AppTheme.danger)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, anim, __) => LogoutScreen(
                          progress: widget.progress,
                          uid: widget.uid,
                        ),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  }
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
  final String icon;

  const _Box(this.val, this.lbl, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(val,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(lbl,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
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
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(10)),
            child:
                Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: labelColor ?? AppTheme.textDark)),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
        ]),
      ),
    );
  }
}
