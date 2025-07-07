import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// String conversion and manipulation utilities
extension StringX on String {
  qLog() {
    dev.log('QUESTION: ${toString()}');
  }

  // Conversion to basic types
  int get toInt =>
      isEmpty ? 0 : int.tryParse(replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
  double get toDouble =>
      isEmpty
          ? 0.0
          : double.tryParse(replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0.0;
  bool get toBool {
    final value = trim().toLowerCase();
    return ['true', 't', 'yes', 'y', '1'].contains(value);
  }

  // Date/Time conversions with multiple formats
  DateTime? toDateTime({DateTime? defaultValue}) {
    if (isEmpty) return defaultValue;

    // Try standard format
    try {
      return DateTime.parse(this);
    } catch (_) {
      // Continue with other formats
    }

    // Try common formats
    final formats = [
      'yyyy-MM-dd',
      'yyyy-MM-dd HH:mm',
      'yyyy-MM-dd HH:mm:ss',
      'dd-MM-yyyy',
      'MM-dd-yyyy',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'dd MMM yyyy',
      'MMM dd, yyyy',
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parse(trim());
      } catch (_) {
        // Try next format
      }
    }

    // Handle two-digit years (MM/dd/yy)
    final twoDigitYearRegex = RegExp(r'^(\d{1,2})[/.-](\d{1,2})[/.-](\d{2})$');
    final match = twoDigitYearRegex.firstMatch(trim());
    if (match != null) {
      try {
        final month = int.parse(match.group(1)!);
        final day = int.parse(match.group(2)!);
        int year = int.parse(match.group(3)!);
        year += (year < 50) ? 2000 : 1900;
        return DateTime(year, month, day);
      } catch (_) {
        // Continue
      }
    }

    return defaultValue;
  }

  // Time conversion
  TimeOfDay? get toTime {
    if (isEmpty) return null;

    // Handle formats like "14:30", "2:30 PM"
    final timeRegex = RegExp(
      r'^(\d{1,2}):(\d{2})(?:\s*(AM|PM))?$',
      caseSensitive: false,
    );
    final match = timeRegex.firstMatch(trim());
    if (match != null) {
      try {
        int hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        final ampm = match.group(3)?.toUpperCase();

        if (ampm == 'PM' && hour < 12) hour += 12;
        if (ampm == 'AM' && hour == 12) hour = 0;

        return TimeOfDay(hour: hour, minute: minute);
      } catch (_) {
        return null;
      }
    }

    // Try datetime parsing as fallback
    try {
      final dateTime = DateTime.parse(this);
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } catch (_) {
      return null;
    }
  }

  // String transformations
  String get capitalized =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
  String get titleCase => split(' ').map((word) => word.capitalized).join(' ');
  String get camelCase {
    final words = trim().split(RegExp(r'[_\s-]+'));
    return words.first.toLowerCase() +
        words.skip(1).map((w) => w.capitalized).join('');
  }

  String get pascalCase {
    final words = trim().split(RegExp(r'[_\s-]+'));
    return words.map((w) => w.capitalized).join('');
  }

  String get snakeCase {
    final result = replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    return result.startsWith('_') ? result.substring(1) : result;
  }

  String get kebabCase => snakeCase.replaceAll('_', '-');

  // Validation
  bool get isEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(this);
  bool get isUrl => RegExp(
    r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,})([\/\w \.-]*)*\/?$',
  ).hasMatch(this);
  bool get isPhoneNumber => RegExp(r'^\+?[\d\s-]{8,}$').hasMatch(this);
  bool get isNumeric => RegExp(r'^\d+$').hasMatch(this);
  bool get isAlpha => RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  bool get isAlphanumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);

  // Truncation and formatting
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  String ellipsis(int maxLength) => truncate(maxLength);

  // Security/Privacy
  String get md5 =>
      utf8.encode(this).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  String maskEmail() {
    final parts = split('@');
    if (parts.length != 2) return this;
    final name = parts[0];
    final domain = parts[1];
    return '${name.length > 2 ? name.substring(0, 2) : name}${'*' * (name.length > 2 ? name.length - 2 : 0)}@$domain';
  }

  String maskPhone() {
    if (length < 4) return this;
    return replaceRange(0, length - 4, '*' * (length - 4));
  }

  // File path handling
  String get fileName {
    final parts = split(RegExp(r'[/\\]'));
    return parts.isNotEmpty ? parts.last : '';
  }

  String get fileExtension {
    final name = fileName;
    final lastDot = name.lastIndexOf('.');
    return lastDot != -1 ? name.substring(lastDot + 1) : '';
  }

  String get fileNameWithoutExtension {
    final name = fileName;
    final lastDot = name.lastIndexOf('.');
    return lastDot != -1 ? name.substring(0, lastDot) : name;
  }
}
