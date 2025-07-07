import 'package:flutter/material.dart';
import 'colorx.dart';

// TextStyle Extensions


extension TextStyleX on TextStyle {
  /// Creates a copy with modified properties
  TextStyle copyWithModified({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextDecoration? decoration,
  }) {
    return copyWith(
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      decoration: decoration ?? this.decoration,
    );
  }

  /// Increases font size by a factor
  TextStyle scaleFont(double factor) {
    return copyWith(fontSize: (fontSize ?? 14.0) * factor);
  }

  /// Makes the text bold
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Makes the text italic
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  /// Adds underline
  TextStyle get underlined => copyWith(decoration: TextDecoration.underline);

  /// Adjusts opacity of the text color
  TextStyle withOpacity(double opacity) {
    return copyWith(color: color?.withOpacityAdjusted(opacity));
  }

  /// Merges another TextStyle's non-null properties
  TextStyle mergeStyle(TextStyle other) {
    return copyWith(
      color: other.color ?? color,
      fontSize: other.fontSize ?? fontSize,
      fontWeight: other.fontWeight ?? fontWeight,
      fontStyle: other.fontStyle ?? fontStyle,
      letterSpacing: other.letterSpacing ?? letterSpacing,
      wordSpacing: other.wordSpacing ?? wordSpacing,
      decoration: other.decoration ?? decoration,
    );
  }
}