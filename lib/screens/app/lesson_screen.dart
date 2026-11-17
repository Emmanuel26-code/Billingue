import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/lesson_model.dart';
import '../../controllers/lesson_controller.dart';
import '../../widgets/answer_tile.dart';
import '../../widgets/heart_widget.dart';
import '../../widgets/penalty_screen.dart';
import '../../widgets/pronunciation_widget.dart';
import '../../services/audio_service.dart';
import 'result_screen.dart';

class LessonScreen extends StatefulWidget {
  final LessonModel lesson;
  final UserProgress progress;
  final String uid;

  const LessonScreen({
    super.key,
    required this.lesson,
    required this.progress,
    required this.uid,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with TickerProviderStateMixin {
  late LessonController _ctrl;
  late AnimationController _qAnim;
  late AnimationController _fbAnim;
  late Animation<double> _qSlide;
  late Animation<double> _fbSlide;
  final AudioService _audio = AudioService();
  bool _showFb = false;

  @override
  void initState() {
    super.initState();
    // Synchronise les cœurs régénérés
    widget.progress.syncHearts();

    // Vérifie la pénalité
    if (widget.progress.isPenaltyActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showPenaltyOverlay(
          context,
          progress: widget.progress,
          uid: widget.uid,
          onResume: () => Navigator.pop(context),
        );
      });
    }

    _ctrl = LessonController(
        lesson: widget.lesson, progress: widget.progress);
    _qAnim = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 380));
    _fbAnim = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 320));
    _qSlide = Tween<double>(begin: 40, end: 0).animate(
        CurvedAnimation(parent: _qAnim, curve: Curves.easeOut));
    _fbSlide = Tween<double>(begin: 80, end: 0).animate(
        CurvedAnimation(parent: _fbAnim, curve: Curves.easeOut));
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _qAnim.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _qAnim.dispose();
    _fbAnim.dispose();
    super.dispose();
  }

  // ── Réponse QCM ────────────────────────────────────────────────────────────
  void _select(String answer) {
    if (_ctrl.answered) return;
    _ctrl.selectAnswer(answer);
    setState(() => _showFb = true);
    _fbAnim.forward(from: 0);

    // Vérifie la pénalité après perte de cœur
    if (!_ctrl.isCorrect && widget.progress.hearts == 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          showPenaltyOverlay(
            context,
            progress: widget.progress,
            uid: widget.uid,
            onResume: () {
              // Reprend si des cœurs sont disponibles
              if (widget.progress.hearts > 0) {
                Navigator.pop(context);
              }
            },
          );
        }
      });
    }
  }

  // ── Passer à la question suivante ──────────────────────────────────────────
  Future<void> _next() async {
    final hasNext = _ctrl.nextQuestion();
    if (!hasNext) {
      _goToResult();
      return;
    }
    setState(() => _showFb = false);
    _fbAnim.reset();
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) _qAnim.forward(from: 0);
  }

  // ── Prononciation réussie ──────────────────────────────────────────────────
  void _onPronunciationSuccess() {
    _ctrl.markPronunciationCorrect();
    _goToNextOrResult();
  }

  // ── Prononciation passée ───────────────────────────────────────────────────
  void _onPronunciationSkip() {
    _ctrl.markPronunciationFailed();
    _goToNextOrResult();
  }

  void _goToNextOrResult() {
    final hasNext = _ctrl.nextQuestion();
    if (!hasNext) {
      _goToResult();
      return;
    }
    setState(() => _showFb = false);
    _fbAnim.reset();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _qAnim.forward(from: 0);
    });
  }

  // ── Navigation vers résultats ──────────────────────────────────────────────
  void _goToResult() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => ResultScreen(
          lesson: widget.lesson,
          correctCount: _ctrl.correctCount,
          totalQuestions: _ctrl.totalQuestions,
          earnedXP: _ctrl.earnedXP,
          accuracy: _ctrl.accuracy,
          progress: widget.progress,
          uid: widget.uid,
          errorCount: _ctrl.errorCount,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  AnswerState _state(String opt) {
    if (!_ctrl.answered) return AnswerState.idle;
    if (opt == _ctrl.currentQuestion.correctAnswer) {
      return AnswerState.correct;
    }
    if (opt == _ctrl.selectedAnswer) {
      return AnswerState.incorrect;
    }
    return AnswerState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final q = _ctrl.currentQuestion;
    final prog =
        (_ctrl.currentIndex + 1) / _ctrl.totalQuestions;
    final isPronunciation =
        q.type == QuestionType.pronunciation;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [

            // ── Top bar ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: _showQuit,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle),
                    child: const Icon(Icons.close,
                        size: 20, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: prog),
                      duration:
                          const Duration(milliseconds: 500),
                      builder: (_, v, __) =>
                          LinearProgressIndicator(
                        value: v,
                        backgroundColor: Colors.grey.shade200,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(
                                AppTheme.primary),
                        minHeight: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                HeartWidget(hearts: widget.progress.hearts),
              ]),
            ),

            // ── Contenu ───────────────────────────────────────
            Expanded(
              child: AnimatedBuilder(
                animation: _qSlide,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, _qSlide.value),
                  child: Opacity(
                      opacity: _qAnim.value, child: child),
                ),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: isPronunciation
                      // ── Mode Prononciation ────────────────
                      ? PronunciationWidget(
                          wordToSay: q.questionText,
                          translation: q.explanation,
                          onSuccess: _onPronunciationSuccess,
                          onSkip: _onPronunciationSkip,
                        )
                      // ── Mode QCM ──────────────────────────
                      : Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // Instruction
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7),
                              decoration: BoxDecoration(
                                color: AppTheme.primary
                                    .withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Text(q.instruction,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.w700,
                                      color: AppTheme.primary)),
                            ),
                            const SizedBox(height: 22),

                            // Carte question + bouton audio
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(18),
                                border: Border.all(
                                    color: AppTheme.border,
                                    width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Column(children: [
                                Text(
                                  q.questionText,
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight:
                                          FontWeight.w900,
                                      color: AppTheme.textDark),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 14),
                                // Bouton écouter audio réel
                                GestureDetector(
                                  onTap: () async {
                                    final played =
                                        await _audio.playWord(
                                            q.questionText);
                                    if (!played) {
                                      // Repli TTS si pas d'audio
                                      debugPrint(
                                          'Pas d\'audio pour : ${q.questionText}');
                                    }
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(
                                              20),
                                      border: Border.all(
                                          color: AppTheme.primary
                                              .withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        Icon(
                                            Icons.volume_up_rounded,
                                            color: AppTheme.primary,
                                            size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          AudioService.hasAudio(
                                                  q.questionText)
                                              ? '🎙️ Écouter'
                                              : '🔊 Écouter',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                                  FontWeight.w600,
                                              color:
                                                  AppTheme.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 22),

                            // Options
                            ...q.options.map(
                              (opt) => AnswerTile(
                                text: opt,
                                state: _state(opt),
                                onTap: () => _select(opt),
                              ),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                ),
              ),
            ),

            // ── Feedback QCM ──────────────────────────────────
            if (!isPronunciation)
              AnimatedBuilder(
                animation: _fbSlide,
                builder: (_, child) => Transform.translate(
                  offset:
                      Offset(0, _showFb ? _fbSlide.value : 80),
                  child: Opacity(
                    opacity: _showFb ? _fbAnim.value : 0,
                    child: child,
                  ),
                ),
                child: _ctrl.answered
                    ? _FeedbackPanel(
                        correct: _ctrl.isCorrect,
                        explanation: q.explanation,
                        correctAnswer: q.correctAnswer,
                        isLast: _ctrl.isLastQuestion,
                        onContinue: _next,
                        onListen: () =>
                            _audio.playWord(q.correctAnswer),
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }

  void _showQuit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Quitter la leçon ?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Ta progression sera perdue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Rester',
                style: TextStyle(color: AppTheme.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Quitter',
                style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }
}

// ── Feedback Widget ───────────────────────────────────────────────────────────

class _FeedbackPanel extends StatelessWidget {
  final bool correct;
  final String explanation;
  final String correctAnswer;
  final bool isLast;
  final VoidCallback onContinue;
  final VoidCallback onListen;

  const _FeedbackPanel({
    required this.correct,
    required this.explanation,
    required this.correctAnswer,
    required this.isLast,
    required this.onContinue,
    required this.onListen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
      decoration: BoxDecoration(
        color: correct
            ? AppTheme.secondary.withValues(alpha: 0.08)
            : AppTheme.danger.withValues(alpha: 0.07),
        border: Border(
          top: BorderSide(
              color: correct
                  ? AppTheme.secondary
                  : AppTheme.danger,
              width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(correct ? '✅' : '❌',
                style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                correct
                    ? 'Excellent !'
                    : 'Pas tout à fait...',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: correct
                        ? AppTheme.secondaryDark
                        : AppTheme.danger),
              ),
            ),
            // Bouton écouter la bonne réponse
            GestureDetector(
              onTap: onListen,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: correct
                      ? AppTheme.secondary.withValues(alpha: 0.15)
                      : AppTheme.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volume_up_rounded,
                        size: 15,
                        color: correct
                            ? AppTheme.secondaryDark
                            : AppTheme.danger),
                    const SizedBox(width: 4),
                    Text('Écouter',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: correct
                                ? AppTheme.secondaryDark
                                : AppTheme.danger)),
                  ],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Text(explanation,
              style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textGrey,
                  height: 1.5)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: correct
                    ? AppTheme.secondary
                    : AppTheme.danger,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
              ),
              child: Text(
                isLast
                    ? 'Voir les résultats 🏆'
                    : 'Continuer →',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}