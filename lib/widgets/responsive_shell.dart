import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Habillage responsive inspiré de la vidéo de présentation :
///
/// * téléphone (< 600 px de large) : l'app occupe tout l'écran, comme avant ;
/// * tablette / petit PC : l'app est centrée dans un cadre de téléphone,
///   sur le fond en vagues orange et jaune de la vidéo ;
/// * grand écran (≥ 1000 px) : en plus, les phrases d'accroche de la vidéo
///   défilent à gauche du téléphone.
///
/// Les écrans de l'app restent conçus pour une largeur de téléphone : on ne
/// les étire jamais, on les met en scène.
class ResponsiveShell extends StatelessWidget {
  final Widget child;
  const ResponsiveShell({super.key, required this.child});

  static const double phoneBreakpoint = 600;
  static const double wideBreakpoint = 1000;
  static const double frameWidth = 410;
  static const double frameMaxHeight = 860;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < phoneBreakpoint) return child;

      final mq = MediaQuery.of(context);
      final frameH = math.min(frameMaxHeight, c.maxHeight - 48);
      final frameW = math.min(frameWidth, frameH * 0.52);
      final wide = c.maxWidth >= wideBreakpoint;

      final phone = _PhoneFrame(
        width: frameW,
        height: frameH,
        // L'app « croit » tourner sur un téléphone de cette taille.
        child: MediaQuery(
          data: mq.copyWith(
            size: Size(frameW, frameH),
            padding: EdgeInsets.zero,
            viewPadding: EdgeInsets.zero,
            viewInsets: EdgeInsets.zero,
          ),
          child: child,
        ),
      );

      // Material transparent : donne un style de texte correct aux slogans
      // (sinon Flutter les souligne en jaune, style « debug »).
      return Material(
        type: MaterialType.transparency,
        child: Stack(children: [
          const Positioned.fill(child: _WaveBackground()),
          Center(
            child: wide
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Flexible(child: _Taglines()),
                        const SizedBox(width: 48),
                        phone,
                      ],
                    ),
                  )
                : phone,
          ),
        ]),
      );
    });
  }
}

/// Cadre arrondi façon téléphone, avec ombre portée.
class _PhoneFrame extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  const _PhoneFrame(
      {required this.width, required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width + 16,
      height: height + 16,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(46),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: SizedBox(width: width, height: height, child: child),
      ),
    );
  }
}

/// Phrases d'accroche de la vidéo, qui défilent toutes les 4 secondes.
class _Taglines extends StatefulWidget {
  const _Taglines();

  @override
  State<_Taglines> createState() => _TaglinesState();
}

class _TaglinesState extends State<_Taglines> {
  static const _items = [
    (
      'Apprenez les langues locales ivoiriennes autrement.',
      'Des leçons interactives adaptées à votre rythme.'
    ),
    (
      'Créez votre compte en quelques secondes.',
      'Commencez votre parcours linguistique dès aujourd\'hui.'
    ),
    (
      'Des cours personnalisés pour progresser chaque jour.',
      'Gagnez de l\'expérience, relevez des défis et suivez vos progrès.'
    ),
    ('Suivez votre évolution en temps réel.', ''),
    (
      'Débloquez des récompenses au fil de votre apprentissage.',
      'Transformez chaque leçon en une nouvelle réussite.'
    ),
    (
      'Rejoignez une nouvelle génération d\'apprenants.',
      'Prêt à découvrir les langues de la Côte d\'Ivoire ?'
    ),
  ];

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _index = (_index + 1) % _items.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = _items[_index];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🇨🇮', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Billingue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ]),
          const SizedBox(height: 36),
          SizedBox(
            height: 260,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Column(
                key: ValueKey(_index),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 17,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fond orange et jaune en vagues, comme dans la vidéo.
class _WaveBackground extends StatelessWidget {
  const _WaveBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9500), AppTheme.primary],
        ),
      ),
      child: CustomPaint(painter: _WavePainter()),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    void wave(List<Color> colors, double y0, double amp, double phase) {
      final path = Path()..moveTo(0, h * y0);
      for (double x = 0; x <= w; x += 8) {
        final y = h * y0 +
            amp * math.sin((x / w) * 2 * math.pi + phase) +
            amp * 0.4 * math.sin((x / w) * 5 * math.pi + phase * 2);
        path.lineTo(x, y);
      }
      path
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(Rect.fromLTWH(0, 0, w, h));
      canvas.drawPath(path, paint);
    }

    // Vague jaune du haut, à l'envers (accroche lumineuse en haut à droite).
    canvas.save();
    canvas.translate(w, h);
    canvas.rotate(math.pi);
    wave([const Color(0xFFFFD000), const Color(0x00FFB000)], 0.78, 50, 1.2);
    canvas.restore();

    wave([const Color(0xFFFFB300), const Color(0xFFFF8A00)], 0.55, 60, 0.0);
    wave([const Color(0xFFFF8A00), const Color(0xFFFF6B00)], 0.70, 45, 2.0);
    wave([const Color(0xFFFF7A00), const Color(0xFFF25C00)], 0.86, 35, 4.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
