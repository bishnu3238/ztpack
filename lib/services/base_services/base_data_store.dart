import 'package:flutter/foundation.dart';
import 'package:pack/services/failure/failure.dart';
import 'package:pack/services/search_service/search_utility.dart';

/// A generic abstract data store class that can be extended by specific stores
/// to handle common state management, pagination, error handling, and more.
abstract class BaseDataStore<T> extends ChangeNotifier {
  List<T> _items = [];
  bool _isLoading = false;
  NetworkFailure? _error;
  T? _selectedItem;
  int _currentPage = 1;
  int _pageSize;
  bool _hasMoreData = true;
  bool _isInitialized = false;

  /// Constructor with optional initial values
  BaseDataStore({
    List<T>? initialItems,
    bool isLoading = false,
    NetworkFailure? error,
    T? selectedItem,
    int pageSize = 10,
  }) : _items = initialItems ?? [],
       _isLoading = isLoading,
       _error = error,
       _selectedItem = selectedItem,
       _pageSize = pageSize;

  // Getters for state
  List<T> get items => _items;
  bool get isLoading => _isLoading;
  NetworkFailure? get error => _error;
  T? get selectedItem => _selectedItem;
  bool get hasItems => _items.isNotEmpty;
  bool get hasError => _error != null;
  bool get hasSelected => _selectedItem != null;
  bool get hasMoreData => _hasMoreData;
  bool get isInitialized => _isInitialized;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  /// Sets the loading state and notifies listeners
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Sets the error state and notifies listeners
  void setError(NetworkFailure? failure) {
    _error = failure;
    if (failure != null) {
      _isLoading = false;
    }
    notifyListeners();
  }

  /// Clears the current error
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  /// Sets the items list and notifies listeners
  void setItems(List<T> newItems, {bool append = false}) {
    if (append) {
      _items.addAll(newItems);
    } else {
      _items = List.from(newItems); // Create a copy for immutability
    }

    _error = null; // Clear error on successful update
    _isInitialized = true;

    // Update pagination state
    if (newItems.length < _pageSize) {
      _hasMoreData = false;
    }

    notifyListeners();
  }

  /// Selects an item and notifies listeners
  void selectItem(T item) {
    if (_selectedItem != item) {
      _selectedItem = item;
      notifyListeners();
    }
  }

  /// Clears the selected item
  void clearSelection() {
    if (_selectedItem != null) {
      _selectedItem = null;
      notifyListeners();
    }
  }

  /// Refreshes the item list by clearing existing data and refetching
  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    _currentPage = 1;
    _hasMoreData = true;
    _items = [];
    notifyListeners();

