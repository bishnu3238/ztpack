import 'package:flutter/foundation.dart';
import 'package:pack/services/base_services/base_model.dart';

import 'data_store_status.dart';
import 'i_data_store.dart';
import 'operation_failure.dart';

/// Base class for collection data stores
abstract class CollectionStore<T extends BaseModel<T>> extends ChangeNotifier implements IDataStore {
  List<T> _items = [];
  T? _selectedItem;
  DataStoreStatus _status = DataStoreStatus.initial;
  OperationFailure? _error;

  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  int _pageSize;
  bool _hasMoreData = true;

  // Cache state
  bool _isCached = false;
  DateTime? _lastUpdated;

  /// Constructor with optional initial values
  CollectionStore({
    List<T>? initialItems,
    T? selectedItem,
    int pageSize = 10,
    DataStoreStatus status = DataStoreStatus.initial,
  }) : _items = initialItems ?? [],
        _selectedItem = selectedItem,
        _pageSize = pageSize,
        _status = initialItems?.isNotEmpty == true ? DataStoreStatus.loaded : status;

  // Getters for state
  List<T> get items => List.unmodifiable(_items);
  @override DataStoreStatus get status => _status;
  @override OperationFailure? get error => _error;
  T? get selectedItem => _selectedItem;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => _totalPages;
  bool get hasMoreData => _hasMoreData;
  DateTime? get lastUpdated => _lastUpdated;

  // Status checks
  @override bool get isInitial => _status == DataStoreStatus.initial;
  @override bool get isLoading => _status == DataStoreStatus.loading;
  @override bool get isRefreshing => _status == DataStoreStatus.refreshing;
  @override bool get isUpdating => _status == DataStoreStatus.updating;
  @override bool get isError => _status == DataStoreStatus.error;
  bool get isEmpty => _items.isEmpty && !isLoading && !isInitial;
  @override bool get isLoaded => _status == DataStoreStatus.loaded;
  bool get hasItems => _items.isNotEmpty;
  bool get hasSelected => _selectedItem != null;
  bool get isCached => _isCached;

  /// Update the store's status and notify listeners
  @override
  void setStatus(DataStoreStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }

  /// Set error state
  @override
  void setError(OperationFailure failure) {
    _error = failure;
    setStatus(DataStoreStatus.error);
  }

  /// Clear error state
  @override
  void clearError() {
    if (_error != null) {
      _error = null;
      // Restore previous state if we have items
      setStatus(_items.isEmpty ? DataStoreStatus.empty : DataStoreStatus.loaded);
    }
  }

  /// Set loading state (default or specific type)
  void setLoading([DataStoreStatus loadingStatus = DataStoreStatus.loading]) {
    if (loadingStatus == DataStoreStatus.loading ||
        loadingStatus == DataStoreStatus.refreshing ||
        loadingStatus == DataStoreStatus.updating) {
      setStatus(loadingStatus);
    }
  }

  /// Set items with proper status updates
  void setItems(List<T> newItems, {bool append = false}) {
    if (append) {
      _items = [..._items, ...newItems];
    } else {
      _items = List.from(newItems);
    }

    _error = null;
    _lastUpdated = DateTime.now();
    _isCached = true;

    // Update status based on item list
    if (_items.isEmpty) {
      setStatus(DataStoreStatus.empty);
    } else {
      setStatus(DataStoreStatus.loaded);
    }
  }

  /// Update pagination information
  void updatePaginationInfo({
    int? currentPage,
    int? totalPages,
    int? pageSize,
    bool? hasMoreData,
  }) {
    _currentPage = currentPage ?? _currentPage;
    _totalPages = totalPages ?? _totalPages;
    _pageSize = pageSize ?? _pageSize;
    _hasMoreData = hasMoreData ?? (currentPage != null && totalPages != null
        ? currentPage < totalPages
        : _hasMoreData);

    notifyListeners();
  }

  /// Select an item
  void selectItem(T item) {
    if (_selectedItem != item) {
      _selectedItem = item;
      notifyListeners();
    }
  }

  /// Clear selected item
  void clearSelection() {
    if (_selectedItem != null) {
      _selectedItem = null;
      notifyListeners();
    }
  }

  /// Prepare for refresh operation
  void prepareRefresh() {
    _currentPage = 1;
    _hasMoreData = true;
    clearError();
    setStatus(DataStoreStatus.refreshing);
  }

  /// Prepare for pagination
  void preparePagination() {
    if (_hasMoreData && !isLoading) {
      _currentPage++;
      setStatus(DataStoreStatus.loading);
    }
  }

  /// Reset pagination on failure
  void resetPagination() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }

  /// Add a single item
  void addItem(T item, {bool selectAfterAdd = false, int? position}) {
    List<T> updatedItems = List.from(_items);

    if (position != null && position >= 0 && position <= updatedItems.length) {
      updatedItems.insert(position, item);
    } else {
      updatedItems.add(item);
    }

    _items = updatedItems;

    if (selectAfterAdd) {
      _selectedItem = item;
    }

    if (_status == DataStoreStatus.empty) {
      setStatus(DataStoreStatus.loaded);
    } else {
      notifyListeners();
    }
  }

  /// Update an existing item
  void updateItem(T item, bool Function(T current) finder) {
    final index = _items.indexWhere(finder);
    if (index != -1) {
      List<T> updatedItems = List.from(_items);
      updatedItems[index] = item;
      _items = updatedItems;

      // Update selected item if it matches
      if (_selectedItem != null && finder(_selectedItem!)) {
        _selectedItem = item;
      }

      notifyListeners();
    }
  }

  /// Remove an item
  void removeItem(bool Function(T item) finder) {
    final existingIndex = _items.indexWhere(finder);

    if (existingIndex != -1) {
      List<T> updatedItems = List.from(_items)..removeAt(existingIndex);
      _items = updatedItems;

      // Clear selection if the removed item was selected
      if (_selectedItem != null && finder(_selectedItem!)) {
        _selectedItem = null;
      }

      if (_items.isEmpty) {
        setStatus(DataStoreStatus.empty);
      } else {
        notifyListeners();
      }
    }
  }

  /// Check if cache is expired
  bool isCacheExpired(Duration duration) {
    return !_isCached || _lastUpdated == null ||
        DateTime.now().difference(_lastUpdated!) > duration;
  }

  /// Invalidate cache
  void invalidateCache() {
    _isCached = false;
    _lastUpdated = null;
  }

  /// Reset store to initial state
  @override
  void reset() {
    _items = [];
    _selectedItem = null;
    _currentPage = 1;
    _totalPages = 1;
    _hasMoreData = true;
    _error = null;
    _isCached = false;
    _lastUpdated = null;
    setStatus(DataStoreStatus.initial);
  }

  /// Clear data but maintain state
  void clear() {
    _items = [];
    _selectedItem = null;
    setStatus(DataStoreStatus.empty);
  }
}