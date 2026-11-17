import 'dart:async';
import 'package:flutter/material.dart';
import '../models/lesson_model.dart';

class HeartsTimerWidget extends StatefulWidget {
  final UserProgress progress;
  final bool showTimer;

  const HeartsTimerWidget({
    super.key,
    required this.progress,
    this.showTimer = true,
  });

  @override
  State<HeartsTimerWidget> createState() =>
      _HeartsTimerWidgetState();
}

class _HeartsTimerWidgetState extends State<HeartsTimerWidget> {
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    widget.progress.syncHearts();
    _secondsLeft = widget.progress.secondsUntilNextHeart;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      // Régénère un cœur si le timer atteint 0
      if (_secondsLeft <= 1 &&
          !widget.progress.heartsAreFull) {
        widget.progress.syncHearts();
        setState(() {
          _secondsLeft =
              widget.progress.secondsUntilNextHeart;
        });
      } else {
        setState(() {
          if (_secondsLeft > 0) _secondsLeft--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerText {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hearts = widget.progress.hearts;
    final isFull = widget.progress.heartsAreFull;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            final active = i < hearts;
            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  active ? '❤️' : '🖤',
                  key: ValueKey('heart_${i}_$active'),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            );
          }),
        ),
        if (widget.showTimer && !isFull && hearts > 0) ...[
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined,
                  size: 10, color: Colors.grey.shade500),
              const SizedBox(width: 3),
              Text(
                _timerText,
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ],
    );
  }
}