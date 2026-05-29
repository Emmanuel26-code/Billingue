import 'package:flutter/material.dart' hide Badge;
import '../core/theme.dart';
import '../services/badge_service.dart';

class BadgeNotification extends StatefulWidget {
  final Badge badge;
  final VoidCallback onDismiss;

  const BadgeNotification({
    super.key,
    required this.badge,
    required this.onDismiss,
  });

  @override
  State<BadgeNotification> createState() =>
      _BadgeNotificationState();
}

class _BadgeNotificationState extends State<BadgeNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0, 0.4));
    _ctrl.forward();

    // Auto-dismiss après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppTheme.primary.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(widget.badge.emoji,
                    style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎉 Nouveau badge !',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary)),
                  const SizedBox(height: 3),
                  Text(widget.badge.title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 2),
                  Text(widget.badge.description,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textGrey)),
                ],
              ),
            ),
            GestureDetector(
              onTap: widget.onDismiss,
              child: Icon(Icons.close,
                  size: 18, color: Colors.grey.shade400),
            ),
          ]),
        ),
      ),
    );
  }
}

// Helper pour afficher la notification de badge
void showBadgeNotification(BuildContext context, Badge badge) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: BadgeNotification(
          badge: badge,
          onDismiss: () => entry.remove(),
        ),
      ),
    ),
  );
  overlay.insert(entry);
}