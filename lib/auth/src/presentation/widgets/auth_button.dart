// src/presentation/widgets/auth_button.dart
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? accentColor;
  final bool useGlassmorphism;

  const AuthButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.accentColor,
    this.useGlassmorphism = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = accentColor ?? Theme.of(context).colorScheme.primary;
    final Color textColor = useGlassmorphism
        ? Colors.white
        : Theme.of(context).colorScheme.onPrimary;

    final Widget buttonChild = isLoading
        ? SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(textColor),
      ),
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 10),
        ],
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 54,
      child: isOutlined
          ? OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: useGlassmorphism ? Colors.white.withOpacity(0.5) : buttonColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          foregroundColor: useGlassmorphism ? Colors.white : buttonColor,
        ),
        child: buttonChild,
      )
          : ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: useGlassmorphism
              ? Colors.white.withOpacity(0.2)
              : buttonColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: useGlassmorphism ? 0 : 2,
          shadowColor: useGlassmorphism
              ? Colors.transparent
              : buttonColor.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: buttonChild,
      ),
    );
  }
}
