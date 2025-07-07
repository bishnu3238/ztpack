// File: easy_localize_app.dart
import 'package:flutter/material.dart';
// import 'package:my_ad_india/provider_state/theme_provider.dart';
import 'easy_localize.dart';
import 'package:pack/services/service.dart';

import 'easy_localize_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localization/flutter_localization.dart';
abstract class ThemeProviderInterface {
  ThemeData get lightTheme;
  ThemeData get darkTheme;
  ThemeMode get themeMode;
}

class EasyLocalizeApp extends StatefulWidget {
  final Widget child;
  final Locale defaultLocale;
  final List<Locale> supportedLocales;
  final String translationsPath;
  final ThemeProviderInterface? themeProvider;
  final ThemeData? lightTheme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;  final RouterConfig<Object>? router;

  const EasyLocalizeApp({
    super.key,
    required this.child,
    required this.defaultLocale,
     required this.supportedLocales,
    this.themeProvider,
    this.lightTheme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
    this.router,
    this.translationsPath = 'assets/translations',
  });

  @override
  State<EasyLocalizeApp> createState() => _EasyLocalizeAppState();
}

class _EasyLocalizeAppState extends State<EasyLocalizeApp> {
  final EasyLocalize _easyLocalize = EasyLocalize();
  late Locale _currentLocale;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocalization();
  }

  Future<void> _initializeLocalization() async {
    await _easyLocalize.initialize(
      defaultLocale: widget.defaultLocale,
      supportedLocales: widget.supportedLocales,
      path: widget.translationsPath,
    );

    _currentLocale = _easyLocalize.currentLocale;
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    final themeData = widget.themeProvider != null
        ? (
    lightTheme: widget.themeProvider!.lightTheme,
    darkTheme: widget.themeProvider!.darkTheme,
    themeMode: widget.themeProvider!.themeMode,
    )
        : (
    lightTheme: widget.lightTheme ?? ThemeData.light(),
    darkTheme: widget.darkTheme ?? ThemeData.dark(),
    themeMode: widget.themeMode,
    );

    return EasyLocalizeProvider(
      easyLocalize: _easyLocalize,
      child: EasyLocalizeBuilder(
        builder: (context, locale) {
          if (widget.router != null) {
            return MaterialApp.router(
              title: "MyAd",
              debugShowCheckedModeBanner: false,

              theme: themeData.lightTheme,
              darkTheme: themeData.darkTheme,
              themeMode: themeData.themeMode,
              locale: locale,
              supportedLocales: widget.supportedLocales,
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: widget.router!,
            );
          } else {
            return MaterialApp(
              title: "MyAd",
              debugShowCheckedModeBanner: false,

              theme: themeData.lightTheme,
              darkTheme: themeData.darkTheme,
              themeMode: themeData.themeMode ,

              locale: locale,
              supportedLocales: widget.supportedLocales,
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              // Use Builder to rebuild the subtree when locale changes
              home: Builder(builder: (context) => widget.child),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _easyLocalize.dispose();
    super.dispose();
  }


}
