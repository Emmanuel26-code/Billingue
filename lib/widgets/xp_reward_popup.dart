import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';

class XPRewardPopup extends StatefulWidget {
  final int xpEarned;
  final int coinsEarned;
  final bool isPerfect;
  final bool hasSpeedBonus;
  final bool hasStreakBonus;

  const XPRewardPopup({
    super.key,
    required this.xpEarned,
    required this.coinsEarned,
    this.isPerfect = false,
    this.hasSpeedBonus = false,
    this.hasStreakBonus = false,
  });

  @override
  State<XPRewardPopup> createState() => _XPRewardPopupState();
}

class _XPRewardPopupState extends State<XPRewardPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0, 0.4));
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚡',
                        style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text(
                      '+${widget.xpEarned} XP',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${widget.coinsEarned} 🪙',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB8860B)),
                    ),
                    if (widget.isPerfect ||
                        widget.hasSpeedBonus ||
                        widget.hasStreakBonus) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (widget.isPerfect)
                            _Bonus('💯 Parfait !'),
                          if (widget.hasSpeedBonus)
                            _Bonus('⚡ Vitesse !'),
                          if (widget.hasStreakBonus)
                            _Bonus('🔥 Série !'),
                        ],
                      ),
                    ],
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

class _Bonus extends StatelessWidget {
  final String label;
  const _Bonus(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary)),
    );
  }
}

// Helper pour afficher le popup
void showXPReward(
  BuildContext context, {
  required int xpEarned,
  required int coinsEarned,
  bool isPerfect = false,
  bool hasSpeedBonus = false,
  bool hasStreakBonus = false,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    barrierDismissible: true,
    builder: (_) => XPRewardPopup(
      xpEarned: xpEarned,
      coinsEarned: coinsEarned,
      isPerfect: isPerfect,
      hasSpeedBonus: hasSpeedBonus,
      hasStreakBonus: hasStreakBonus,
    ),
  );
}