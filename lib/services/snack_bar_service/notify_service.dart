import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';

enum NotificationPosition {
  top,
  bottom,
  center,
}

enum NotificationType {
  success,
  error,
  info,
  warning,
  custom,
}

class NotifyService {
  // Singleton pattern
  static final NotifyService _instance = NotifyService._internal();
  factory NotifyService() => _instance;
  NotifyService._internal();

  // Core notification method
  static OverlayEntry? _currentOverlay;

  // Base notification method
  static void _showNotification({
    required BuildContext context,
    required Widget content,
    NotificationPosition position = NotificationPosition.bottom,
    Duration duration = const Duration(seconds: 3),
    bool dismissible = true,
    VoidCallback? onDismiss,
  }) {
    // Hide current notification if exists
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }

    // Calculate position
    Alignment alignment;
    switch (position) {
      case NotificationPosition.top:
        alignment = Alignment.topCenter;
        break;
      case NotificationPosition.center:
        alignment = Alignment.center;
        break;
      case NotificationPosition.bottom:
        alignment = Alignment.bottomCenter;
        break;
    }

    // Create overlay entry
    _currentOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: dismissible
            ? () {
                _currentOverlay?.remove();
                _currentOverlay = null;
                if (onDismiss != null) onDismiss();
              }
            : null,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Align(
              alignment: alignment,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );

    // Insert overlay
    Overlay.of(context).insert(_currentOverlay!);

