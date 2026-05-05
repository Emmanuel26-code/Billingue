import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/lesson_model.dart';
import '../../controllers/lesson_controller.dart';
import '../../widgets/answer_tile.dart';
import '../../widgets/heart_widget.dart';
import 'result_screen.dart';

class LessonScreen extends StatefulWidget {
  final LessonModel lesson;
  final UserProgress progress;

  const LessonScreen(
      {super.key, required this.lesson, required this.progress});

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
  bool _showFb = false;

  @override
  void initState() {
    super.initState();
    _ctrl =
        LessonController(lesson: widget.lesson, progress: widget.progress);
    _qAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fbAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _qSlide = Tween<double>(begin: 40, end: 0).animate(
        CurvedAnimation(parent: _qAnim, curve: Curves.easeOut));
    _fbSlide = Tween<double>(begin: 80, end: 0).animate(
        CurvedAnimation(parent: _fbAnim, curve: Curves.easeOut));
    _ctrl.addListener(() => setState(() {}));
    _qAnim.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _qAnim.dispose();
    _fbAnim.dispose();
    super.dispose();
  }

  void _select(String answer) {
    _ctrl.selectAnswer(answer);
    setState(() => _showFb = true);
    _fbAnim.forward(from: 0);
  }

  Future<void> _next() async {
    final hasNext = _ctrl.nextQuestion();
    if (!hasNext) {
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
          ),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
      return;
    }
    setState(() => _showFb = false);
    _fbAnim.reverse();
    await Future.delayed(const Duration(milliseconds: 80));
    _qAnim.forward(from: 0);
  }

  AnswerState _state(String opt) {
    if (!_ctrl.answered) return AnswerState.idle;
    if (opt == _ctrl.currentQuestion.correctAnswer) return AnswerState.correct;
    if (opt == _ctrl.selectedAnswer) return AnswerState.incorrect;
    return AnswerState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final q = _ctrl.currentQuestion;
    final prog =
        (_ctrl.currentIndex + 1) / _ctrl.totalQuestions;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
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
                      duration: const Duration(milliseconds: 500),
                      builder: (_, v, __) => LinearProgressIndicator(
                        value: v,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
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

            // Question
            Expanded(
              child: AnimatedBuilder(
                animation: _qSlide,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, _qSlide.value),
                  child: Opacity(opacity: _qAnim.value, child: child),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(q.instruction,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary)),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: AppTheme.border, width: 2),
                        ),
                        child: Text(q.questionText,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textDark),
                            textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 24),
                      ...q.options.map((opt) => AnswerTile(
                            text: opt,
                            state: _state(opt),
                            onTap: () => _select(opt),
                          )),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            // Feedback
            AnimatedBuilder(
              animation: _fbSlide,
              builder: (_, child) => Transform.translate(
                offset:
                    Offset(0, _showFb ? _fbSlide.value : 80),
                child: Opacity(
                    opacity: _showFb ? _fbAnim.value : 0,
                    child: child),
              ),
              child: _ctrl.answered ? _Feedback(
                correct: _ctrl.isCorrect,
                explanation: q.explanation,
                isLast: _ctrl.isLastQuestion,
                onContinue: _next,
              ) : const SizedBox.shrink(),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

class _Feedback extends StatelessWidget {
  final bool correct;
  final String explanation;
  final bool isLast;
  final VoidCallback onContinue;

  const _Feedback({
    required this.correct,
    required this.explanation,
    required this.isLast,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
      decoration: BoxDecoration(
        color: correct
            ? AppTheme.secondary.withOpacity(0.08)
            : AppTheme.danger.withOpacity(0.07),
        border: Border(
          top: BorderSide(
              color: correct ? AppTheme.secondary : AppTheme.danger,
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
            Text(
              correct ? 'Excellent !' : 'Pas tout à fait...',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: correct
                      ? AppTheme.secondaryDark
                      : AppTheme.danger),
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
                backgroundColor:
                    correct ? AppTheme.secondary : AppTheme.danger,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
              ),
              child: Text(
                isLast ? 'Voir les résultats 🏆' : 'Continuer →',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}