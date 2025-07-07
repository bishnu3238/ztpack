// File: easy_localize_builder.dart
import 'package:flutter/material.dart';
import 'easy_localize.dart';
import 'easy_localize_provider.dart';

class EasyLocalizeBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, Locale locale) builder;

  const EasyLocalizeBuilder({
    super.key,
    required this.builder,
  });

  @override
  State<EasyLocalizeBuilder> createState() => _EasyLocalizeBuilderState();
}

class _EasyLocalizeBuilderState extends State<EasyLocalizeBuilder> {
  late EasyLocalize _easyLocalize;
  late Locale _currentLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _easyLocalize = EasyLocalizeProvider.of(context).easyLocalize;
    _currentLocale = _easyLocalize.currentLocale;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Locale>(
      stream: _easyLocalize.localeStream,
      initialData: _currentLocale,
      builder: (context, snapshot) {
        return widget.builder(context, snapshot.data!);
      },
    );
  }
}
