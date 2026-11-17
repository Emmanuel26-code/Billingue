import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../models/lesson_model.dart';

class PenaltyOverlay extends StatefulWidget {
  final UserProgress progress;
  final String uid;
  final VoidCallback onResume;

  const PenaltyOverlay({
    super.key,
    required this.progress,
    required this.uid,
    required this.onResume,
  });

  @override
  State<PenaltyOverlay> createState() => _PenaltyOverlayState();
}

class _PenaltyOverlayState extends State<PenaltyOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0, 0.4));
    _ctrl.forward();

    _secondsLeft = widget.progress.penaltySecondsRemaining;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining =
          widget.progress.penaltySecondsRemaining;
      setState(() => _secondsLeft = remaining);

      // Pénalité terminée
      if (remaining <= 0) {
        _timer?.cancel();
        // Donne 1 cœur pour reprendre
        widget.progress.syncHearts();
        if (widget.progress.hearts == 0) {
          widget.progress.refillHearts();
        }
        widget.onResume();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  String get _timerText {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: ScaleTransition(
              scale: _scale,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cœurs vides
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (_) => const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 4),
                          child: Text('🖤',
                              style: TextStyle(fontSize: 32)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Titre
                    const Text(
                      'Tu n\'as plus de vies !',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Prends une pause et reviens dans',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.danger, width: 2),
                      ),
                      child: Text(
                        _timerText,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            fontFeatures: [
                              FontFeature.tabularFigures()
                            ]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tes vies se régénèrent automatiquement\n(1 vie toutes les 30 minutes)',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Option achat avec pièces
                    if (widget.progress.coins >= 100) ...[
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.progress.coins -= 100;
                          widget.progress.refillHearts();
                          _timer?.cancel();
                          widget.onResume();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8860B),
                            borderRadius:
                                BorderRadius.circular(28),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: const [
                              Text('🪙',
                                  style:
                                      TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text(
                                'Recharger (100 🪙)',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Quitter la leçon
                    GestureDetector(
                      onTap: () {
                        _timer?.cancel();
                        Navigator.of(context)
                            .popUntil((r) => r.isFirst);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(28),
                          border: Border.all(
                              color:
                                  Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'Revenir à l\'accueil',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      '💡 Astuce : Achète des freezes de série\npour protéger ta progression !',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Affiche l'overlay de pénalité
void showPenaltyOverlay(
  BuildContext context, {
  required UserProgress progress,
  required String uid,
  required VoidCallback onResume,
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => PenaltyOverlay(
        progress: progress,
        uid: uid,
        onResume: onResume,
      ),
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ),
  );
}