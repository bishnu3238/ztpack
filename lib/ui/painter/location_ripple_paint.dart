import 'dart:math' as math;

import 'package:flutter/material.dart';

class LocationRipplePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  LocationRipplePainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw pin base
    final pinPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final pinPath = Path();
    final pinSize = size.width * 0.25;
    final pinTop = size.height * 0.4;

    // Draw location pin
    pinPath.moveTo(center.dx, pinTop);
    pinPath.arcTo(
        Rect.fromCenter(
            center: Offset(center.dx, pinTop),
            width: pinSize,
            height: pinSize
        ),
        math.pi,
        math.pi,
        false
    );
    pinPath.lineTo(center.dx, center.dy + pinSize * 0.6);
    pinPath.close();

    canvas.drawPath(pinPath, pinPaint);

    // Draw pin circle
    canvas.drawCircle(
        Offset(center.dx, pinTop),
        pinSize * 0.3,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill
    );

    // Draw ripples
    for (int i = 0; i < 3; i++) {
      final rippleProgress = (animationValue - (i * 0.3)) % 1.0;

      if (rippleProgress >= 0) {
        // Size increases as animation progresses
        final rippleSize = rippleProgress * size.width * 0.8;

        // Opacity decreases as animation progresses
        final rippleOpacity = (1.0 - rippleProgress) * 0.4;

        final ripplePaint = Paint()
          ..color = color.withOpacity(rippleOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        canvas.drawCircle(
            center,
            rippleSize,
            ripplePaint
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant LocationRipplePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}