import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import 'hearts_timer_widget.dart';

class HeartWidget extends StatelessWidget {
  final UserProgress? progress;
  final int? hearts;      // Pour usage simple sans timer
  final int maxHearts;
  final bool showTimer;

  const HeartWidget({
    super.key,
    this.progress,
    this.hearts,
    this.maxHearts = 5,
    this.showTimer = false,
  });

  @override
  Widget build(BuildContext context) {
    // Mode avec timer (utilise UserProgress)
    if (progress != null && showTimer) {
      return HeartsTimerWidget(
        progress: progress!,
        showTimer: showTimer,
      );
    }

    // Mode simple (juste les cœurs)
    final h = hearts ?? progress?.hearts ?? 5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxHearts, (i) {
        final active = i < h;
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
    );
  }
}