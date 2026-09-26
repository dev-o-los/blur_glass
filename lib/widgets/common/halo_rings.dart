import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// A crisp, vector-based macOS Protection Halo & Scanning Radar.
class HaloRings extends StatefulWidget {
  const HaloRings({
    super.key,
    required this.child,
    this.size = 224,
    this.accent = BrandColors.blue,
    this.isPulsing = true,
  });

  final Widget child;
  final double size;
  final Color accent;
  final bool isPulsing;

  @override
  State<HaloRings> createState() => _HaloRingsState();
}

class _HaloRingsState extends State<HaloRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = colors.isDark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RadarHaloPainter(
                  accent: widget.accent,
                  pulseProgress: widget.isPulsing ? progress : 0.0,
                  isDark: isDark,
                ),
              ),
              Container(
                width: widget.size * 0.58,
                height: widget.size * 0.58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.heroCore,
                  border: Border.all(
                    color: widget.accent.withValues(alpha: 0.85),
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accent.withValues(alpha: isDark ? 0.3 : 0.2),
                      blurRadius: 24,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: widget.child,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RadarHaloPainter extends CustomPainter {
  _RadarHaloPainter({
    required this.accent,
    required this.pulseProgress,
    required this.isDark,
  });

  final Color accent;
  final double pulseProgress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: isDark ? 0.16 : 0.12),
          accent.withValues(alpha: isDark ? 0.04 : 0.02),
          Colors.transparent,
        ],
        stops: const [0.4, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));
    canvas.drawCircle(center, maxRadius, glowPaint);

    final outerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = accent.withValues(alpha: isDark ? 0.18 : 0.22);
    canvas.drawCircle(center, maxRadius * 0.95, outerRing);

    final midRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = accent.withValues(alpha: isDark ? 0.12 : 0.16);
    canvas.drawCircle(center, maxRadius * 0.78, midRing);

    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = accent.withValues(alpha: isDark ? 0.28 : 0.35);

    const tickCount = 36;
    for (int i = 0; i < tickCount; i++) {
      final angle = i * (2 * math.pi / tickCount);
      final isMajor = i % 9 == 0;
      final tickLength = isMajor ? 6.0 : 3.0;
      final rOuter = maxRadius * 0.95;
      final rInner = rOuter - tickLength;

      canvas.drawLine(
        Offset(center.dx + math.cos(angle) * rInner,
            center.dy + math.sin(angle) * rInner),
        Offset(center.dx + math.cos(angle) * rOuter,
            center.dy + math.sin(angle) * rOuter),
        isMajor
            ? (tickPaint
              ..strokeWidth = 1.8
              ..color = accent.withValues(alpha: isDark ? 0.45 : 0.55))
            : (tickPaint
              ..strokeWidth = 1.0
              ..color = accent.withValues(alpha: isDark ? 0.2 : 0.25)),
      );
    }

    if (pulseProgress > 0) {
      final waveRadius = (maxRadius * 0.58) +
          ((maxRadius * 0.92 - maxRadius * 0.58) * pulseProgress);
      final waveOpacity = (1.0 - pulseProgress).clamp(0.0, 1.0) * 0.45;
      final wavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = accent.withValues(alpha: waveOpacity);
      canvas.drawCircle(center, waveRadius, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarHaloPainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.pulseProgress != pulseProgress ||
      oldDelegate.isDark != isDark;
}
