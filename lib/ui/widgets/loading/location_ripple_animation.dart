import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../painter/location_ripple_paint.dart';


class LocationRippleAnimation extends StatefulWidget {
  final Color color;
  final double size;

  const LocationRippleAnimation({
    super.key,
    this.color = Colors.white,
    this.size = 100.0,
  });

  @override
  State<LocationRippleAnimation> createState() => _LocationRippleAnimationState();
}

class _LocationRippleAnimationState extends State<LocationRippleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: LocationRipplePainter(
            animationValue: _controller.value,
            color: widget.color,
          ),
          size: Size(widget.size, widget.size),
        );
      },
    );
  }
}

