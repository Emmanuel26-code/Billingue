import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/lesson_model.dart';

class LessonCard extends StatefulWidget {
  final LessonModel lesson;
  final bool isCompleted;
  final VoidCallback? onTap;
  final int index;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.isCompleted,
    this.onTap,
    required this.index,
  });

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _unlocked => widget.lesson.isUnlocked || widget.isCompleted;

  Color get _borderColor {
    if (widget.isCompleted) return AppTheme.secondary;
    if (_unlocked) return AppTheme.primary;
    return AppTheme.border;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _unlocked ? (_) => _ctrl.forward() : null,
      onTapUp: _unlocked ? (_) => _ctrl.reverse() : null,
      onTapCancel: _unlocked ? () => _ctrl.reverse() : null,
      onTap: _unlocked ? widget.onTap : null,
      child: ScaleTransition(
        scale: _scale,
        child: Opacity(
          opacity: _unlocked ? 1.0 : 0.45,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isCompleted
                  ? AppTheme.secondary.withOpacity(0.07)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _borderColor, width: 2),
              boxShadow: _unlocked
                  ? [
                      BoxShadow(
                        color: _borderColor.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _unlocked
                        ? _borderColor.withOpacity(0.12)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _unlocked ? widget.lesson.emoji : '🔒',
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lesson.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _unlocked
                              ? AppTheme.textDark
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.lesson.subtitle,
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textGrey),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '⚡ +${widget.lesson.xpReward} XP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _unlocked
                              ? const Color(0xFFB8860B)
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isCompleted)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppTheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 18),
                  )
                else if (_unlocked)
                  Icon(Icons.arrow_forward_ios,
                      color: AppTheme.primary, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}