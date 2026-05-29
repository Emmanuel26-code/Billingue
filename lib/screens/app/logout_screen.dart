import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/lesson_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../auth/welcome_screen.dart';

class LogoutScreen extends StatefulWidget {
  final UserProgress progress;
  final String uid;

  const LogoutScreen({
    super.key,
    required this.progress,
    required this.uid,
  });

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconCtrl;
  late AnimationController _progressCtrl;
  late Animation<double> _iconScale;
  late Animation<double> _fade;

  String _currentStep = 'Sauvegarde de ta progression...';
  double _progress = 0.0;
  bool _done = false;
  bool _error = false;

  final List<_Step> _steps = [
    _Step('💾', 'Sauvegarde de ta progression...', 0.25),
    _Step('🏆', 'Sauvegarde de tes badges...', 0.50),
    _Step('❤️', 'Sauvegarde de tes vies...', 0.75),
    _Step('✅', 'Finalisation...', 1.0),
  ];

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(
        parent: _iconCtrl, curve: const Interval(0, 0.5));
    _iconCtrl.forward();
    _runLogout();
  }

  Future<void> _runLogout() async {
    try {
      for (final step in _steps) {
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted) {
          setState(() {
            _currentStep = step.label;
            _progress = step.progress;
          });
        }
      }

      // Sauvegarde réelle dans Firestore
      await UserService().saveProgress(
        uid: widget.uid,
        xp: widget.progress.xp,
        hearts: widget.progress.hearts,
        streak: widget.progress.streak,
        completedLessons:
            widget.progress.completedLessons.toList(),
        totalWordsLearned: widget.progress.totalWordsLearned,
        totalErrors: widget.progress.totalErrors,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      // Déconnexion Firebase
      await AuthService().signOut();

      if (mounted) {
        setState(() {
          _done = true;
          _currentStep = 'Sauvegarde terminée !';
        });

        await Future.delayed(const Duration(milliseconds: 1200));

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              pageBuilder: (_, anim, __) => const WelcomeScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 600),
            ),
            (_) => false,
          );
        }
      }
    } catch (e) {
      print('erreur de sauvegarde firebase: $e');
      if (mounted) {
        setState(() {
          _error = true;
          _currentStep = 'Erreur — Réessaie';
        });
      }
    }
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icône animée
                  ScaleTransition(
                    scale: _iconScale,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration:
                              const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(
                                  scale: anim, child: child),
                          child: Text(
                            _done
                                ? '✅'
                                : _error
                                    ? '❌'
                                    : _steps
                                        .firstWhere(
                                          (s) =>
                                              s.label ==
                                              _currentStep,
                                          orElse: () => _steps[0],
                                        )
                                        .icon,
                            key: ValueKey(_currentStep),
                            style: const TextStyle(fontSize: 52),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Titre
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _done
                          ? 'À bientôt ! 👋'
                          : _error
                              ? 'Une erreur est survenue'
                              : 'Sauvegarde en cours...',
                      key: ValueKey(_done),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Étape actuelle
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _currentStep,
                      key: ValueKey(_currentStep),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Barre de progression
                  if (!_error) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _progress),
                        duration:
                            const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        builder: (_, v, __) =>
                            LinearProgressIndicator(
                          value: v,
                          backgroundColor:
                              Colors.white.withOpacity(0.25),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${(_progress * 100).round()}%',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],

                  // Checklist des étapes
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: _steps.map((step) {
                        final isDone =
                            _progress >= step.progress;
                        final isCurrent =
                            _currentStep == step.label;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6),
                          child: Row(children: [
                            AnimatedSwitcher(
                              duration: const Duration(
                                  milliseconds: 300),
                              child: Icon(
                                isDone
                                    ? Icons.check_circle
                                    : isCurrent
                                        ? Icons.radio_button_checked
                                        : Icons
                                            .radio_button_unchecked,
                                key: ValueKey(isDone),
                                color: isDone
                                    ? Colors.white
                                    : Colors.white
                                        .withOpacity(0.4),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              step.label,
                              style: TextStyle(
                                color: isDone
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                fontSize: 13,
                                fontWeight: isDone
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                            if (isCurrent && !_done) ...[
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ],
                          ]),
                        );
                      }).toList(),
                    ),
                  ),

                  // Bouton réessayer si erreur
                  if (_error) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _error = false;
                            _progress = 0;
                            _currentStep =
                                'Sauvegarde de ta progression...';
                          });
                          _runLogout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(28)),
                        ),
                        child: const Text(
                          'Réessayer',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        await AuthService().signOut();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const WelcomeScreen()),
                            (_) => false,
                          );
                        }
                      },
                      child: Text(
                        'Déconnecter sans sauvegarder',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],

                  // Message rassurant
                  if (!_done && !_error) ...[
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline,
                              color: Colors.white.withOpacity(0.8),
                              size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Tes données sont en sécurité',
                            style: TextStyle(
                              color:
                                  Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Step {
  final String icon;
  final String label;
  final double progress;

  const _Step(this.icon, this.label, this.progress);
}