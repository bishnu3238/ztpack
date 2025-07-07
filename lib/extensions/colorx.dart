import 'dart:ui';

import 'package:flutter/material.dart';

/// Color extensions
extension ColorX on Color {
  // Color manipulation
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Adjusts the saturation of the color
  Color saturate([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(this);
    return hsl.withSaturation((hsl.saturation + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Reduces the saturation of the color
  Color desaturate([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(this);
    return hsl.withSaturation((hsl.saturation - amount).clamp(0.0, 1.0)).toColor();
  }

  /// Adjusts the opacity of the color
  Color withOpacityAdjusted(double opacity) {
    assert(opacity >= 0 && opacity <= 1, 'Opacity must be between 0 and 1');
    return withValues(alpha: opacity);
  }

  /// Converts the color to a hex string (e.g., #FF0000)
  String toHex({bool includeAlpha = false}) {
    final r = this.r.toInt().toRadixString(16).padLeft(2, '0');
    final g = this.g.toInt().toRadixString(16).padLeft(2, '0');
    final b = this.b.toInt().toRadixString(16).padLeft(2, '0');
    final a = includeAlpha ? this.a.toInt().toRadixString(16).padLeft(2, '0') : '';
    return '#$a$r$g$b'.toUpperCase();
  }

  /// Creates a color from a hex string
  static Color fromHex(String hex) {
    final hexCleaned = hex.replaceFirst('#', '').replaceAll(' ', '');
    final length = hexCleaned.length;
    int value;

    if (length == 3 || length == 4) {
      // Handle short hex like #FFF or #FFFF
      final chars = length == 3 ? hexCleaned.split('') : hexCleaned.split('');
      final r = chars[0] + chars[0];
      final g = chars[1] + chars[1];
      final b = chars[2] + chars[2];
      final a = length == 4 ? chars[3] + chars[3] : 'FF';
      value = int.parse('0x$a$r$g$b');
    } else if (length == 6 || length == 8) {
      // Handle full hex like #FF0000 or #FF0000FF
      value = int.parse('0x${length == 6 ? 'FF' : ''}$hexCleaned');
    } else {
      return Colors.transparent;
    }

    return Color(value);
  }

  /// Generates a complementary color (180 degrees opposite on the color wheel)
  Color get complementary {
    final hsl = HSLColor.fromColor(this);
    final complementaryHue = (hsl.hue + 180) % 360;
    return hsl.withHue(complementaryHue).toColor();
  }

  /// Generates analogous colors (30 degrees apart on either side)
  List<Color> get analogous {
    final hsl = HSLColor.fromColor(this);
    final hue1 = (hsl.hue + 30) % 360;
    final hue2 = (hsl.hue - 30) % 360;
    return [
      hsl.withHue(hue1).toColor(),
      hsl.withHue(hue2).toColor(),
    ];
  }

  /// Generates a list of shades (darker variations)
  List<Color> shades([int count = 5, double step = 0.1]) {
    return List.generate(count, (index) => darken(step * (index + 1)));
  }

  /// Generates a list of tints (lighter variations)
  List<Color> tints([int count = 5, double step = 0.1]) {
    return List.generate(count, (index) => lighten(step * (index + 1)));
  }

  /// Checks if the color is considered dark (for text contrast)
  bool get isDark {
    // Using luminance formula for contrast detection
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    return luminance < 0.5;
  }

  /// Returns a contrasting color (black or white) for readability
  Color get contrastText => isDark ? Colors.white : Colors.black;
}