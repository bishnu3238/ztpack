// Custom Painter for Wave Background
import 'package:flutter/material.dart';
import 'dart:math'as math;

class WaveBackgroundPainter extends CustomPainter {
  final double animationValue;
  final Color baseColor;

  WaveBackgroundPainter({
    required this.animationValue,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
    Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [baseColor.withValues(alpha: 0.7), baseColor.withValues(alpha: 0.4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw multiple waves
    _drawWave(canvas, size, 1.0, 0.4);
    _drawWave(canvas, size, 0.8, 0.6);
    _drawWave(canvas, size, 0.6, 0.8);
  }

  void _drawWave(
      Canvas canvas,
      Size size,
      double amplitude,
      double phaseShift,
      ) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.5);

    for (double x = 0; x <= size.width; x++) {
      final wave =
          amplitude *
              math.sin(
                (x / size.width * 2 * math.pi) +
                    (animationValue * 2 * math.pi * phaseShift),
              );
      final y = size.height * 0.5 + wave * size.height * 0.2;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = baseColor.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant WaveBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
