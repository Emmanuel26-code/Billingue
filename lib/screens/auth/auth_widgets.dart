import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AuthTopBar extends StatelessWidget {
  final double progress;
  final VoidCallback onBack;

  const AuthTopBar({super.key, required this.progress, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Icons.arrow_back,
                color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 600),
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  minHeight: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool obscure;
  final Widget? suffix;

  const AuthInput({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

class OrangeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const OrangeButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  const GoogleButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                  color: Color(0xFFEA4335), shape: BoxShape.circle),
              child: const Center(
                child: Text('G',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 10),
            const Text('CONTINUE WITH GOOGLE',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class AfricaMap extends StatelessWidget {
  final double size;
  final Color color;

  const AfricaMap({
    super.key,
    required this.size,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.1,
      child: CustomPaint(painter: _AfricaPainter(color: color)),
    );
  }
}

class _AfricaPainter extends CustomPainter {
  final Color color;
  const _AfricaPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(w * 0.30, h * 0.05);
    path.quadraticBezierTo(w * 0.50, h * 0.01, w * 0.65, h * 0.09);
    path.quadraticBezierTo(w * 0.80, h * 0.17, w * 0.80, h * 0.28);
    path.quadraticBezierTo(w * 0.88, h * 0.38, w * 0.84, h * 0.52);
    path.quadraticBezierTo(w * 0.80, h * 0.64, w * 0.75, h * 0.72);
    path.quadraticBezierTo(w * 0.70, h * 0.82, w * 0.64, h * 0.90);
    path.quadraticBezierTo(w * 0.57, h * 1.00, w * 0.50, h * 1.05);
    path.quadraticBezierTo(w * 0.43, h * 1.00, w * 0.38, h * 0.90);
    path.quadraticBezierTo(w * 0.28, h * 0.76, w * 0.24, h * 0.62);
    path.quadraticBezierTo(w * 0.16, h * 0.50, w * 0.18, h * 0.37);
    path.quadraticBezierTo(w * 0.20, h * 0.20, w * 0.30, h * 0.05);
    path.close();
    canvas.drawPath(path, paint);
    // Point CI
    canvas.drawCircle(Offset(w * 0.42, h * 0.48), w * 0.04,
        Paint()..color = AppTheme.primary);
    // Drapeau CI
    final fw = w * 0.13;
    final fh = h * 0.06;
    final fx = w * 0.52;
    final fy = h * 0.07;
    canvas.drawRect(Rect.fromLTWH(fx, fy, fw / 3, fh),
        Paint()..color = AppTheme.primary);
    canvas.drawRect(Rect.fromLTWH(fx + fw / 3, fy, fw / 3, fh),
        Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(fx + fw * 2 / 3, fy, fw / 3, fh),
        Paint()..color = const Color(0xFF2ECC71));
  }

  @override
  bool shouldRepaint(_AfricaPainter old) => false;
}