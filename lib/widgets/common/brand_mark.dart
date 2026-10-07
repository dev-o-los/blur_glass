import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// A high-fidelity brand mark representing the Privacy Iris lens.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: BrandColors.markGradient,
        ),
        borderRadius: BorderRadius.circular(size * 0.225),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 0.75,
        ),
        boxShadow: [
          BoxShadow(
            color: BrandColors.blueDark.withValues(alpha: 0.35),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: CustomPaint(
        painter: ApertureIrisPainter(),
      ),
    );
  }
}

class ApertureIrisPainter extends CustomPainter {
  const ApertureIrisPainter({this.color = Colors.white});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..color = color.withValues(alpha: 0.25);
    canvas.drawCircle(center, radius * 0.76, ringPaint);

    final dotPaint = Paint()..color = color;
    const dotCount = 8;
    for (int i = 0; i < dotCount; i++) {
      final angle = (i * 2 * math.pi / dotCount) - (math.pi / 2);
      final dotPos = Offset(
        center.dx + math.cos(angle) * (radius * 0.52),
        center.dy + math.sin(angle) * (radius * 0.52),
      );
      canvas.drawCircle(dotPos, radius * 0.09, dotPaint);
    }

    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) + (math.pi / 4);
      final sparklePos = Offset(
        center.dx + math.cos(angle) * (radius * 0.74),
        center.dy + math.sin(angle) * (radius * 0.74),
      );
      canvas.drawCircle(
        sparklePos,
        radius * 0.055,
        dotPaint..color = color.withValues(alpha: 0.9),
      );
    }

    canvas.drawCircle(center, radius * 0.14, dotPaint..color = color);
  }

  @override
  bool shouldRepaint(covariant ApertureIrisPainter oldDelegate) =>
      oldDelegate.color != color;
}
