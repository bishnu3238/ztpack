// // Generate Mocks:
// // Add @GenerateMocks([SearchRepository, RecentSearchStorage]) to the test file.
// // Run flutter pub run build_runner build to generate the mock files (search_module_test.mocks.dart).
// // Run Tests:
// // Execute flutter test in the package directory to run the tests.
//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:provider/provider.dart';
//  import 'package:shared_preferences/shared_preferences.dart';
//  import '../search_utility.dart';
//
// // Generated mocks (run `flutter pub run build_runner build` after adding mockito)
// import '../src/core/models/searchable.dart';
// import 'test.mocks.dart';
//
// // Mock Searchable implementation for testing
// class MockSearchable extends Searchable {
//   @override
//   String get id => 'mock_id';
//   @override
//   String get displayName => 'Mock Item';
//   @override
//   String get displayDescription => 'Mock Description';
//   @override
//   String? get imageUrl => null;
//   @override
//   SearchResultType get resultType => SearchResultType.service;
//   @override
//   Map<String, dynamic> get searchableFields => {'name': 'Mock Item', 'description': 'Mock Description'};
//
//   @override
//   bool matchesQuery(String query) => displayName.toLowerCase().contains(query.toLowerCase());
// }
//
// @GenerateMocks([SearchRepository, RecentSearchStorage])
// void main() {
//   late MockSearchRepository mockRepository;
//   late MockRecentSearchStorage mockStorage;
//   late SearchViewModel viewModel;
//
//   setUp(() async {
//     mockRepository = MockSearchRepository();
//     mockStorage = MockRecentSearchStorage();
//
//     // Mock SharedPreferences for RecentSearchStorage
//     SharedPreferences.setMockInitialValues({'recent_searches': ['test1', 'test2']});
//
//     viewModel = SearchViewModel(
//       repository: mockRepository,
//       recentSearchStorage: mockStorage,
//       config: SearchConfig(),
//     );
//   });
//
//   group('SearchViewModel Tests', () {
//     test('Initial state is correct', () {
//       expect(viewModel.query, '');
//       expect(viewModel.isLoading, false);
//       expect(viewModel.showSuggestions, false);
//       expect(viewModel.isFocused, false);
//       expect(viewModel.recentSearches, isEmpty); // Before load
//     });
//
//     test('Loads recent searches successfully', () async {
//       when(mockStorage.getRecentSearches()).thenAnswer((_) async => ['test1', 'test2']);
//       await viewModel._loadRecentSearches();
//       expect(viewModel.recentSearches, ['test1', 'test2']);
//     });
//
//     test('Adds recent search', () async {
//       when(mockStorage.addRecentSearch('test3')).thenAnswer((_) async {});
//       when(mockStorage.getRecentSearches()).thenAnswer((_) async => ['test3', 'test1', 'test2']);
//       when(mockRepository.search('test3')).thenAnswer((_) async => Right([MockSearchable()]));
//
//       viewModel.onQueryChanged('test3');
//       await viewModel.search();
//
//       verify(mockStorage.addRecentSearch('test3')).called(1);
//       expect(viewModel.recentSearches, ['test3', 'test1', 'test2']);
//     });
//
//     test('Clears recent searches', () async {
//       when(mockStorage.clearRecentSearches()).thenAnswer((_) async {});
//       when(mockStorage.getRecentSearches()).thenAnswer((_) async => []);
//
//       await viewModel.clearRecentSearches();
//       expect(viewModel.recentSearches, isEmpty);
//     });
//
//     test('Fetches suggestions on query change', () async {
//       when(mockRepository.getSuggestions('test'))
//           .thenAnswer((_) async => Right([MockSearchable()]));
//       viewModel.onQueryChanged('test');
//       await Future.delayed(const Duration(milliseconds: 300)); // Wait for debounce
//       expect(viewModel.suggestions, isNotEmpty);
//     });
//   });
//
//   group('SearchPage Widget Tests', () {
//     testWidgets('Shows recommended suggestions when not focused', (tester) async {
//       final recommendedWidget = Container(key: const Key('recommended'), child: const Text('Recommended'));
//
//       await tester.pumpWidget(
//         ChangeNotifierProvider(
//           create: (_) => viewModel,
//           child: MaterialApp(
//             home: SearchPage(
//               recommendedSuggestions: recommendedWidget,
//               onResultTap: (_) {},
//             ),
//           ),
//         ),
//       );
//
//       expect(find.byKey(const Key('recommended')), findsOneWidget);
//       expect(find.text('Recent Searches'), findsNothing);
//     });
//
//     testWidgets('Switches to recent searches when focused', (tester) async {
//       when(mockStorage.getRecentSearches()).thenAnswer((_) async => ['test1', 'test2']);
//       await viewModel._loadRecentSearches();
//
//       final recommendedWidget = Container(key: const Key('recommended'), child: const Text('Recommended'));
//
//       await tester.pumpWidget(
//         ChangeNotifierProvider(
//           create: (_) => viewModel,
//           child: MaterialApp(
//             home: SearchPage(
//               recommendedSuggestions: recommendedWidget,
//               onResultTap: (_) {},
//             ),
//           ),
//         ),
//       );
//
//       // Focus the search field
//       await tester.tap(find.byType(CupertinoSearchTextField));
//       await tester.pump();
//
//       expect(find.text('Recent Searches'), findsOneWidget);
//       expect(find.text('test1'), findsOneWidget);
//       expect(find.text('test2'), findsOneWidget);
//       expect(find.byKey(const Key('recommended')), findsNothing);
//     });
//
//     testWidgets('Calls onResultTap when search result is tapped', (tester) async {
//       when(mockRepository.search('test')).thenAnswer((_) async => Right([MockSearchable()]));
//       bool tapped = false;
//
//       await tester.pumpWidget(
//         ChangeNotifierProvider(
//           create: (_) => viewModel,
//           child: MaterialApp(
//             home: SearchPage(
//               recommendedSuggestions: Container(),
//               onResultTap: (result) {
//                 tapped = true;
//                 expect(result.displayName, 'Mock Item');
//               },
//             ),
//           ),
//         ),
//       );
//
//       // Perform a search
//       await tester.enterText(find.byType(CupertinoSearchTextField), 'test');
//       await tester.testTextInput.receiveAction(TextInputAction.search);
//       await tester.pump();
//
//       // Tap the result
//       await tester.tap(find.text('Mock Item'));
//       await tester.pump();
//
//       expect(tapped, true);
//     });
//   });
// }