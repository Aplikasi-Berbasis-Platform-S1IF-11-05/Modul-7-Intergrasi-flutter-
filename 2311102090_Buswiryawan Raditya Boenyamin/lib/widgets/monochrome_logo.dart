// 2311102090-Buswiryawan Raditya Boenyamin
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MonochromeLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool showLabel;

  const MonochromeLogo({
    super.key,
    this.size = 80,
    this.color,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = color ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: primaryColor, width: size * 0.08),
          ),
          padding: EdgeInsets.all(size * 0.15),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _LogoPainter(primaryColor),
                ),
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 16),
          Text(
            'TASK_SYSTEM_v2',
            style: GoogleFonts.jetBrainsMono(
              fontSize: size * 0.15,
              fontWeight: FontWeight.w900,
              color: primaryColor,
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;
  _LogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // A sharp, geometric "T" and checkmark hybrid
    final path = Path();
    
    // The "T" vertical bar
    path.moveTo(size.width * 0.4, 0);
    path.lineTo(size.width * 0.6, 0);
    path.lineTo(size.width * 0.6, size.height);
    path.lineTo(size.width * 0.4, size.height);
    path.close();

    // The horizontal slash (checkmark style)
    path.moveTo(0, size.height * 0.4);
    path.lineTo(size.width, size.height * 0.1);
    path.lineTo(size.width, size.height * 0.3);
    path.lineTo(0, size.height * 0.6);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
