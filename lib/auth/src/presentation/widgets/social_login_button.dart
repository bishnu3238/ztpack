// src/presentation/widgets/social_login_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum SocialLoginProvider {
  google,
  facebook,
  twitter,
  apple,
  github,
}

class SocialLoginButton extends StatefulWidget {
  final SocialLoginProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool useGlassmorphism;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
    this.useGlassmorphism = false,
  });

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String text;
    IconData icon;
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (widget.provider) {
      case SocialLoginProvider.google:
        text = 'Continue with Google';
        icon = Icons.g_mobiledata_rounded;
        backgroundColor = widget.useGlassmorphism ? Colors.transparent : Colors.white;
        textColor = widget.useGlassmorphism ? Colors.white : Colors.black87;
        borderColor = widget.useGlassmorphism ? Colors.white.withOpacity(0.2) : Colors.grey.shade300;
        break;
      case SocialLoginProvider.facebook:
        text = 'Continue with Facebook';
        icon = Icons.facebook;
        backgroundColor = widget.useGlassmorphism
            ? Colors.transparent
            : const Color(0xFF1877F2);
        textColor = Colors.white;
        borderColor = widget.useGlassmorphism
            ? Colors.white.withOpacity(0.2)
            : const Color(0xFF1877F2);
        break;
      case SocialLoginProvider.twitter:
        text = 'Continue with Twitter';
        icon = Icons.chat_bubble_outline;
        backgroundColor = widget.useGlassmorphism
            ? Colors.transparent
            : const Color(0xFF1DA1F2);
        textColor = Colors.white;
        borderColor = widget.useGlassmorphism
            ? Colors.white.withOpacity(0.2)
            : const Color(0xFF1DA1F2);
        break;
      case SocialLoginProvider.apple:
        text = 'Continue with Apple';
        icon = Icons.apple;
        backgroundColor = widget.useGlassmorphism
            ? Colors.transparent
            : Colors.black;
        textColor = Colors.white;
        borderColor = widget.useGlassmorphism
            ? Colors.white.withOpacity(0.2)
            : Colors.black;
        break;
      case SocialLoginProvider.github:
        text = 'Continue with GitHub';
        icon = Icons.code;
        backgroundColor = widget.useGlassmorphism
            ? Colors.transparent
            : const Color(0xFF333333);
        textColor = Colors.white;
        borderColor = widget.useGlassmorphism
            ? Colors.white.withOpacity(0.2)
            : const Color(0xFF333333);
        break;
    }

    final Widget buttonChild = widget.isLoading
        ? SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(textColor),
      ),
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: textColor, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
              boxShadow: _isHovered && !widget.useGlassmorphism
                  ? [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onPressed();
                },
                borderRadius: BorderRadius.circular(16),
                splashColor: textColor.withOpacity(0.1),
                highlightColor: textColor.withOpacity(0.05),
                child: Center(child: buttonChild),
              ),
            ),
          ),
        ),
      ),
    );
  }
}