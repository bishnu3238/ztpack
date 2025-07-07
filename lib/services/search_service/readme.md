# Search Module

A reusable Flutter package for implementing a search functionality with features like recent searches, dynamic suggestions, and customizable recommendations.

## Features

- **Search Functionality**: Search across multiple data types with pagination support.
- **Recent Searches**: Persist and display recent search queries using `SharedPreferences`.
- **Dynamic Suggestions**: Show real-time suggestions as the user types (debounced).
- **Recommended Suggestions**: Display custom recommendations when the search field is not focused.
- **Customizable Result Handling**: Pass a callback to handle taps on search results.
- **Error Handling**: Robust error management with `dartz`’s `Either`.
- **Dependency Injection**: Uses `get_it` for easy dependency management.

## Installation

Add the package to your `pubspec.yaml`:

dependencies:
  search_module:
    path: ../search_service # Replace with your package path or hosted version

**** Configuring Dependencies
**** The setupDependencies function initializes default implementations. You can customize it:
    
 ## Usage
### 1. Initialize the Dependency Injection Module
```dart
 _getIt.registerFactoryParam<
      SearchViewModel,
      SearchRepository,
      RecentSearchStorage>((param1, param2) =>
          SearchViewModel(repository: param1, recentSearchStorage: param2),
    );
}
```


## Example
## Customizing Searchable Models
## Implement the Searchable interface for your data models:
```dart
class CustomItem implements Searchable {
  final String id;
  final String name;

  CustomItem(this.id, this.name);

  @override
  String get id => id;
  @override
  String get displayName => name;
  @override
  String get displayDescription => 'Description of $name';
  @override
  String? get imageUrl => null;
  @override
  SearchResultType get resultType => SearchResultType.service;
  @override
  Map<String, dynamic> get searchableFields => {'name': name, 'description': displayDescription};
}
```

## Custom Data Store
## Create a custom DataStore for your data:
```dart
class CustomStore implements DataStore {
  final List<CustomItem> items;

  CustomStore(this.items);

  @override
  Future<List<Searchable>> searchItems(String query, {int? skip, int? take}) async {
    final filtered = items.where((item) => item.matchesQuery(query)).toList();
    if (skip != null || take != null) {
      final start = skip ?? 0;
      final end = take != null ? start + take : filtered.length;
      return filtered.skip(start).take(end - start).toList();
    }
    return filtered;
  }

  @override
  Future<List<Searchable>> getAll() async => items;
}
```

## Search Page
## Use the SearchPage widget to display the search UI:
```dart
          GoRoute(
            path: search,
            builder:
                (context, state) => FutureBuilder<RecentSearchStorage>(
                  future: RecentSearchStorage.create(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CupertinoActivityIndicator();
                    }

                    final recentSearchStorage = snapshot.data!;

                    return ChangeNotifierProvider(
                      create:
                          (context) => SearchViewModel(
                            repository: SearchRepositoryImpl(
                              stores: [
                                DependencyInjector.get<CategoryStore>(),
                                DependencyInjector.get<SubCategoryStore>(),
                                DependencyInjector.get<ServiceStore>(),
                              ],

                              maxSuggestionsPerType: 5,
                            ),
                            recentSearchStorage: recentSearchStorage,
                          ),
                      child: SearchPage(
                        recommendedSuggestions: SizedBox(),
                        onResultTap: (s) {},
                      ),
                    );
                  },
                ),
          ),
```




---

### **Explanation**

#### **Test Code**
- **Unit Tests**: Test `SearchViewModel` methods like loading recent searches, adding searches, clearing searches, and fetching suggestions using Mockito mocks.
- **Widget Tests**: Test `SearchPage` behavior, including showing recommended suggestions when unfocused, switching to recent searches when focused, and triggering `onResultTap`.
- **Mocks**: Use `mockito` to mock `SearchRepository` and `RecentSearchStorage` for isolated testing.

#### **README.md**
- **Overview**: Describes the package’s purpose and features.
- **Installation**: Guides users on adding the package and its dependencies.
- **Setup**: Explains how to initialize dependencies with examples.
- **Usage**: Provides basic and advanced examples, including custom models and stores.
- **API Reference**: Documents key classes and properties.
- **Testing**: Instructs users on running tests.

---

### **Next Steps**
1. **Add Tests**: Place the test code in `test/search_service_test.dart` and run `flutter test` to verify functionality.
2. **Update README**: Save the `README.md` content in your package’s root directory.
3. **Publish (Optional)**: If you plan to publish this package to `pub.dev`, ensure all dependencies are correctly listed and run `flutter pub publish --dry-run` to validate.

Let me know if you need help refining the tests or README further!
