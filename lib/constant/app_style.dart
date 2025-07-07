import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  // Private constructor to prevent instantiation
  AppStyles._();

  // Color Palette
  static const Color primaryColor = Color(0xFF3366FF);
  static const Color secondaryColor = Color(0xFF5E5E5E);
  static const Color accentColor = Color(0xFFFF6B6B);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF333333);
  static const Color errorColor = Color(0xFFFF4D4D);
  static const Color successColor = Color(0xFF4CAF50);

  // Text Styles
  static TextStyle get titleLarge => GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: 0.5,
  );

  static TextStyle get titleMedium => GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: 0.4,
  );

  static TextStyle get titleSmall => GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textColor,
    letterSpacing: 0.3,
  );

  static TextStyle get bodyLarge => GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textColor,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.openSans(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textColor,
    height: 1.4,
  );

  static TextStyle get bodySmall => GoogleFonts.openSans(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textColor.withOpacity(0.7),
    height: 1.3,
  );

  static TextStyle get labelLarge => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static TextStyle get labelMedium => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textColor,
    letterSpacing: 0.4,
  );

  static TextStyle get labelSmall => GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textColor.withOpacity(0.8),
    letterSpacing: 0.3,
  );

  // Error Text Style
  static TextStyle get errorTextStyle => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: errorColor,
  );

  // Button Text Styles
  static TextStyle get buttonTextLarge => GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static TextStyle get buttonTextSmall => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: 0.4,
  );

  // Input Decoration Styles
  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isError = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      labelStyle: labelMedium.copyWith(
        color: isError ? errorColor : textColor.withOpacity(0.7),
      ),
      hintStyle: bodyMedium.copyWith(
        color: textColor.withOpacity(0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: textColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: errorColor,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: errorColor,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      errorStyle: errorTextStyle,
    );
  }

  // Box Decorations
  static BoxDecoration get primaryBoxDecoration => BoxDecoration(
    color: primaryColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get secondaryBoxDecoration => BoxDecoration(
    color: secondaryColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: secondaryColor.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        color: primaryColor,
        elevation: 0,
        titleTextStyle: titleMedium.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: TextTheme(
        displayLarge: titleLarge,
        displayMedium: titleMedium,
        displaySmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: buttonTextLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: textColor.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: textColor.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: errorColor,
          ),
        ),
      ),
    );
  }

  // Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  // Border Radius
  static BorderRadius get smallRadius => BorderRadius.circular(8);
  static BorderRadius get mediumRadius => BorderRadius.circular(12);
  static BorderRadius get largeRadius => BorderRadius.circular(16);

  // Padding
  static EdgeInsets get smallPadding => const EdgeInsets.all(sm);
  static EdgeInsets get mediumPadding => const EdgeInsets.all(md);
  static EdgeInsets get largePadding => const EdgeInsets.all(lg);

  // Shadow
  static BoxShadow get lightShadow => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );

  static BoxShadow get mediumShadow => BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 15,
    offset: const Offset(0, 5),
  );
}