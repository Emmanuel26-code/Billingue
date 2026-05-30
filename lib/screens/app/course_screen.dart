import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/lesson_model.dart';
import '../../services/tts_service.dart';
import '../../widgets/loading_overlay.dart';
import 'lesson_screen.dart';
import '../../services/audio_service.dart';

class CourseScreen extends StatefulWidget {
  final LessonModel lesson;
  final UserProgress progress;
  final String uid;

  const CourseScreen({
    super.key,
    required this.lesson,
    required this.progress,
    required this.uid,
  });

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  final TtsService _tts = TtsService();
  final AudioService _audio = AudioService();
  int _currentIndex = 0;
  bool _isSpeaking = false;

  // Timer
  late Timer _timer;
  late int _totalSeconds;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _tts.init();
    _totalSeconds = _getTimeForObjectif(widget.progress.objectif);
    _startTimer();
  }

  int _getTimeForObjectif(String objectif) {
    switch (objectif) {
      case 'Moyens':
        return 5 * 60;
      case 'Regulier':
        return 10 * 60;
      case 'Sérieux':
        return 15 * 60;
      case 'Intense':
        return 20 * 60;
      default:
        return 10 * 60;
    }
  }

  String get _objectifEmoji {
    switch (widget.progress.objectif) {
      case 'Moyens':
        return '🟢';
      case 'Regulier':
        return '🔵';
      case 'Sérieux':
        return '🟡';
      case 'Intense':
        return '🔴';
      default:
        return '🔵';
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  String get _timeRemaining {
    final remaining = _totalSeconds - _secondsElapsed;
    if (remaining <= 0) return '0:00';
    final m = remaining ~/ 60;
    final s = remaining % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  double get _timeProgress =>
      (_secondsElapsed / _totalSeconds).clamp(0.0, 1.0);

  Color get _timeColor {
    if (_timeProgress < 0.6) return AppTheme.secondary;
    if (_timeProgress < 0.85) return Colors.orange;
    return AppTheme.danger;
  }

  @override
  void dispose() {
    _timer.cancel();
    _tts.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < widget.lesson.courseCards.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goToQuiz();
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToQuiz() {
    _timer.cancel();
    _tts.stop();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => LessonScreen(
          lesson: widget.lesson,
          progress: widget.progress,
          uid: widget.uid,
        ),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await _tts.speakBaoule(text);
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.lesson.courseCards;
    final total = cards.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 20, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lesson.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0,
                              end: (_currentIndex + 1) / total,
                            ),
                            duration:
                                const Duration(milliseconds: 400),
                            builder: (_, v, __) =>
                                LinearProgressIndicator(
                              value: v,
                              backgroundColor: Colors.grey.shade200,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      AppTheme.primary),
                              minHeight: 7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/$total',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Barre de temps ───────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _timeColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Text(_objectifEmoji,
                              style:
                                  const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            'Objectif ${widget.progress.objectif}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ]),
                        Row(children: [
                          Icon(Icons.timer_outlined,
                              size: 14, color: _timeColor),
                          const SizedBox(width: 4),
                          Text(
                            _secondsElapsed > _totalSeconds
                                ? 'Temps dépassé !'
                                : 'Reste : $_timeRemaining',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _timeColor,
                            ),
                          ),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        child: LinearProgressIndicator(
                          value: _timeProgress,
                          backgroundColor: Colors.grey.shade100,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                                  _timeColor),
                          minHeight: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Label COURS ──────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B4FCF)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: const [
                        Text('📖',
                            style: TextStyle(fontSize: 13)),
                        SizedBox(width: 5),
                        Text(
                          'COURS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF5B4FCF),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Cards ────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) {
                  setState(() {
                    _currentIndex = i;
                    _isSpeaking = false;
                  });
                  _tts.stop();
                },
                itemCount: total,
                itemBuilder: (_, i) {
                  final card = cards[i];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration:
                        const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    builder: (_, v, child) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - v)),
                        child: child,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          // Carte principale
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(24),
                              border: Border.all(
                                  color: AppTheme.primary
                                      .withOpacity(0.2),
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary
                                      .withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(widget.lesson.emoji,
                                    style: const TextStyle(
                                        fontSize: 44)),
                                const SizedBox(height: 20),
                                Text(
                                  card.baoule,
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primary,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 40,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary
                                        .withOpacity(0.3),
                                    borderRadius:
                                        BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  card.francais,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 18),
                                GestureDetector(
                                  onTap: () async {
                                    // Joue le vrai audio enregistré
                                    final played = await _audio.playWord(card.baoule);
                                    // Si pas d'audio → TTS de secours
                                    if (!played) await _tts.speakBaoule(card.baoule);
                                    setState(() => _isSpeaking = !_isSpeaking);
                                    await Future.delayed(const Duration(seconds: 2));
                                    if (mounted) setState(() => _isSpeaking = false);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _isSpeaking
                                          ? AppTheme.primary
                                          : AppTheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                          color: AppTheme.primary.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _isSpeaking
                                              ? Icons.stop_rounded
                                              : Icons.volume_up_rounded,
                                          color: _isSpeaking
                                              ? Colors.white
                                              : AppTheme.primary,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 7),
                                        Text(
                                          _isSpeaking
                                              ? 'Stop'
                                              : AudioService.hasAudio(card.baoule)
                                                  ? '🎙️ Écouter'
                                                  : '🔊 Écouter',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _isSpeaking
                                                ? Colors.white
                                                : AppTheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Exemple
                          if (card.exemple != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FFF5),
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppTheme.secondary
                                        .withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    const Text('💬',
                                        style: TextStyle(
                                            fontSize: 13)),
                                    const SizedBox(width: 6),
                                    Text('Exemple',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w800,
                                          color: AppTheme
                                              .secondaryDark,
                                        )),
                                  ]),
                                  const SizedBox(height: 6),
                                  Text(card.exemple!,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight.w700,
                                          color:
                                              AppTheme.textDark)),
                                  if (card.exempeFr != null) ...[
                                    const SizedBox(height: 3),
                                    Text(card.exempeFr!,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                AppTheme.textGrey,
                                            fontStyle:
                                                FontStyle.italic)),
                                  ],
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),
                          Text('Swipe pour naviguer',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Navigation ───────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  if (_currentIndex > 0)
                    GestureDetector(
                      onTap: _prev,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.grey.shade200,
                              width: 2),
                        ),
                        child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 18,
                            color: AppTheme.textDark),
                      ),
                    )
                  else
                    const SizedBox(width: 50),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _currentIndex == total - 1
                                  ? AppTheme.secondary
                                  : AppTheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(28)),
                        ),
                        child: Text(
                          _currentIndex == total - 1
                              ? 'Commencer le Quiz 🎯'
                              : 'Suivant →',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dots
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  total > 10 ? 10 : total,
                  (i) {
                    final active = total > 10
                        ? (_currentIndex * 10 ~/ total == i)
                        : (_currentIndex == i);
                    return AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 3),
                      width: active ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? AppTheme.primary
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}