    // Auto-dismiss after duration
    if (duration != Duration.zero) {
      Timer(duration, () {
        if (_currentOverlay != null) {
          _currentOverlay!.remove();
          _currentOverlay = null;
          if (onDismiss != null) onDismiss();
        }
      });
    }
  }

  // Snackbar method
  static void snackbar({
    required BuildContext context,
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    VoidCallback? onTap,
    bool showIcon = true,
    Widget? customContent,
  }) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    // Configure based on type
    switch (type) {
      case NotificationType.success:
        backgroundColor = Colors.greenAccent.shade700;// Theme.of(context).colorScheme.primary;
        textColor = Colors.white ; //Theme.of(context).colorScheme.onPrimary;
        icon = Icons.check_circle;
        break;
      case NotificationType.error:
        backgroundColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.error;
        break;
      case NotificationType.warning:
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case NotificationType.info:
        backgroundColor = Theme.of(context).colorScheme.primary;
        textColor = Theme.of(context).colorScheme.onPrimary;
        icon = Icons.info;
        break;
      case NotificationType.custom:
        backgroundColor = Theme.of(context).colorScheme.surface;
        textColor = Theme.of(context).colorScheme.onSurface;
        icon = Icons.notifications;
        break;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: customContent ??
              Row(
                children: [
                  if (showIcon) Icon(icon, color: textColor, size: 20),
                  if (showIcon) const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ],
              ),
          backgroundColor: backgroundColor,
          behavior: behavior,
          duration: duration,
          action: onTap != null
              ? SnackBarAction(
                  label: 'Dismiss',
                  textColor: textColor,
                  onPressed: onTap,
                )
              : null,
        ),
      );
  }

  // Toast notification
  static void toast({
    required BuildContext context,
    required String message,
    NotificationType type = NotificationType.info,
    NotificationPosition position = NotificationPosition.bottom,
    Duration duration = const Duration(seconds: 2),
    bool showIcon = true,
  }) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case NotificationType.success:
        backgroundColor = Colors.green.shade800;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case NotificationType.error:
        backgroundColor = Colors.red.shade800;
        textColor = Colors.white;
        icon = Icons.error;
        break;
      case NotificationType.warning:
        backgroundColor = Colors.orange.shade800;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case NotificationType.info:
        backgroundColor = Colors.blue.shade800;
        textColor = Colors.white;
        icon = Icons.info;
        break;
      case NotificationType.custom:
        backgroundColor = Colors.grey.shade800;
        textColor = Colors.white;
        icon = Icons.notifications;
        break;
    }

    _showNotification(
      context: context,
      position: position,
      duration: duration,
      content: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) Icon(icon, color: textColor, size: 20),
            if (showIcon) const SizedBox(width: 10),
            Text(
              message,
              maxLines: 1,
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  // Alert dialog style notification
  static void alert({
    required BuildContext context,
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onDismiss,
  }) {
    Color backgroundColor;
    Color iconColor;
    IconData icon;

    switch (type) {
      case NotificationType.success:
        backgroundColor = Colors.green.shade50;
        iconColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case NotificationType.error:
        backgroundColor = Colors.red.shade50;
        iconColor = Colors.red;
        icon = Icons.error;
        break;
      case NotificationType.warning:
        backgroundColor = Colors.orange.shade50;
        iconColor = Colors.orange;
        icon = Icons.warning;
        break;
      case NotificationType.info:
        backgroundColor = Colors.blue.shade50;
        iconColor = Colors.blue;
        icon = Icons.info;
        break;
      case NotificationType.custom:
        backgroundColor = Colors.grey.shade100;
        iconColor = Colors.grey.shade700;
        icon = Icons.notifications;
        break;
    }

    _showNotification(
      context: context,
      position: NotificationPosition.center,
      duration: duration,
      onDismiss: onDismiss,
      content: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _currentOverlay?.remove();
                _currentOverlay = null;
                if (onDismiss != null) onDismiss();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 40),
              ),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }

  // Amazon-style notification
  static void amazonStyle({
    required BuildContext context,
    required String message,
    required String actionText,
    VoidCallback? onAction,
    String title = '',
    Duration duration = const Duration(seconds: 4),
  }) {
    _showNotification(
      context: context,
      position: NotificationPosition.top,
      duration: duration,
      content: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: MediaQuery.of(context).size.width * 0.95,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            Text(message),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _currentOverlay?.remove();
                  _currentOverlay = null;
                  if (onAction != null) onAction();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.teal.shade700,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  actionText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Google Files app style notification
  static void googleFilesStyle({
    required BuildContext context,
    required String message,
    String title = '',
    Duration duration = const Duration(seconds: 3),
    Widget? leadingIcon,
    Color? color,
    List<Widget>? actions,
  }) {
    _showNotification(
      context: context,
      position: NotificationPosition.bottom,
      duration: duration,
      content: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: MediaQuery.of(context).size.width * 0.95,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color ?? Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              leadingIcon,
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
            if (actions != null) ...actions,
          ],
        ),
      ),
    );
  }

  // Loading notification with animation
  static OverlayEntry? _loadingOverlay;

  static void showLoading({
    required BuildContext context,
    String message = 'Loading...',
    bool barrierDismissible = false,
  }) {
    if (_loadingOverlay != null) {
      _loadingOverlay!.remove();
      _loadingOverlay = null;
    }

    _loadingOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: barrierDismissible
            ? () {
                _loadingOverlay?.remove();
                _loadingOverlay = null;
              }
            : null,
        child: Container(
          color: Colors.black54,
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_loadingOverlay!);
  }

  static void hideLoading() {
    if (_loadingOverlay != null) {
      _loadingOverlay!.remove();
      _loadingOverlay = null;
    }
  }

  // Animation with sparkles
  static void sparkleAnimation({
    required BuildContext context,
    required String message,
    NotificationType type = NotificationType.success,
    IconData icon = Icons.star,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Get colors based on type
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case NotificationType.success:
        backgroundColor = Colors.green.shade800;
        textColor = Colors.white;
        break;
      case NotificationType.error:
        backgroundColor = Colors.red.shade800;
        textColor = Colors.white;
        break;
      case NotificationType.warning:
        backgroundColor = Colors.orange.shade800;
        textColor = Colors.white;
        break;
      case NotificationType.info:
        backgroundColor = Colors.blue.shade800;
        textColor = Colors.white;
        break;
      case NotificationType.custom:
        backgroundColor = Colors.purple.shade800;
        textColor = Colors.white;
        break;
    }

    // Create overlay for animation
    final overlay = Overlay.of(context);
    final animationOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: SparkleAnimation(
              duration: const Duration(seconds: 2),
              icon: icon,
            ),
          ),
        ],
      ),
    );

    // Show animation
    overlay.insert(animationOverlay);

    // Show message
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: TextStyle(color: textColor),
          ),
          backgroundColor: backgroundColor,
          duration: duration,
        ),
      );

    // Remove animation after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      animationOverlay.remove();
    });
  }

  // Animation with Lottie
  static void lottieAnimation({
    required BuildContext context,
    required String message,
    required String lottieAsset,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black87,
    NotificationPosition position = NotificationPosition.center,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showNotification(
      context: context,
      position: position,
      duration: duration,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Lottie.asset(
                lottieAsset,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example implementation of SparkleAnimation
class SparkleAnimation extends StatefulWidget {
  final Duration duration;
  final IconData? icon;

  const SparkleAnimation({
    Key? key,
    required this.duration,
    this.icon,
  }) : super(key: key);

  @override
  State<SparkleAnimation> createState() => _SparkleAnimationState();
}

class _SparkleAnimationState extends State<SparkleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Sparkle> _sparkles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Create sparkles
    for (int i = 0; i < 30; i++) {
      _sparkles.add(Sparkle(
        position: Offset(
          _random.nextDouble() * 400,
          _random.nextDouble() * 600,
        ),
        color: _getRandomColor(),
        size: _random.nextDouble() * 10 + 5,
        angle: _random.nextDouble() * pi * 2,
      ));
    }

    _controller.forward();
  }

  Color _getRandomColor() {
    final List<Color> colors = [
      Colors.amber,
      Colors.yellow,
      Colors.orange,
      Colors.pink.shade300,
      Colors.purple.shade300,
      Colors.blue.shade300,
    ];
    return colors[_random.nextInt(colors.length)];
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
          painter: SparklePainter(
            sparkles: _sparkles,
            progress: _controller.value,
            icon: widget.icon,
          ),
        );
      },
    );
  }
}

