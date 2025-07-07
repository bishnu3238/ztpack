// lib/features/auth/presentation/widgets/error_message_box.dart

import 'package:flutter/material.dart';

class ErrorMessageBox extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  const ErrorMessageBox({
    super.key,
    required this.message,
    this.onDismiss,
    this.icon = Icons.error_outline,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: textColor.withValues(alpha: 0.7),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  // Factory constructor for success message
  factory ErrorMessageBox.success({
    required String message,
    VoidCallback? onDismiss,
  }) {
    return ErrorMessageBox(
      message: message,
      onDismiss: onDismiss,
      icon: Icons.check_circle_outline,
      backgroundColor: Colors.green.shade600,
      textColor: Colors.lightGreenAccent.shade700,
    );
  }

  // Factory constructor for info message
  factory ErrorMessageBox.info({
    required String message,
    VoidCallback? onDismiss,
  }) {
    return ErrorMessageBox(
      message: message,
      onDismiss: onDismiss,
      icon: Icons.info_outline,
      backgroundColor: Colors.white,
      textColor: Colors.blueGrey.shade900,
    );
  }
}