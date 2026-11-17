import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/lesson_model.dart';
import '../../data/lessons_data.dart';
import '../../widgets/answer_tile.dart';
import '../../widgets/heart_widget.dart';

class RevisionScreen extends StatefulWidget {
  final UserProgress progress;
  final String uid;

  const RevisionScreen({
    super.key,
    required this.progress,
    required this.uid,
  });

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen>
    with TickerProviderStateMixin {
  late List<QuestionModel> _questions;
  int _currentIndex = 0;
  bool _answered = false;
  String? _selected;
  bool _isCorrect = false;
  int _correct = 0;
  bool _showFb = false;
  bool _finished = false;

  late AnimationController _qAnim;
  late AnimationController _fbAnim;
  late Animation<double> _qSlide;
  late Animation<double> _fbSlide;

  @override
  void initState() {
    super.initState();
    _buildRevisionQuestions();

    _qAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fbAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _qSlide = Tween<double>(begin: 40, end: 0).animate(
        CurvedAnimation(parent: _qAnim, curve: Curves.easeOut));
    _fbSlide = Tween<double>(begin: 80, end: 0).animate(
        CurvedAnimation(parent: _fbAnim, curve: Curves.easeOut));
    _qAnim.forward();
  }

  void _buildRevisionQuestions() {
    // Récupère les questions des leçons complétées
    // en mélangeant pour varier
    final List<QuestionModel> all = [];
    for (final lesson in LessonsData.allLessons) {
      if (widget.progress.isLessonCompleted(lesson.id)) {
        // Prend les questions QCM seulement pour la révision
        final qcm = lesson.questions
            .where((q) => q.type == QuestionType.multipleChoice)
            .toList();
        all.addAll(qcm);
      }
    }

    // Mélange aléatoire
    all.shuffle();

    // Limite selon l'objectif
    int limit;
    switch (widget.progress.objectif) {
      case 'Moyens':
        limit = 5;
        break;
      case 'Regulier':
        limit = 8;
        break;
      case 'Sérieux':
        limit = 12;
        break;
      case 'Intense':
        limit = 20;
        break;
      default:
        limit = 8;
    }

    _questions = all.take(limit).toList();

    if (_questions.isEmpty) {
      _finished = true;
    }
  }

  @override
  void dispose() {
    _qAnim.dispose();
    _fbAnim.dispose();
    super.dispose();
  }

  void _select(String answer) {
    if (_answered) return;
    setState(() {
      _selected = answer;
      _isCorrect =
          answer == _questions[_currentIndex].correctAnswer;
      _answered = true;
      _showFb = true;
    });
    if (_isCorrect) _correct++;
    _fbAnim.forward(from: 0);
  }

  Future<void> _next() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selected = null;
        _showFb = false;
      });
      _fbAnim.reverse();
      await Future.delayed(const Duration(milliseconds: 80));
      _qAnim.forward(from: 0);
    } else {
      setState(() => _finished = true);
    }
  }

  AnswerState _state(String opt) {
    if (!_answered) return AnswerState.idle;
    if (opt == _questions[_currentIndex].correctAnswer) {
      return AnswerState.correct;
    }
    if (opt == _selected) return AnswerState.incorrect;
    return AnswerState.idle;
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildResult();

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📚', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                const Text('Aucune leçon complétée !',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                    'Complète au moins une leçon\npour accéder à la révision.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textGrey)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];
    final prog =
        (_currentIndex + 1) / _questions.length;

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
                  onTap: () => Navigator.pop(context),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Text('🔄',
                            style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          'Mode Révision · ${widget.progress.objectif}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.purple),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
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
                                    Colors.purple),
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                HeartWidget(hearts: widget.progress.hearts),
              ]),
            ),

            // Compteur
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${_questions.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '✅ $_correct correctes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Question
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
                      const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(q.instruction,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.purple)),
                      ),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
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
                offset: Offset(0, _showFb ? _fbSlide.value : 80),
                child: Opacity(
                    opacity: _showFb ? _fbAnim.value : 0,
                    child: child),
              ),
              child: _answered
                  ? _buildFeedback(q)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback(QuestionModel q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
      decoration: BoxDecoration(
        color: _isCorrect
            ? AppTheme.secondary.withValues(alpha: 0.08)
            : AppTheme.danger.withValues(alpha: 0.07),
        border: Border(
          top: BorderSide(
              color: _isCorrect
                  ? AppTheme.secondary
                  : AppTheme.danger,
              width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(_isCorrect ? '✅' : '❌',
                style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              _isCorrect ? 'Excellent !' : 'Pas tout à fait...',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _isCorrect
                      ? AppTheme.secondaryDark
                      : AppTheme.danger),
            ),
          ]),
          const SizedBox(height: 6),
          Text(q.explanation,
              style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textGrey,
                  height: 1.5)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCorrect
                    ? AppTheme.secondary
                    : AppTheme.danger,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
              ),
              child: Text(
                _currentIndex < _questions.length - 1
                    ? 'Continuer →'
                    : 'Voir les résultats 📊',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final accuracy = _questions.isNotEmpty
        ? ((_correct / _questions.length) * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  accuracy >= 80 ? '🏆' : accuracy >= 60 ? '🌟' : '💪',
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 20),
                Text(
                  accuracy >= 80
                      ? 'Révision parfaite !'
                      : accuracy >= 60
                          ? 'Bien révisé !'
                          : 'Continue à réviser !',
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 32),
                Row(children: [
                  _RBox('$_correct/${_questions.length}',
                      'Correctes', AppTheme.secondary, '✅'),
                  const SizedBox(width: 10),
                  _RBox('$accuracy%', 'Précision',
                      AppTheme.primary, '🎯'),
                  const SizedBox(width: 10),
                  _RBox(
                      '${_questions.length - _correct}',
                      'À retravailler',
                      AppTheme.danger,
                      '🔄'),
                ]),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Retour à l\'accueil'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _buildRevisionQuestions();
                      _currentIndex = 0;
                      _correct = 0;
                      _finished = false;
                      _answered = false;
                      _selected = null;
                      _showFb = false;
                    });
                    _qAnim.forward(from: 0);
                  },
                  child: Text('Réviser à nouveau 🔄',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RBox extends StatelessWidget {
  final String val;
  final String lbl;
  final Color color;
  final String icon;

  const _RBox(this.val, this.lbl, this.color, this.icon);

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
              style: const TextStyle(
                  fontSize: 9, color: Colors.grey),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}