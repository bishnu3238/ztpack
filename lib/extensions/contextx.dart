
import 'package:flutter/material.dart';

/// BuildContext extensions
extension BuildContextX on BuildContext {
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  // Media query shortcuts
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => mediaQuery.size;

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  EdgeInsets get viewPadding => mediaQuery.viewPadding;

  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  EdgeInsets get padding => mediaQuery.padding;

  double get statusBarHeight => viewPadding.top;

  double get bottomInset => viewInsets.bottom;

  double get keyboardHeight => viewInsets.bottom;

  bool get isKeyboardVisible => viewInsets.bottom > 0;

  Brightness get brightness => mediaQuery.platformBrightness;

  bool get isDarkMode => brightness == Brightness.dark;

  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  // Responsive design helpers
  bool get isPhone => screenWidth < 600;

  bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  bool get isDesktop => screenWidth >= 900;

  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  // Navigation shortcuts
  NavigatorState get navigator => Navigator.of(this);

  void popX<T>([T? result]) => navigator.pop(result);

  Future<T?> pushX<T>(Widget Function(BuildContext) builder) =>
      navigator.push<T>(MaterialPageRoute(builder: builder));

  // Snackbar
  ScaffoldMessengerState get scaffoldMessengerX => ScaffoldMessenger.of(this);

  void showSnackBarX(String message,
      {Duration? duration, Color? backgroundColor}) {
    scaffoldMessengerX.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration ?? const Duration(seconds: 2),
          backgroundColor: backgroundColor,
        )
    );
  }

// Dialog utilities
  Future<T?> showCustomDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }

  // Advanced dialog utilities
  Future<bool> showConfirmDialog({
    String title = 'Confirm',
    required String message,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<String?> showInputDialog({
    String title = 'Enter Value',
    String? initialValue,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<String>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result;
  }

  // Modal bottom sheet
  Future<T?> showCustomBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: context.viewInsets.bottom),
        child: child,
      ),
    );
  }

  // Theme utilities
  bool get isLightMode => !isDarkMode;
  Color get primaryColor => theme.primaryColor;
  TextStyle? get headlineSmall => textTheme.headlineSmall;
  TextStyle? get headlineMedium => textTheme.headlineMedium;
  TextStyle? get headlineLarge => textTheme.headlineLarge;
  TextStyle? get bodySmall => textTheme.bodySmall;
  TextStyle? get bodyMedium => textTheme.bodyMedium;
  TextStyle? get bodyLarge => textTheme.bodyLarge;

  // Focus and keyboard utilities
  void hideKeyboard() => FocusScope.of(this).unfocus();
  void requestFocus([FocusNode? node]) {
    if (node != null) {
      FocusScope.of(this).requestFocus(node);
    } else {
      FocusScope.of(this).requestFocus(FocusNode());
    }
  }

  // Size utilities based on screen proportions
  double percentOfScreenWidth(double percent) => screenWidth * percent / 100;
  double percentOfScreenHeight(double percent) => screenHeight * percent / 100;
  double get safeAreaBottom => mediaQuery.padding.bottom;
  double get safeAreaTop => mediaQuery.padding.top;

  // Platform detection
  bool get isIOS => Theme.of(this).platform == TargetPlatform.iOS;
  bool get isAndroid => Theme.of(this).platform == TargetPlatform.android;
  bool get isMacOS => Theme.of(this).platform == TargetPlatform.macOS;
  bool get isWindows => Theme.of(this).platform == TargetPlatform.windows;
  bool get isLinux => Theme.of(this).platform == TargetPlatform.linux;
  bool get isMobile => isIOS || isAndroid;
  bool get isDesktopPlatform => isMacOS || isWindows || isLinux;

  // Form validation utilities
  void showFormFieldError(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
