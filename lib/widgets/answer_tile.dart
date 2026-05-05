import 'package:flutter/material.dart';
import '../core/theme.dart';

enum AnswerState { idle, correct, incorrect }

class AnswerTile extends StatefulWidget {
  final String text;
  final AnswerState state;
  final VoidCallback? onTap;

  const AnswerTile({
    super.key,
    required this.text,
    this.state = AnswerState.idle,
    this.onTap,
  });

  @override
  State<AnswerTile> createState() => _AnswerTileState();
}

class _AnswerTileState extends State<AnswerTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shake = Tween<double>(begin: 0, end: 1).animate(_shakeCtrl);
  }

  @override
  void didUpdateWidget(AnswerTile old) {
    super.didUpdateWidget(old);
    if (widget.state == AnswerState.incorrect &&
        old.state != AnswerState.incorrect) {
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  Color get _bg {
    switch (widget.state) {
      case AnswerState.correct:
        return AppTheme.secondary.withOpacity(0.1);
      case AnswerState.incorrect:
        return AppTheme.danger.withOpacity(0.1);
      case AnswerState.idle:
        return Colors.white;
    }
  }

  Color get _border {
    switch (widget.state) {
      case AnswerState.correct:
        return AppTheme.secondary;
      case AnswerState.incorrect:
        return AppTheme.danger;
      case AnswerState.idle:
        return AppTheme.border;
    }
  }

  Color get _text {
    switch (widget.state) {
      case AnswerState.correct:
        return AppTheme.secondaryDark;
      case AnswerState.incorrect:
        return AppTheme.danger;
      case AnswerState.idle:
        return AppTheme.textDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shake,
      builder: (_, child) {
        final dx = _shake.value < 0.5
            ? -8 * (_shake.value * 2)
            : 8 * ((_shake.value - 0.5) * 2);
        return Transform.translate(
          offset: Offset(dx * (1 - _shake.value), 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.state == AnswerState.idle ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(widget.text,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _text)),
              ),
              if (widget.state == AnswerState.correct)
                Icon(Icons.check_circle, color: AppTheme.secondary, size: 22),
              if (widget.state == AnswerState.incorrect)
                Icon(Icons.cancel, color: AppTheme.danger, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}