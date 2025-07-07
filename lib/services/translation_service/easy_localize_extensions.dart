// File: easy_localize_extensions.dart
import 'package:flutter/material.dart';
import 'easy_localize.dart';
import 'easy_localize_provider.dart';
import 'translation_args.dart';

extension EasyLocalizeExtension on BuildContext {
  EasyLocalize get easyLocalize => EasyLocalizeProvider.of(this).easyLocalize;

  String tr<T extends Map<String, dynamic>>(String key, {TranslationArgs<T>? args}) {
    return easyLocalize.translate(key, args: args?.args);
  }

  String plural<T extends Map<String, dynamic>>(String key, int count, {TranslationArgs<T>? args}) {
    return easyLocalize.translatePlural(key, count, args: args?.args);
  }

  String formatDate(DateTime date, {String? pattern, String? locale}) {
    return easyLocalize.formatDate(date, pattern: pattern, locale: locale);
  }

  String formatNumber(num number, {String? pattern, String? locale}) {
    return easyLocalize.formatNumber(number, pattern: pattern, locale: locale);
  }

  Locale get locale => easyLocalize.currentLocale;

  Future<void> setLocale(Locale locale) async {
    try {
      await easyLocalize.setLocale(locale);
    } catch (e) {
      // Optionally handle error, e.g., show a snackbar
    }
  }
}
