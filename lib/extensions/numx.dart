
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Number extensions for UI and time operations
extension NumX on num {
  // UI related
  BorderRadius get circular => BorderRadius.circular(toDouble());
  BorderRadius get circularTop => BorderRadius.vertical(top: Radius.circular(toDouble()));
  BorderRadius get circularBottom => BorderRadius.vertical(bottom: Radius.circular(toDouble()));
  BorderRadius get circularLeft => BorderRadius.horizontal(left: Radius.circular(toDouble()));
  BorderRadius get circularRight => BorderRadius.horizontal(right: Radius.circular(toDouble()));

  // Padding shortcuts
  EdgeInsets get all => EdgeInsets.all(toDouble());
  EdgeInsets get horizontal => EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsets get vertical => EdgeInsets.symmetric(vertical: toDouble());
  EdgeInsets get top => EdgeInsets.only(top: toDouble());
  EdgeInsets get bottom => EdgeInsets.only(bottom: toDouble());
  EdgeInsets get left => EdgeInsets.only(left: toDouble());
  EdgeInsets get right => EdgeInsets.only(right: toDouble());

  // Custom padding (horizontal/vertical)
  EdgeInsets symmetricHV(num vertical) => EdgeInsets.symmetric(
      horizontal: toDouble(),
      vertical: vertical.toDouble()
  );

  EdgeInsets symmetricVH(num horizontal) => EdgeInsets.symmetric(
      horizontal: horizontal.toDouble(),
      vertical: toDouble()
  );

  // Time durations
  Duration get milliseconds => Duration(milliseconds: toInt());
  Duration get seconds => Duration(seconds: toInt());
  Duration get minutes => Duration(minutes: toInt());
  Duration get hours => Duration(hours: toInt());
  Duration get days => Duration(days: toInt());

  // Number formatting
  String get formatted => NumberFormat('#,###').format(this);
  String get currency => NumberFormat.currency(symbol: '\$').format(this);
  String get percent => NumberFormat.percentPattern().format(this);
  String decimals(int places) => NumberFormat('#,##0.${'0' * places}').format(this);

  // Math utilities
  num clamp(num min, num max) => math.min(math.max(this, min), max);
  bool isBetween(num min, num max) => this >= min && this <= max;
}