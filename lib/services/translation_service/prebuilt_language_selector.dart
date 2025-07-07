import 'package:flutter/material.dart';
 import 'easy_localize_extensions.dart';

enum LanguageSelectorType { fullscreen, horizontal, vertical, dialog }


class PrebuiltLanguageSelector extends StatelessWidget {
  final Map<Locale, String> languageNames;
  final LanguageSelectorType type;
  final bool showCountryFlags;

  const PrebuiltLanguageSelector({
    super.key,
    required this.languageNames,
    this.type = LanguageSelectorType.fullscreen,
    this.showCountryFlags = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LanguageSelectorType.fullscreen:
        return _FullScreenSelector(
          languageNames: languageNames,
          showCountryFlags: showCountryFlags,
        );
      case LanguageSelectorType.horizontal:
        return _HorizontalSelector(
          languageNames: languageNames,
          showCountryFlags: showCountryFlags,
        );
      case LanguageSelectorType.vertical:
        return _VerticalSelector(
          languageNames: languageNames,
          showCountryFlags: showCountryFlags,
        );
      case LanguageSelectorType.dialog:
        return _DialogSelector(
          languageNames: languageNames,
          showCountryFlags: showCountryFlags,
        );
    }
  }
}

// --- Fullscreen selector ---
class _FullScreenSelector extends StatelessWidget {
  final Map<Locale, String> languageNames;
  final bool showCountryFlags;
  const _FullScreenSelector({
    required this.languageNames,
    required this.showCountryFlags,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Language')),
      body: _VerticalSelector(
        languageNames: languageNames,
        showCountryFlags: showCountryFlags,
      ),
    );
  }
}

// --- Horizontal selector ---
class _HorizontalSelector extends StatelessWidget {
  final Map<Locale, String> languageNames;
  final bool showCountryFlags;
  const _HorizontalSelector({
    required this.languageNames,
    required this.showCountryFlags,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: languageNames.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          final locale = languageNames.keys.elementAt(index);
          final name = languageNames[locale]!;
          final isSelected =
              context.locale.languageCode == locale.languageCode &&
              (context.locale.countryCode ?? '') == (locale.countryCode ?? '');
          return GestureDetector(
            onTap: () => context.setLocale(locale),
            child: Chip(
              avatar: showCountryFlags ? Text(_getFlag(locale)) : null,
              label: Text(name),
              backgroundColor:
                  isSelected ? Theme.of(context).primaryColor : null,
              labelStyle: TextStyle(color: isSelected ? Colors.white : null),
            ),
          );
        },
      ),
    );
  }
}

// --- Vertical selector ---
class _VerticalSelector extends StatelessWidget {
  final Map<Locale, String> languageNames;
  final bool showCountryFlags;
  const _VerticalSelector({
    required this.languageNames,
    required this.showCountryFlags,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: languageNames.length,
      separatorBuilder: (_, __) => Divider(height: 1),
      itemBuilder: (context, index) {
        final locale = languageNames.keys.elementAt(index);
        final name = languageNames[locale]!;
        final isSelected =
            context.locale.languageCode == locale.languageCode &&
            (context.locale.countryCode ?? '') == (locale.countryCode ?? '');
        return ListTile(
          leading:
              showCountryFlags
                  ? Text(_getFlag(locale), style: TextStyle(fontSize: 24))
                  : null,
          title: Text(name),
          trailing:
              isSelected
                  ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                  : null,
          onTap: () => context.setLocale(locale),
        );
      },
    );
  }
}

// --- Dialog selector ---
class _DialogSelector extends StatelessWidget {
  final Map<Locale, String> languageNames;
  final bool showCountryFlags;
  const _DialogSelector({
    required this.languageNames,
    required this.showCountryFlags,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('Change Language'),
      onPressed: () {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text('Select Language'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: _VerticalSelector(
                    languageNames: languageNames,
                    showCountryFlags: showCountryFlags,
                  ),
                ),
              ),
        );
      },
    );
  }
}

// --- Helper for flag emoji ---
String _getFlag(Locale locale) {
  final String countryCode =
      locale.countryCode?.toUpperCase() ?? locale.languageCode.toUpperCase();
  if (countryCode.length != 2) return '';
  final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
  final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
  return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
}

// class LanguageNavigator {
//   static const String languagePath = '/language';
//  static GoRoute page() => GoRoute(
//     path: languagePath,
//     builder: (context, state) {
//       final languageNames = {
//         const Locale('en', 'US'): 'English',
//         const Locale('hi', 'IN'): 'हिन्दी',
//         const Locale('bn', 'BN'): 'বাংলা',
//         const Locale('ta', 'IN'): 'தமிழ்',
//         const Locale('te', 'IN'): 'తెలుగు',
//         const Locale('ja', 'JP'): '日本語',
//         const Locale('ko', 'KR'): '한국어',
//         // const Locale('de', 'DE'): 'Deutsch',
//         // const Locale('it', 'IT'): 'Italiano',
//         // const Locale('pt', 'PT'): 'Português',
//         // const Locale('es', 'ES'): 'Español',
//         // const Locale('fr', 'FR'): 'Français',
//       };
//       final type =
//           state.extra as LanguageSelectorType? ??
//           LanguageSelectorType.fullscreen;
//       return PrebuiltLanguageSelector(languageNames: languageNames, type: type);
//     },
//   );
//
//   goToLanguageSelector(BuildContext context, [LanguageSelectorType? type]) {
//     context.push(languagePath, extra: {'type': type});
//   }
// }
