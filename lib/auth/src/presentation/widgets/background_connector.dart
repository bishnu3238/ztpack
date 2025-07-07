// src/presentation/widgets/background_connector.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class BackgroundConnector extends StatefulWidget {
  final Color accentColor;
  final bool isKeyboardVisible;
  final bool isDarkMode;

  const BackgroundConnector({
    Key? key,
    required this.accentColor,
    required this.isKeyboardVisible,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<BackgroundConnector> createState() => _BackgroundConnectorState();
}

class _BackgroundConnectorState extends State<BackgroundConnector> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Background subtle color
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: widget.isDarkMode
                  ? [
                Colors.black,
                Color.lerp(Colors.black, widget.accentColor, 0.1) ?? Colors.black,
              ]
                  : [
                Colors.white,
                Color.lerp(Colors.white, widget.accentColor, 0.05) ?? Colors.white,
              ],
            ),
          ),
        ),

        // Abstract service connector elements
        if (!widget.isKeyboardVisible) ...[
          // Top right corner decorations
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              size: Size(size.width * 0.5, size.height * 0.3),
              painter: ConnectorPainter(
                color: widget.accentColor.withOpacity(0.05),
                nodeColor: widget.accentColor.withOpacity(0.1),
                animationValue: _animationController.value,
              ),
            ),
          ),

          // Bottom left nodes
          Positioned(
            bottom: 0,
            left: 0,
            child: CustomPaint(
              size: Size(size.width * 0.6, size.height * 0.25),
              painter: NodesPainter(
                color: widget.accentColor.withOpacity(0.08),
                animationValue: _animationController.value,
              ),
            ),
          ),

          // Floating circle decorations
          ...List.generate(5, (index) {
            final random = math.Random(index);
            final double posX = random.nextDouble() * size.width;
            final double posY = random.nextDouble() * size.height;
            final double radius = 10 + random.nextDouble() * 40;

            return Positioned(
              left: posX,
              top: posY,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final pulseValue = math.sin((_animationController.value * math.pi * 2) + index);
                  final scale = 0.8 + (pulseValue * 0.2).abs();

                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: 0.1 + (pulseValue * 0.1).abs(),
                      child: Container(
                        width: radius,
                        height: radius,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.accentColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ],
    );
  }
}

class ConnectorPainter extends CustomPainter {
  final Color color;
  final Color nodeColor;
  final double animationValue;

  ConnectorPainter({
    required this.color,
    required this.nodeColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final nodePaint = Paint()
      ..color = nodeColor
      ..style = PaintingStyle.fill;

    // Define connection points
    final points = [
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.9, size.height * 0.7),
      Offset(size.width * 0.3, size.height * 0.6),
    ];

    // Draw connecting lines between nodes
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];

      // Create curved connection
      path.quadraticBezierTo(
        (p0.dx + p1.dx) / 2 + math.sin(animationValue * math.pi * 2) * 10,
        (p0.dy + p1.dy) / 2 + math.cos(animationValue * math.pi * 2) * 10,
        p1.dx,
        p1.dy,
      );
    }

    // Connect back to first point to create a network
    path.quadraticBezierTo(
      (points.last.dx + points[0].dx) / 2,
      (points.last.dy + points[0].dy) / 2,
      points[0].dx,
      points[0].dy,
    );

    canvas.drawPath(path, paint);

    // Draw nodes at connection points
    for (final point in points) {
      final pulseValue = math.sin((animationValue * math.pi * 2) + points.indexOf(point));
      final radius = 4 + pulseValue.abs() * 2;
      canvas.drawCircle(point, radius, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class NodesPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  NodesPainter({
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw network nodes
    final nodePositions = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.1, size.height * 0.7),
      Offset(size.width * 0.4, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.9),
      Offset(size.width * 0.5, size.height * 0.8),
      Offset(size.width * 0.7, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.2),
    ];

    // Connect nodes
    for (int i = 0; i < nodePositions.length; i++) {
      for (int j = i + 1; j < nodePositions.length; j++) {
        // Only connect if nodes are somewhat close to each other
        final distance = (nodePositions[i] - nodePositions[j]).distance;
        if (distance < size.width * 0.3) {
          // Animate line opacity based on distance
          final opacity = 1.0 - (distance / (size.width * 0.3));
          linePaint.color = color.withOpacity(opacity * 0.5);

          // Draw connecting line
          canvas.drawLine(nodePositions[i], nodePositions[j], linePaint);
        }
      }
    }

    // Draw nodes with subtle animation
    for (int i = 0; i < nodePositions.length; i++) {
      final pulseValue = math.sin((animationValue * math.pi * 2) + i);
      final radius = 3 + pulseValue.abs() * 2;

      canvas.drawCircle(nodePositions[i], radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}