import 'package:flutter/material.dart';

class CustomDottedBorder extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color borderColor;
  final double strokeWidth;
  final double gap;
  final double dashLength;

  const CustomDottedBorder({
    super.key,
    required this.child,
    this.borderRadius = 12.0,
    this.borderColor = Colors.grey,
    this.strokeWidth = 1.5,
    this.gap = 4.0,
    this.dashLength = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(
        borderRadius: borderRadius,
        borderColor: borderColor,
        strokeWidth: strokeWidth,
        gap: gap,
        dashLength: dashLength,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final double borderRadius;
  final Color borderColor;
  final double strokeWidth;
  final double gap;
  final double dashLength;

  _DottedBorderPainter({
    required this.borderRadius,
    required this.borderColor,
    required this.strokeWidth,
    required this.gap,
    required this.dashLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rRect);
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(
            distance,
            nextDistance < metric.length ? nextDistance : metric.length,
          ),
          paint,
        );
        distance += dashLength + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
