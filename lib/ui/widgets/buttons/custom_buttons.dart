import 'package:flutter/material.dart';

/// Enum to define different button types
enum CustomButtonType {
  primary,
  secondary,
  success,
  danger,
  warning,
  info,
  light,
  dark,
  outline,
  gradient
}

/// Enum to define button sizes
enum CustomButtonSize {
  small,
  medium,
  large,
  extraLarge
}

/// Custom Button Widget with comprehensive features
class CustomButton extends StatelessWidget {
  /// The text to display on the button
  final String text;

  /// The type of button (primary, secondary, etc.)
  final CustomButtonType type;

  /// Size of the button
  final CustomButtonSize size;

  /// Callback when the button is pressed
  final VoidCallback? onPressed;

  /// Icon to display before the text
  final IconData? prefixIcon;

  /// Icon to display after the text
  final IconData? suffixIcon;

  /// Custom text style for the button
  final TextStyle? textStyle;

  /// Whether the button is disabled
  final bool isDisabled;

  /// Loading state of the button
  final bool isLoading;

  /// Custom width of the button
  final double? width;

  /// Custom height of the button
  final double? height;

  /// Border radius of the button
  final double borderRadius;

  /// Elevation of the button
  final double elevation;

  /// Gradient for gradient type buttons
  final Gradient? gradient;

  const CustomButton({
    super.key,
    required this.text,
    this.type = CustomButtonType.primary,
    this.size = CustomButtonSize.medium,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.textStyle,
    this.isDisabled = false,
    this.isLoading = false,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.elevation = 2.0,
    this.gradient,
  });

  /// Get button color based on type
  Color _getButtonColor(BuildContext context) {
    switch (type) {
      case CustomButtonType.primary:
        return Theme.of(context).primaryColor;
      case CustomButtonType.secondary:
        return Colors.grey;
      case CustomButtonType.success:
        return Colors.green;
      case CustomButtonType.danger:
        return Colors.red;
      case CustomButtonType.warning:
        return Colors.orange;
      case CustomButtonType.info:
        return Colors.blue;
      case CustomButtonType.light:
        return Colors.white;
      case CustomButtonType.dark:
        return Colors.black;
      case CustomButtonType.outline:
        return Colors.transparent;
      case CustomButtonType.gradient:
        return Colors.transparent;
    }
  }

  /// Get text color based on button type
  Color _getTextColor(BuildContext context) {
    switch (type) {
      case CustomButtonType.light:
        return Colors.black;
      case CustomButtonType.outline:
        return _getButtonColor(context);
      default:
        return Colors.white;
    }
  }

  /// Get button size
  double _getButtonHeight() {
    switch (size) {
      case CustomButtonSize.small:
        return 40.0;
      case CustomButtonSize.medium:
        return 50.0;
      case CustomButtonSize.large:
        return 60.0;
      case CustomButtonSize.extraLarge:
        return 70.0;
    }
  }

  /// Get button text style
  TextStyle _getTextStyle(BuildContext context) {
    final baseStyle = textStyle ?? Theme.of(context).textTheme.labelLarge;
    return baseStyle!.copyWith(
      color: isDisabled ? Colors.grey : _getTextColor(context),
      fontSize: _getButtonHeight() * 0.3,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine button decoration
    Decoration decoration;
    if (type == CustomButtonType.gradient && gradient != null) {
      decoration = BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      );
    } else if (type == CustomButtonType.outline) {
      decoration = BoxDecoration(
        border: Border.all(color: _getButtonColor(context), width: 2),
        borderRadius: BorderRadius.circular(borderRadius),
      );
    } else {
      decoration = BoxDecoration(
        color: isDisabled ? Colors.grey.shade300 : _getButtonColor(context),
        borderRadius: BorderRadius.circular(borderRadius),
      );
    }

    // Button content
    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Prefix Icon
        if (prefixIcon != null && !isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(
              prefixIcon,
              color: _getTextColor(context),
              size: _getButtonHeight() * 0.4,
            ),
          ),

        // Loading Indicator or Text
        isLoading
            ? SizedBox(
          width: _getButtonHeight() * 0.5,
          height: _getButtonHeight() * 0.5,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_getTextColor(context)),
          ),
        )
            : Text(
          text,
          style: _getTextStyle(context),
          overflow: TextOverflow.ellipsis,
        ),

        // Suffix Icon
        if (suffixIcon != null && !isLoading)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              suffixIcon,
              color: _getTextColor(context),
              size: _getButtonHeight() * 0.4,
            ),
          ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: isDisabled || isLoading ? null : onPressed,
        child: Ink(
          width: width,
          height: _getButtonHeight(),
          decoration: decoration,
          child: Center(child: content),
        ),
      ),
    );
  }

  /// Predefined button constructors
  const factory CustomButton.primary({
    required String text,
    VoidCallback? onPressed,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) = _PrimaryCustomButton;

  const factory CustomButton.secondary({
    required String text,
    VoidCallback? onPressed,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) = _SecondaryCustomButton;

  const factory CustomButton.success({
    required String text,
    VoidCallback? onPressed,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) = _SuccessCustomButton;

  const factory CustomButton.danger({
    required String text,
    VoidCallback? onPressed,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) = _DangerCustomButton;

  const factory CustomButton.gradient({
    required String text,
    required Gradient gradient,
    VoidCallback? onPressed,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) = _GradientCustomButton;
}

// Specific button type implementations
class _PrimaryCustomButton extends CustomButton {
  const _PrimaryCustomButton({
    required super.text,
    super.onPressed,
    super.prefixIcon,
    super.suffixIcon,
  }) : super(
    type: CustomButtonType.primary,
  );
}

class _SecondaryCustomButton extends CustomButton {
  const _SecondaryCustomButton({
    required super.text,
    super.onPressed,
    super.prefixIcon,
    super.suffixIcon,
  }) : super(
    type: CustomButtonType.secondary,
  );
}

class _SuccessCustomButton extends CustomButton {
  const _SuccessCustomButton({
    required super.text,
    super.onPressed,
    super.prefixIcon,
    super.suffixIcon,
  }) : super(
    type: CustomButtonType.success,
  );
}

class _DangerCustomButton extends CustomButton {
  const _DangerCustomButton({
    required super.text,
    super.onPressed,
    super.prefixIcon,
    super.suffixIcon,
  }) : super(
    type: CustomButtonType.danger,
  );
}

class _GradientCustomButton extends CustomButton {
  const _GradientCustomButton({
    required super.text,
    required Gradient super.gradient,
    super.onPressed,
    super.prefixIcon,
    super.suffixIcon,
  }) : super(
    type: CustomButtonType.gradient,
  );
}