    try {
      await fetchData();
    } catch (e) {
      _error = e is NetworkFailure ? e : NetworkFailure(message: e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads more items (pagination)
  Future<void> loadMore() async {
    if (_hasMoreData && !_isLoading) {
      _currentPage++;
      _isLoading = true;
      notifyListeners();

      try {
        await fetchData(page: _currentPage, append: true);
      } catch (e) {
        _error =
            e is NetworkFailure ? e : NetworkFailure(message: e.toString());
        _currentPage--; // Revert page increment on failure
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Initialize the store by loading initial data
  Future<void> initialize() async {
    if (!_isInitialized && !_isLoading) {
      await refresh();
    }
  }

  /// Method to be implemented by subclasses to fetch data
  Future<void> fetchData({int? page, bool append = false});

  /// Updates an item in the list
  void updateItem(T item, bool Function(T current) finder) {
    final index = _items.indexWhere(finder);
    if (index != -1) {
      _items[index] = item;

      // Update selected item if it matches
      if (_selectedItem != null && finder(_selectedItem!)) {
        _selectedItem = item;
      }

      notifyListeners();
    }
  }

  /// Adds a new item to the list
  void addItem(T item, {bool selectAfterAdd = false}) {
    _items = [..._items, item];

    if (selectAfterAdd) {
      _selectedItem = item;
    }

    notifyListeners();
  }

  /// Removes an item from the list
  void removeItem(bool Function(T item) finder) {
    final existingIndex = _items.indexWhere(finder);

    if (existingIndex != -1) {
      _items = List.from(_items)..removeAt(existingIndex);

      // Clear selection if the removed item was selected
      if (_selectedItem != null && finder(_selectedItem!)) {
        _selectedItem = null;
      }

      notifyListeners();
    }
  }

  /// Creates a new instance with updated state (to be implemented by subclasses)
  BaseDataStore<T> copyWith();

  /// Method to reset store state
  void reset() {
    _items = [];
    _isLoading = false;
    _error = null;
    _selectedItem = null;
    _currentPage = 1;
    _hasMoreData = true;
    _isInitialized = false;
    notifyListeners();
  }

  /// Dispose of any resources
  @override
  void dispose() {
    // Clean up if needed (e.g., listeners or subscriptions)
    super.dispose();
  }
}

/// A more specific abstract class for searchable data stores
abstract class SearchableDataStore<T extends Searchable>
    extends BaseDataStore<T> {
  List<T> _filteredItems = [];
  String _searchQuery = '';
  bool _isSearching = false;

  SearchableDataStore({
    super.initialItems,
    super.isLoading,
    super.error,
    super.selectedItem,
    super.pageSize,
  });

  // Additional getters for search functionality
  List<T> get filteredItems =>
      _filteredItems.isEmpty && _searchQuery.isEmpty ? items : _filteredItems;

  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  /// Performs a search on the items list
  void search(String query) {
    _searchQuery = query;
    _isSearching = query.isNotEmpty;

    if (query.isEmpty) {
      _filteredItems = [];
    } else {
      _filteredItems = items.where((item) => item.matchesQuery(query)).toList();
    }

    notifyListeners();
  }

  /// Clears the current search
  void clearSearch() {
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      _isSearching = false;
      _filteredItems = [];
      notifyListeners();
    }
  }

  @override
  void setItems(List<T> newItems, {bool append = false}) {
    super.setItems(newItems, append: append);

    // Re-apply search filter if active
    if (_isSearching) {
      _filteredItems =
          items.where((item) => item.matchesQuery(_searchQuery)).toList();
    }
  }
}

/// A mixin for stores that need caching capabilities
mixin CachedMixin<T> on BaseDataStore<T> {
  bool _isCached = false;
  DateTime? _lastCachedTime;

  bool get isCached => _isCached;
  DateTime? get lastCachedTime => _lastCachedTime;

  /// Duration for which the cache is considered valid
  Duration get cacheDuration => const Duration(minutes: 15);

  /// Checks if the cache is still valid
  bool get isCacheValid =>
      _isCached &&
      _lastCachedTime != null &&
      DateTime.now().difference(_lastCachedTime!) < cacheDuration;

  /// Marks the current data as cached
  void markCached() {
    _isCached = true;
    _lastCachedTime = DateTime.now();
  }

  /// Clears the cache status
  void invalidateCache() {
    _isCached = false;
    _lastCachedTime = null;
  }

  /// Fetch data with caching logic
  Future<void> fetchDataWithCache({
    int? page,
    bool append = false,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && page == 1 && isCacheValid) {
      // Use cached data
      return;
    }

    await fetchData(page: page, append: append);

    if (page == 1 || page == null) {
      markCached();
    }
  }
}

/// A mixin for data stores that need filtering capabilities
mixin FilteredMixin<T, F> on BaseDataStore<T> {
  F? _activeFilter;
  List<T> _filteredItems = [];
  bool _isFiltering = false;

  F? get activeFilter => _activeFilter;
  bool get isFiltering => _isFiltering;

  List<T> get filteredItems => _isFiltering ? _filteredItems : items;

  /// Applies a filter to the items list
  void applyFilter(F filter, bool Function(T item, F filter) filterLogic) {
    _activeFilter = filter;
    _isFiltering = true;
    _filteredItems = items.where((item) => filterLogic(item, filter)).toList();
    notifyListeners();
  }

  /// Clears the active filter
  void clearFilter() {
    if (_isFiltering) {
      _activeFilter = null;
      _isFiltering = false;
      _filteredItems = [];
      notifyListeners();
    }
  }

  @override
  void setItems(List<T> newItems, {bool append = false}) {
    super.setItems(newItems, append: append);

    // Re-apply filter if active
    if (_isFiltering && _activeFilter != null) {
      applyFilter(_activeFilter!, (item, filter) => _filterLogic(item, filter));
    }
  }

  /// Filter logic to be implemented by the class using this mixin
  bool _filterLogic(T item, F filter);
}

/// A mixin for data stores that need sorting capabilities
mixin SortedMixin<T> on BaseDataStore<T> {
  String? _sortBy;
  bool _sortAscending = true;

  String? get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  /// Sorts the items list
  void sortItems({
    required String by,
    bool? ascending,
    required int Function(T a, T b) comparator,
  }) {
    _sortBy = by;
    _sortAscending = ascending ?? !_sortAscending;

    final mutableList = List<T>.from(items);
    mutableList.sort(
      (a, b) => _sortAscending ? comparator(a, b) : comparator(b, a),
    );

    _items = mutableList;
    notifyListeners();
  }

  /// Clears the current sort
  void clearSort() {
    if (_sortBy != null) {
      _sortBy = null;
      _sortAscending = true;
      refresh(); // Reset to original order
    }
  }
}
