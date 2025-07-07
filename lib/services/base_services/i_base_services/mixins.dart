import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:shared_preferences/shared_preferences.dart';

import '../base_model.dart';
import 'collection_store.dart';
import 'entitiy_store.dart';

/// A mixin for adding search capabilities to a collection store
mixin SearchableMixin<T extends BaseModel<T>> on CollectionStore<T> {
  List<T> _searchedItems = [];
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isSearchLoading = false;

  // Additional getters for search functionality
  List<T> get filteredItems => _isSearching ? _searchedItems : items;

  bool get isSearching => _isSearching;
  bool get isSearchLoading => _isSearchLoading;
  String get searchQuery => _searchQuery;

  /// Set search loading state
  void setSearchLoading(bool loading) {
    if (_isSearchLoading != loading) {
      _isSearchLoading = loading;
      notifyListeners();
    }
  }

  /// Set filtered items with search results
  void setSearchedItems(List<T> items) {
    _searchedItems = List.from(items);
    _isSearchLoading = false;
    notifyListeners();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;

      if (!_isSearching) {
        _searchedItems = [];
      }

      notifyListeners();
    }
  }

  /// Execute search on items with provided matcher function
  void searchLocal(String query, bool Function(T item, String query) matcher) {
    updateSearchQuery(query);

    if (query.isEmpty) {
      _searchedItems = [];
      _isSearching = false;
    } else {
      _searchedItems = items.where((item) => matcher(item, query)).toList();
    }

    notifyListeners();
  }

  /// Clear search and reset to original items
  void clearSearch() {
    if (_isSearching) {
      _searchQuery = '';
      _isSearching = false;
      _searchedItems = [];
      _isSearchLoading = false;
      notifyListeners();
    }
  }

  Future<List<T>> searchItems(String query, {int? skip, int? take}) async {
    // Implement search logic
    final filteredItems =
        items.where((item) {
          // Implement your search logic here
          // This is a placeholder and should be overridden
          return true;
        }).toList();

    // Apply pagination if requested
    if (skip != null || take != null) {
      final start = skip ?? 0;
      final end = take != null ? start + take : filteredItems.length;
      return filteredItems.skip(start).take(end - start).toList();
    }

    return filteredItems;
  }
}

/// A mixin for filtering data in collection stores
mixin FilterableMixin<T extends BaseModel<T>, F> on CollectionStore<T> {
  F? _activeFilter;
  List<T> _filteredItems = [];
  bool _isFiltering = false;
  Map<String, dynamic> _filterParams = {};

  F? get activeFilter => _activeFilter;
  bool get isFiltering => _isFiltering;
  Map<String, dynamic> get filterParams => Map.unmodifiable(_filterParams);

  List<T> get filteredItems => _isFiltering ? _filteredItems : super.items;

  /// Apply a filter with custom filter logic
  void applyFilter(F filter, bool Function(T item, F filter) filterLogic) {
    _activeFilter = filter;
    _isFiltering = true;
    _filteredItems =
        super.items.where((item) => filterLogic(item, filter)).toList();
    notifyListeners();
  }

  /// Set filter parameters for use with external filtering
  void setFilterParams(Map<String, dynamic> params) {
    _filterParams = Map.from(params);
    notifyListeners();
  }

  /// Update a single filter parameter
  void updateFilterParam(String key, dynamic value) {
    _filterParams = {..._filterParams, key: value};
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    if (_isFiltering || _filterParams.isNotEmpty) {
      _activeFilter = null;
      _isFiltering = false;
      _filteredItems = [];
      _filterParams = {};
      notifyListeners();
    }
  }
}

/// A mixin for sorting data in collection stores
mixin SortableMixin<T extends BaseModel<T>> on CollectionStore<T> {
  String? _sortBy;
  bool _sortAscending = true;

  String? get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  /// Sort items with a provided comparator function
  void sortItems({
    required String by,
    bool? ascending,
    required int Function(T a, T b) comparator,
  }) {
    bool changed =
        _sortBy != by || (ascending != null && _sortAscending != ascending);

    if (!changed) return;

    _sortBy = by;
    _sortAscending = ascending ?? !_sortAscending;

    final mutableList = List<T>.from(super.items);
    mutableList.sort(
      (a, b) => _sortAscending ? comparator(a, b) : comparator(b, a),
    );

    super.setItems(mutableList);
  }

  /// Reset sorting
  void clearSort() {
    if (_sortBy != null) {
      _sortBy = null;
      _sortAscending = true;
      notifyListeners();
    }
  }
}

/// A mixin for caching items in a collection store
mixin CacheMixin<T extends BaseModel<T>> on CollectionStore<T> {
  final Map<String, T> _cache = {};
  final Queue<String> _cacheOrder = Queue<String>();
  final int _maxCacheSize = 100;

  T? getCached(String id) => _cache[id];

  void cacheItem(T item) {
    _cache[item.id!] = item;
    _cacheOrder.add(item.id!);

    // Remove oldest items if cache exceeds max size
    while (_cache.length > _maxCacheSize) {
      final oldestId = _cacheOrder.removeFirst();
      _cache.remove(oldestId);
    }
  }

  void clearCache() {
    _cache.clear();
    _cacheOrder.clear();
  }

  bool isCache(String id) => _cache.containsKey(id);
}

/// A mixin for adding offline support to a collection store
mixin OfflineSupportMixin<T extends BaseModel<T>> on CollectionStore<T> {
  String get storageKey => '${T.toString()}_offline_data';

  Future<void> saveOffline() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(storageKey, jsonList);
    } catch (e) {
      dev.log('Error saving offline data: $e');
    }
  }

  Future<void> loadOffline(
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(storageKey) ?? [];

      if (jsonList.isNotEmpty) {
        final loadedItems =
            jsonList.map((jsonStr) => fromJson(jsonDecode(jsonStr))).toList();

        setItems(loadedItems);
      }
    } catch (e) {
      dev.log('Error loading offline data: $e');
    }
  }

  Future<void> clearOffline() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
    } catch (e) {
      dev.log('Error clearing offline data: $e');
    }
  }
}

mixin LocalStorageMixin<T extends BaseModel<T>> on EntityStore<T> {
  String get storageKey => '${T.toString()}_local_data';

  Future<void> saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(entity?.toJson());
      await prefs.setString(storageKey, json);
    } catch (e) {
      dev.log('Error saving to local storage: $e');
    }
  }

  Future<void> loadFromLocalStorage(
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(storageKey);
      if (jsonStr != null) {
        final json = jsonDecode(jsonStr);
        final loadedItem = fromJson(json);
        setEntity(loadedItem);
      }
    } catch (e) {
      dev.log('Error loading from local storage: $e');
    }
  }

  Future<void> clearLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
    } catch (e) {
      dev.log('Error clearing local storage: $e');
    }
  }
}
