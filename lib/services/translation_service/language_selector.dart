import 'package:flutter/material.dart';
 import 'easy_localize_extensions.dart';

class LanguageSelector extends StatelessWidget {
  final Map<Locale, String> languageNames;
  final Widget? title;
  final bool showCountryFlags;
  final void Function(Locale)? onLocaleSelected;

  const LanguageSelector({
    super.key,
    required this.languageNames,
    this.title,
    this.showCountryFlags = true,
    this.onLocaleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: languageNames.length,
      itemBuilder: (context, index) {
        final locale = languageNames.keys.elementAt(index);
        final name = languageNames[locale]!;

        return ListTile(
          leading: showCountryFlags ? _buildFlag(locale) : null,
          title: Text(name),
          onTap: () async {
            await context.setLocale(locale);
            // Navigate to the current route with the new locale
            // final currentPath = GoRouter.of(context).routeInformationProvider.value.uri.path;
            // final newPath = currentPath.replaceFirst(
            //   RegExp(r'^/(en|es)'),
            //   '/${locale.languageCode}',
            // );
            // context.go(newPath);
            if (onLocaleSelected != null) {
              onLocaleSelected!(locale);
            }
          },
          trailing: context.locale.languageCode == locale.languageCode
              ? Icon(Icons.check, color: Theme.of(context).primaryColor)
              : null,
        );
      },
    );
  }

  Widget _buildFlag(Locale locale) {
    final String countryCode = locale.countryCode?.toUpperCase() ?? locale.languageCode.toUpperCase();
    return Text(
      getCountryFlag(countryCode),
      style: TextStyle(fontSize: 24),
    );
  }

  String getCountryFlag(String countryCode) {
    if (countryCode.length != 2) return '';
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }
}