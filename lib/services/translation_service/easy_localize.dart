// File: easy_localize.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

export 'easy_localize_builder.dart';
export 'easy_localize_app.dart';
export 'easy_localize_extensions.dart';
export 'language_selector.dart';
 import 'error_handler.dart';
class EasyLocalizeException implements Exception {
  final String message;
  EasyLocalizeException(this.message);
  @override
  String toString() => 'EasyLocalizeException: $message';
}

class EasyLocalize {
  // Singleton instance
  static final EasyLocalize _instance = EasyLocalize._internal();
  factory EasyLocalize() => _instance;
  EasyLocalize._internal();

  // Private fields
  late Locale _currentLocale;
  late List<Locale> _supportedLocales;
  late Map<String, Map<String, dynamic>> _localizedValues = {};
  StreamController<Locale>? _localeController;
  final String _prefsKey = 'selected_locale';
  late Locale _fallbackLocale;

  // Getters
  Locale get currentLocale => _currentLocale;
  Stream<Locale> get localeStream => _localeController!.stream;

  // Initialize the localization service
  Future<void> initialize({
    required Locale defaultLocale,
    required List<Locale> supportedLocales,
    required String path,
    Locale? fallbackLocale,
    void Function(Object error)? onError, // Add error callback
  }) async {
    // Prevent multiple StreamControllers
    _localeController?.close();
    _localeController = StreamController<Locale>.broadcast();
    _supportedLocales = supportedLocales;

    // Load saved locale or use default
    final prefs = await SharedPreferences.getInstance();
    final savedLocaleString = prefs.getString(_prefsKey);

    if (savedLocaleString != null) {
      final parts = savedLocaleString.split('_');
      if (parts.length == 2) {
        _currentLocale = Locale(parts[0], parts[1]);
      } else {
        _currentLocale = Locale(parts[0], '');
      }
    } else {
      _currentLocale = defaultLocale;
    }

    // Ensure the saved locale is supported (compare full locale)
    bool isSupported = _supportedLocales.any((locale) =>
      locale.languageCode == _currentLocale.languageCode &&
      (locale.countryCode ?? '') == (_currentLocale.countryCode ?? '')
    );

    if (!isSupported) {
      _currentLocale = defaultLocale;
    }

    _fallbackLocale = fallbackLocale ?? defaultLocale;

    // Load all translations
    await _loadAllTranslations(path, onError: onError);

    // Notify listeners
    _localeController!.add(_currentLocale);
  }

  // Load translations for all supported locales
  Future<void> _loadAllTranslations(String path, {void Function(Object error)? onError}) async {
    for (var locale in _supportedLocales) {
      final langCode = locale.languageCode;
      final countryCode = locale.countryCode;
      final localeKey = countryCode == null || countryCode.isEmpty
          ? langCode
          : '${langCode}_$countryCode';
      String filePath = countryCode == null || countryCode.isEmpty
          ? '$path/$langCode.json'
          : '$path/${langCode}_$countryCode.json';

      try {
        final jsonString = await rootBundle.loadString(filePath);
        final Map<String, dynamic> values = json.decode(jsonString);
        _localizedValues[localeKey] = values;
      } catch (e) {
        ErrorHandler.handleInitializationError(
          message: 'Failed to load translations for $localeKey at $filePath',
          error: e,
        );
      }
    }
  }
  // Async load a translation file for a locale if not already loaded
  Future<void> loadTranslationForLocale(Locale locale, String path, {void Function(Object error)? onError}) async {
    final langCode = locale.languageCode;
    final countryCode = locale.countryCode;
    final localeKey = countryCode == null || countryCode.isEmpty
        ? langCode
        : '${langCode}_$countryCode';
    if (_localizedValues.containsKey(localeKey)) return;
    String filePath = countryCode == null || countryCode.isEmpty
        ? '$path/$langCode.json'
        : '$path/${langCode}_$countryCode.json';
    try {
      final jsonString = await rootBundle.loadString(filePath);
      final Map<String, dynamic> values = json.decode(jsonString);
      _localizedValues[localeKey] = values;
    } catch (e) {
      if (onError != null) {
        onError(e);
      } else {
        throw EasyLocalizeException('Error loading language file: $filePath');
      }
    }
  }

  // Change the current locale
  Future<void> setLocale(Locale locale) async {
    // Check if locale is supported (compare full locale)
    bool isSupported = _supportedLocales.any((supportedLocale) =>
      supportedLocale.languageCode == locale.languageCode &&
      (supportedLocale.countryCode ?? '') == (locale.countryCode ?? '')
    );

    if (!isSupported) {
      throw Exception('Locale $locale is not supported');
    }

    _currentLocale = locale;

    // Save selected locale
    final prefs = await SharedPreferences.getInstance();
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      await prefs.setString(_prefsKey, '${locale.languageCode}_${locale.countryCode}');
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }

    // Notify listeners
    _localeController!.add(locale);
  }

  // Get a translated string
  String translate(String key, {Map<String, dynamic>? args}) {
    String? value = _getTranslationForKey(key, _currentLocale, args: args);
    if (value == null) {
      value = _getTranslationForKey(key, _fallbackLocale, args: args);
      if (value == null) {
        ErrorHandler.handleTranslationError(
          key: key,
          locale: _currentLocale,
          message: 'Translation not found',
        );
        return key;
      }
    }
    return value;
  }  String? _getTranslationForKey(String key, Locale locale, {Map<String, dynamic>? args}) {
    final localeKey = locale.countryCode == null || locale.countryCode!.isEmpty
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    if (!_localizedValues.containsKey(localeKey)) return null;
    final translations = _localizedValues[localeKey]!;

    // Handle nested keys
    dynamic value = _resolveNestedKey(key, translations);
    if (value == null) return null;

    String stringValue = value.toString();
    if (args != null && args.isNotEmpty) {
      args.forEach((argKey, argValue) {
        stringValue = stringValue.replaceAll('{$argKey}', argValue.toString());
      });
    }
    return stringValue;
  }

  dynamic _resolveNestedKey(String key, Map<String, dynamic> translations) {
    final keys = key.split('.');
    dynamic current = translations;
    for (var k in keys) {
      if (current is Map<String, dynamic> && current.containsKey(k)) {
        current = current[k];
      } else {
        return null;
      }
    }
    return current;
  }
  // Translate with plurals
  String translatePlural(String key, int count, {Map<String, dynamic>? args}) {
    String? value = _getPluralTranslation(key, count, _currentLocale, args: args);
    if (value == null) {
      value = _getPluralTranslation(key, count, _fallbackLocale, args: args);
      if (value == null) return key;
    }
    return value;
  }

  String? _getPluralTranslation(String key, int count, Locale locale, {Map<String, dynamic>? args}) {
    final localeKey = locale.countryCode == null || locale.countryCode!.isEmpty
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    if (!_localizedValues.containsKey(localeKey)) return null;
    final translations = _localizedValues[localeKey]!;
    if (!translations.containsKey(key)) return null;
    final Map<String, dynamic> pluralForms = translations[key];
    String? pluralKey;
    if (count == 0 && pluralForms.containsKey('zero')) {
      pluralKey = 'zero';
    } else if (count == 1 && pluralForms.containsKey('one')) {
      pluralKey = 'one';
    } else if (count == 2 && pluralForms.containsKey('two')) {
      pluralKey = 'two';
    } else if (pluralForms.containsKey('other')) {
      pluralKey = 'other';
    } else {
      pluralKey = pluralForms.keys.first;
    }
    if (!pluralForms.containsKey(pluralKey)) return null;
    String value = pluralForms[pluralKey].toString();
    Map<String, dynamic> allArgs = args ?? {};
    allArgs['count'] = count;
    allArgs.forEach((argKey, argValue) {
      value = value.replaceAll('{$argKey}', argValue.toString());
    });
    return value;
  }

  // Advanced: Format date/number using intl
  String formatDate(DateTime date, {String? pattern, String? locale}) {
    final loc = locale ?? _currentLocale.toString();
    return DateFormat(pattern, loc).format(date);
  }

  String formatNumber(num number, {String? pattern, String? locale}) {
    final loc = locale ?? _currentLocale.toString();
    final format = NumberFormat(pattern, loc);
    return format.format(number);
  }

  // Advanced: Reload all translations
  Future<void> reload({void Function(Object error)? onError}) async {
    _localizedValues.clear();
    await _loadAllTranslations('assets/translations', onError: onError);
    _localeController?.add(_currentLocale);
  }

  // Advanced: Add a new locale at runtime
  Future<void> addLocale(Locale locale, String path, {void Function(Object error)? onError}) async {
    if (_supportedLocales.contains(locale)) return;
    _supportedLocales.add(locale);
    await loadTranslationForLocale(locale, path, onError: onError);
    _localeController?.add(_currentLocale);
  }

  // Advanced: Check if translation exists
  bool hasTranslation(String key, {Locale? locale}) {
    final loc = locale ?? _currentLocale;
    final localeKey = loc.countryCode == null || loc.countryCode!.isEmpty
        ? loc.languageCode
        : '${loc.languageCode}_${loc.countryCode}';
    return _localizedValues[localeKey]?.containsKey(key) ?? false;
  }

  // Clean up resources
  void dispose() {
    _localeController?.close();
  }
}

// File: pubspec.yaml additions
/*
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  shared_preferences: ^2.2.0
  intl: ^0.17.0

flutter:
  assets:
    - assets/translations/
*/