class Sparkle {
  final Offset position;
  final Color color;
  final double size;
  final double angle;

  Sparkle({
    required this.position,
    required this.color,
    required this.size,
    required this.angle,
  });
}

class SparklePainter extends CustomPainter {
  final List<Sparkle> sparkles;
  final double progress;
  final IconData? icon;

  SparklePainter({
    required this.sparkles,
    required this.progress,
    this.icon,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final sparkle in sparkles) {
      final paint = Paint()
        ..color = sparkle.color.withOpacity(1 - progress)
        ..style = PaintingStyle.fill;

      final center = Offset(
        sparkle.position.dx + size.width / 2 * progress * cos(sparkle.angle),
        sparkle.position.dy + size.height / 2 * progress * sin(sparkle.angle),
      );

      canvas.drawCircle(center, sparkle.size * (1 - progress), paint);
    }

    if (icon != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon!.codePoint),
          style: TextStyle(
            fontSize: 48 + (20 * progress),
            color: Colors.white.withOpacity(1 - progress),
            fontFamily: icon!.fontFamily,
            package: icon!.fontPackage,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          size.width / 2 - textPainter.width / 2,
          size.height / 2 - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(SparklePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Example implementation of CouponSparkleAnimation
class CouponSparkleAnimation extends StatefulWidget {
  final Duration duration;

  const CouponSparkleAnimation({
    Key? key,
    required this.duration,
  }) : super(key: key);

  @override
  State<CouponSparkleAnimation> createState() => _CouponSparkleAnimationState();
}

class _CouponSparkleAnimationState extends State<CouponSparkleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<CouponSparkle> _sparkles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Create stars and confetti
    for (int i = 0; i < 50; i++) {
      _sparkles.add(CouponSparkle(
        position: Offset(
          _random.nextDouble() * 400,
          _random.nextDouble() * 600,
        ),
        color: _getRandomColor(),
        size: _random.nextDouble() * 15 + 5,
        velocity: Offset(
          (_random.nextDouble() * 2 - 1) * 10,
          -_random.nextDouble() * 10 - 10,
        ),
        rotation: _random.nextDouble() * pi * 2,
        rotationSpeed: (_random.nextDouble() * 2 - 1) * 0.2,
        shape: _random.nextBool() ? SparkleShape.star : SparkleShape.confetti,
      ));
    }

    _controller.forward();
  }

  Color _getRandomColor() {
    final List<Color> colors = [
      Colors.amber,
      Colors.yellow,
      Colors.orange,
      Colors.pink.shade300,
      Colors.purple.shade300,
      Colors.blue.shade300,
      Colors.green.shade300,
    ];
    return colors[_random.nextInt(colors.length)];
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
          painter: CouponSparklePainter(
            sparkles: _sparkles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

enum SparkleShape { star, confetti }

class CouponSparkle {
  final Offset position;
  final Color color;
  final double size;
  final Offset velocity;
  final double rotation;
  final double rotationSpeed;
  final SparkleShape shape;

  CouponSparkle({
    required this.position,
    required this.color,
    required this.size,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

class CouponSparklePainter extends CustomPainter {
  final List<CouponSparkle> sparkles;
  final double progress;

  CouponSparklePainter({
    required this.sparkles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final sparkle in sparkles) {
      final position = Offset(
        sparkle.position.dx + sparkle.velocity.dx * progress,
        sparkle.position.dy +
            sparkle.velocity.dy * progress +
            20 * progress * progress, // Add gravity
      );

      final opacity = 1.0 - progress;
      final paint = Paint()
        ..color = sparkle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(sparkle.rotation + sparkle.rotationSpeed * progress * 10);

      if (sparkle.shape == SparkleShape.star) {
        _drawStar(canvas, sparkle.size, paint);
      } else {
        _drawConfetti(canvas, sparkle.size, paint);
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final outerRadius = size;
    final innerRadius = size * 0.4;
    final centerX = 0.0;
    final centerY = 0.0;

    for (int i = 0; i < 5; i++) {
      final outerAngle = 2 * pi * i / 5 - pi / 2;
      final innerAngle = 2 * pi * (i + 0.5) / 5 - pi / 2;

      final outerX = centerX + outerRadius * cos(outerAngle);
      final outerY = centerY + outerRadius * sin(outerAngle);
      final innerX = centerX + innerRadius * cos(innerAngle);
      final innerY = centerY + innerRadius * sin(innerAngle);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }

      path.lineTo(innerX, innerY);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawConfetti(Canvas canvas, double size, Paint paint) {
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size,
        height: size * 0.5,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CouponSparklePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
