// import 'package:flutter_test/flutter_test.dart';
// import 'package:pack/services/translation_service/easy_localize.dart';
// import 'package:flutter/material.dart';
//
// void main() {
//   late EasyLocalize easyLocalize;
//   setUp(() {
//     easyLocalize = EasyLocalize();
//   });
//
//   test('Initialize and translate', () async {
//     await easyLocalize.initialize(
//       defaultLocale: Locale('en'),
//       supportedLocales: [Locale('en'), Locale('es')],
//       path: 'assets/translations',
//       fallbackLocale: Locale('en'),
//     );
//     expect(easyLocalize.translate('hello'), isNotEmpty);
//   });
//
//   test('Plural translation', () async {
//     await easyLocalize.initialize(
//       defaultLocale: Locale('en'),
//       supportedLocales: [Locale('en')],
//       path: 'assets/translations',
//     );
//     expect(easyLocalize.translatePlural('apples', 1), contains('apple'));
//     expect(easyLocalize.translatePlural('apples', 2), contains('apples'));
//   });
//
//   test('Fallback locale', () async {
//     await easyLocalize.initialize(
//       defaultLocale: Locale('fr'),
//       supportedLocales: [Locale('fr')],
//       path: 'assets/translations',
//       fallbackLocale: Locale('en'),
//     );
//     expect(easyLocalize.translate('hello'), isNotEmpty);
//   });
//
//   test('Format date and number', () async {
//     await easyLocalize.initialize(
//       defaultLocale: Locale('en'),
//       supportedLocales: [Locale('en')],
//       path: 'assets/translations',
//     );
//     final now = DateTime(2024, 1, 1);
//     expect(easyLocalize.formatDate(now), isNotEmpty);
//     expect(easyLocalize.formatNumber(12345), isNotEmpty);
//   });
//
//   test('Error management', () async {
//     bool errorCaught = false;
//     await easyLocalize.initialize(
//       defaultLocale: Locale('en'),
//       supportedLocales: [Locale('en')],
//       path: 'bad/path',
//       onError: (_) => errorCaught = true,
//     );
//     expect(errorCaught, true);
//   });
// }
