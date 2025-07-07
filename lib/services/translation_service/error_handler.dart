import 'dart:developer' as dev;
import 'dart:ui';

import 'easy_localize.dart';

class ErrorHandler {
  static void handleTranslationError({
    required String key,
    required Locale locale,
    required String message,
    bool isDebug = true,
  }) {
    final errorMessage = 'TranslationError: $message for key "$key" in locale $locale';
    if (isDebug) {
      dev.log(errorMessage);
    }
    // Optionally log to analytics or crash reporting service
  }

  static void handleInitializationError({
    required String message,
    required Object error,
    bool isDebug = true,
  }) {
    final errorMessage = 'InitializationError: $message\nError: $error';
    if (isDebug) {
      dev.log(errorMessage);
    }
    throw EasyLocalizeException(errorMessage);
  }
}