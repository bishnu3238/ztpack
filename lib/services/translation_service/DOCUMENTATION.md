Below is the completed `README.md` file for the `EasyLocalize` Flutter package, tailored to provide a comprehensive guide for developers, especially Flutter developers working with localization in apps that may integrate with APIs (Node.js, PHP) and databases (MySQL). The content is structured formally, with clear, well-structured sentences and precise language, aligning with your preference for a professional tone to guide junior developers toward expertise. The `README.md` incorporates the provided sections, expands on them, and includes additional details for advanced usage, error handling, testing, and integration with GoRouter, as discussed in prior conversations.

---

# EasyLocalize Flutter Package

A robust, extensible, and easy-to-use localization package for Flutter applications.  
Supports asynchronous translation loading, fallback locales, pluralization, context-based formatting, and multiple language selector UIs, making it ideal for apps requiring dynamic multilingual support.

---

## Table of Contents

- [Why Use EasyLocalize?](#why-use-easylocalize)
- [When & Where to Use](#when--where-to-use)
- [Getting Started (Basic Implementation)](#getting-started-basic-implementation)
  - [1. Add Dependencies](#1-add-dependencies)
  - [2. Prepare Translation Files](#2-prepare-translation-files)
  - [3. Wrap Your App](#3-wrap-your-app)
  - [4. Use Translations in Widgets](#4-use-translations-in-widgets)
- [Language Selector Widgets](#language-selector-widgets)
- [Advanced Usage](#advanced-usage)
  - [Fallback Locale](#fallback-locale)
  - [Async Translation Loading](#async-translation-loading)
  - [Formatting Dates and Numbers](#formatting-dates-and-numbers)
  - [Dynamic Locale Addition](#dynamic-locale-addition)
  - [Translation Existence Check](#translation-existence-check)
  - [Reloading Translations](#reloading-translations)
  - [GoRouter Integration](#gorouter-integration)
- [Error Handling](#error-handling)
- [Testing](#testing)
- [API Reference](#api-reference)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

---

## Why Use EasyLocalize?

- **Simple API**: Intuitive methods like `context.tr()`, `context.plural()`, and `context.formatDate()` simplify localization tasks.
- **Async & Dynamic**: Supports asynchronous loading of translations and runtime addition of new locales.
- **Fallback Support**: Gracefully handles missing translations by falling back to a default locale, ensuring a seamless user experience.
- **Pluralization**: Implements CLDR plural rules for accurate plural forms across languages.
- **Formatting**: Built-in support for date and number formatting using the `intl` package.
- **UI Widgets**: Includes prebuilt `LanguageSelector` widgets for customizable language-switching interfaces.
- **Testable**: Designed with unit and widget testing in mind, ensuring reliability and maintainability.
- **GoRouter Compatibility**: Seamlessly integrates with `go_router` for locale-aware routing.

---

## When & Where to Use

- **When**: Use `EasyLocalize` in Flutter applications requiring multilingual support, dynamic locale switching, or advanced localization features such as pluralization and formatting.
- **Where**: Ideal as the primary localization solution for your app or as an enhancement to existing localization logic. Suitable for apps with backend APIs (e.g., Node.js, PHP) and databases (e.g., MySQL) for fetching dynamic translations.

---

## Getting Started (Basic Implementation)

### 1. Add Dependencies

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  shared_preferences: ^2.2.0
  intl: ^0.19.0
  go_router: ^14.2.0 # Optional, for GoRouter integration

flutter:
  assets:
    - assets/translations/
```

Run `flutter pub get` to install the dependencies.

### 2. Prepare Translation Files

Create JSON files for each supported locale in the `assets/translations/` directory. For example:

**`assets/translations/en_US.json`**:
```json
{
  "home": {
    "title": "Home",
    "welcome": "Welcome to {appName}"
  },
  "settings": {
    "title": "Settings"
  },
  "items": {
    "zero": "No items",
    "one": "One item",
    "other": "{count} items"
  },
  "routes": {
    "home": "home",
    "settings": "settings"
  }
}
```

**`assets/translations/es_ES.json`**:
```json
{
  "home": {
    "title": "Inicio",
    "welcome": "Bienvenido a {appName}"
  },
  "settings": {
    "title": "Ajustes"
  },
  "items": {
    "zero": "Sin elementos",
    "one": "Un elemento",
    "other": "{count} elementos"
  },
  "routes": {
    "home": "inicio",
    "settings": "ajustes"
  }
}
```

Ensure the `assets/translations/` directory is declared in `pubspec.yaml`.

### 3. Wrap Your App

Wrap your app with `EasyLocalizeApp` to initialize localization. If using GoRouter, provide a `GoRouter` instance.

**`main.dart`**:
```dart
import 'package:flutter/material.dart';
import 'package:my_ad_india/utils/translation_service/easy_localize.dart';
import 'package:my_ad_india/utils/translation_service/router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final easyLocalize = EasyLocalize();
    return EasyLocalizeApp(
      defaultLocale: Locale('en', 'US'),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
      translationsPath: 'assets/translations',
      router: createRouter(context, easyLocalize), // GoRouter integration
      child: Container(), // Placeholder, unused with router
      lightTheme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
    );
  }
}
```

### 4. Use Translations in Widgets

Use the `BuildContext` extension methods to access translations.

**Example Widget**:
```dart
import 'package:flutter/material.dart';
import 'package:my_ad_india/utils/translation_service/easy_localize_extensions.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('home.title')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(context.tr('home.welcome', args: TranslationArgs({'appName': 'MyApp'}))),
            Text(context.plural('items', 3)), // "3 items" in English
            Text(context.formatDate(DateTime.now(), pattern: 'yyyy-MM-dd')),
          ],
        ),
      ),
    );
  }
}
```

---

## Language Selector Widgets

The `LanguageSelector` widget provides a customizable UI for switching locales.

**Example Usage**:
```dart
import 'package:flutter/material.dart';
import 'package:my_ad_india/utils/translation_service/easy_localize_extensions.dart';
import 'package:my_ad_india/utils/translation_service/language_selector.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings.title'))),
      body: LanguageSelector(
        languageNames: {
          Locale('en', 'US'): 'English',
          Locale('es', 'ES'): 'Spanish',
        },
        showCountryFlags: true,
        onLocaleSelected: (locale) {
          // Navigate with GoRouter
          final currentPath = GoRouter.of(context).routeInformationProvider.value.uri.path;
          final newPath = currentPath.replaceFirst(
            RegExp(r'^/(en|es)'),
            '/${locale.languageCode}',
          );
          context.go(newPath);
        },
      ),
    );
  }
}
```

**Features**:
- Displays language names with optional country flags.
- Highlights the current locale with a checkmark.
- Supports custom callbacks for locale changes.

---

## Advanced Usage

### Fallback Locale

Specify a fallback locale to use when a translation is missing.

**Example**:
```dart
await EasyLocalize().initialize(
  defaultLocale: Locale('en', 'US'),
  supportedLocales: [Locale('en', 'US'), Locale('es', 'ES')],
  path: 'assets/translations',
  fallbackLocale: Locale('en', 'US'),
);
```

If a key is missing in `es_ES`, `EasyLocalize` falls back to `en_US`.

### Async Translation Loading

Translations are loaded lazily to optimize performance. Only the current locale’s translations are loaded initially, with others loaded on demand.

**Example**:
```dart
await context.setLocale(Locale('es', 'ES')); // Loads es_ES.json if not cached
```

### Formatting Dates and Numbers

Use `formatDate` and `formatNumber` for locale-specific formatting.

**Example**:
```dart
String formattedDate = context.formatDate(
  DateTime.now(),
  pattern: 'EEEE, MMMM d, yyyy',
); // e.g., "Wednesday, May 14, 2025"

String formattedNumber = context.formatNumber(
  1234.56,
  pattern: '#,##0.00',
); // e.g., "1,234.56" in en_US, "1.234,56" in es_ES
```

### Dynamic Locale Addition

Add new locales at runtime, useful for apps fetching translations from an API.

**Example**:
```dart
await EasyLocalize().addLocale(
  Locale('fr', 'FR'),
  'assets/translations',
  onError: (error) => print('Error adding locale: $error'),
);
```

### Translation Existence Check

Check if a translation exists for a key.

**Example**:
```dart
bool hasTranslation = context.easyLocalize.hasTranslation('home.title');
if (!hasTranslation) {
  // Handle missing translation
}
```

### Reloading Translations

Reload all translations, useful for updating translations from an API.

**Example**:
```dart
await EasyLocalize().reload(
  onError: (error) => print('Error reloading translations: $error'),
);
```

### GoRouter Integration

Integrate with `go_router` for locale-aware routing (e.g., `/en/home`, `/es/inicio`).

**Example Router Setup** (`router.dart`):
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad_india/utils/translation_service/easy_localize_extensions.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

GoRouter createRouter(BuildContext context, EasyLocalize easyLocalize) {
  return GoRouter(
    initialLocation: '/${easyLocalize.currentLocale.languageCode}/${easyLocalize.translateRoute('routes.home')}',
    routes: [
      GoRoute(
        path: '/:lang(${easyLocalize.translateRoute('routes.home')}|${easyLocalize.translateRoute('routes.settings')})',
        redirect: (context, state) async {
          final lang = state.pathParameters['lang'];
          final supportedLocales = easyLocalize.supportedLocales;
          final currentLocale = easyLocalize.currentLocale;

          final isSupported = supportedLocales.any((locale) => locale.languageCode == lang);
          if (!isSupported) {
            return '/${currentLocale.languageCode}${state.matchedLocation.replaceFirst('/$lang', '')}';
          }

          if (lang != currentLocale.languageCode) {
            await context.setLocale(Locale(lang!));
          }
          return null;
        },
        routes: [
          GoRoute(
            path: easyLocalize.translateRoute('routes.home'),
            builder: (context, state) => HomeScreen(),
          ),
          GoRoute(
            path: easyLocalize.translateRoute('routes.settings'),
            builder: (context, state) => SettingsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) async {
      final path = state.matchedLocation;
      if (!path.startsWith(RegExp(r'/(en|es)'))) {
        return '/${easyLocalize.currentLocale.languageCode}/${easyLocalize.translateRoute('routes.home')}';
      }
      return null;
    },
  );
}
```

**Usage**:
- Routes reflect the current locale (e.g., `/en/home`, `/es/inicio`).
- Locale changes update the route automatically via `LanguageSelector`.

---

## Error Handling

`EasyLocalize` provides robust error handling through the `ErrorHandler` class.

**Example**:
```dart
await EasyLocalize().initialize(
  defaultLocale: Locale('en', 'US'),
  supportedLocales: [Locale('en', 'US'), Locale('es', 'ES')],
  path: 'assets/translations',
  onError: (error) {
    print('Initialization error: $error');
    // Optionally log to analytics
  },
);
```

**Features**:
- Debug-mode warnings for missing translations.
- Centralized error logging via `ErrorHandler`.
- Fallback to the key or default locale for missing translations.

---

## Testing

`EasyLocalize` is designed for testability. Below are example tests.

**Unit Test** (`test/easy_localize_test.dart`):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_ad_india/utils/translation_service/easy_localize.dart';

void main() {
  group('EasyLocalize', () {
    late EasyLocalize easyLocalize;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      easyLocalize = EasyLocalize();
    });

    test('initialize sets default locale', () async {
      await easyLocalize.initialize(
        defaultLocale: Locale('en', 'US'),
        supportedLocales: [Locale('en', 'US'), Locale('es', 'ES')],
        path: 'assets/translations',
      );
      expect(easyLocalize.currentLocale, Locale('en', 'US'));
    });

    test('setLocale updates locale', () async {
      await easyLocalize.initialize(
        defaultLocale: Locale('en', 'US'),
        supportedLocales: [Locale('en', 'US'), Locale('es', 'ES')],
        path: 'assets/translations',
      );
      await easyLocalize.setLocale(Locale('es', 'ES'));
      expect(easyLocalize.currentLocale, Locale('es', 'ES'));
    });
  });
}
```

**Widget Test** (`test/language_selector_test.dart`):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_ad_india/utils/translation_service/easy_localize.dart';
import 'package:my_ad_india/utils/translation_service/language_selector.dart';

void main() {
  testWidgets('LanguageSelector switches locale', (WidgetTester tester) async {
    final easyLocalize = EasyLocalize();
    await easyLocalize.initialize(
      defaultLocale: Locale('en', 'US'),
      supportedLocales: [Locale('en', 'US'), Locale('es', 'ES')],
      path: 'assets/translations',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: EasyLocalizeProvider(
          easyLocalize: easyLocalize,
          child: LanguageSelector(
            languageNames: {
              Locale('en', 'US'): 'English',
              Locale('es', 'ES'): 'Spanish',
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Spanish'));
    await tester.pumpAndSettle();
    expect(easyLocalize.currentLocale, Locale('es', 'ES'));
  });
}
```

---

## API Reference

### `EasyLocalize`
- `initialize`: Initializes localization with default and supported locales.
- `setLocale`: Changes the current locale.
- `translate`: Retrieves a translated string with optional arguments.
- `translatePlural`: Handles plural forms based on CLDR rules.
- `formatDate`: Formats a date for the current locale.
- `formatNumber`: Formats a number for the current locale.
- `addLocale`: Adds a new locale at runtime.
- `reload`: Reloads all translations.
- `hasTranslation`: Checks if a translation exists.

### `EasyLocalizeApp`
- Wraps the app to provide localization context.

### `EasyLocalizeBuilder`
- Rebuilds widgets when the locale changes.

### `EasyLocalizeProvider`
- Provides access to `EasyLocalize` via `BuildContext`.

### `LanguageSelector`
- A widget for selecting languages with customizable UI.

### Extension Methods
- `context.tr(key, {args})`: Translates a string.
- `context.plural(key, count, {args})`: Translates a pluralized string.
- `context.formatDate(date, {pattern, locale})`: Formats a date.
- `context.formatNumber(number, {pattern, locale})`: Formats a number.
- `context.setLocale(locale)`: Sets the locale.
- `context.locale`: Gets the current locale.

---

## Examples

### Basic Translation
```dart
Text(context.tr('home.welcome', args: TranslationArgs({'appName': 'MyApp'})));
```

### Pluralization
```dart
Text(context.plural('items', 3)); // "3 items" in en_US, "3 elementos" in es_ES
```

### Date Formatting
```dart
Text(context.formatDate(DateTime.now(), pattern: 'yyyy-MM-dd'));
```

### GoRouter Navigation
```dart
context.go('/${context.locale.languageCode}/${context.tr('routes.settings')}');
```

### Dynamic Translations from API
Integrate with a Node.js/PHP backend to fetch translations dynamically:

**Node.js API Example**:
```javascript
const express = require('express');
const app = express();

app.get('/translations/:locale', async (req, res) => {
  const { locale } = req.params;
  // Fetch from MySQL
  const translations = await db.query('SELECT key, value FROM translations WHERE locale = ?', [locale]);
  res.json(translations.reduce((acc, { key, value }) => ({ ...acc, [key]: value }), {}));
});

app.listen(3000);
```

**Flutter Code**:
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> fetchTranslations(Locale locale) async {
  final response = await http.get(Uri.parse('http://your-api/translations/${locale.toString()}'));
  if (response.statusCode == 200) {
    final translations = json.decode(response.body);
    // Update EasyLocalize translations
    await EasyLocalize().addLocale(locale, '', onError: (e) => print(e));
    // Save to local cache if needed
  }
}
```

---

## Contributing

Contributions are welcome! Please:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/YourFeature`).
3. Commit your changes (`git commit -m 'Add YourFeature'`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Open a pull request.

Report issues or suggest features on the [GitHub repository](https://github.com/your-repo/easylocalize).

---

## License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

This `README.md` provides a comprehensive guide to using `EasyLocalize`, covering basic and advanced use cases, testing, and integration with GoRouter and backend APIs. It’s designed to be clear for junior developers while offering advanced insights for experts. If you need further customization (e.g., specific API integration examples with PHP/MySQL or additional widget examples), please let me know!