import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:collection';
import 'package:pack/services/failure/failure.dart';

/// Enum representing different loading states for a data store
enum LoadingEver {
  idle,
  loading,
  refreshing,
  paginating,
  processing,
  error,
  empty,
  success
}

/// Interface for data entities that can be uniquely identified
abstract class Identifiable {
  String get id;
}

/// Class representing store operation result
class StoreResult<T> {
  final bool success;
  final T? data;
  final NetworkFailure? error;
  final String? message;
  final Map<String, dynamic>? metadata;

  StoreResult({
    this.success = true,
    this.data,
    this.error,
    this.message,
    this.metadata,
  });

  bool get isSuccess => success && error == null;
  bool get isError => !success || error != null;

  StoreResult<R> map<R>(R Function(T? data) mapper) {
    return StoreResult<R>(
      success: success,
      data: data != null ? mapper(data) : null,
      error: error,
      message: message,
      metadata: metadata,
    );
  }

  factory StoreResult.success(T? data, {String? message, Map<String, dynamic>? metadata}) {
    return StoreResult(
      success: true,
      data: data,
      message: message,
      metadata: metadata,
    );
  }

  factory StoreResult.error(NetworkFailure error, {String? message, Map<String, dynamic>? metadata}) {
    return StoreResult(
      success: false,
      error: error,
      message: message ?? error.message,
      metadata: metadata,
    );
  }
}

/// Configuration options for DataStore
class DataStoreConfig {
  final int pageSize;
  final bool enablePagination;
  final bool autoInitialize;
  final Duration refreshThrottle;
  final Duration cacheDuration;
  final bool optimisticUpdates;
  final bool trackAnalytics;
  final bool trackHistory;
  final int maxHistoryItems;
  final bool debugMode;

  const DataStoreConfig({
    this.pageSize = 10,
    this.enablePagination = true,
    this.autoInitialize = true,
    this.refreshThrottle = const Duration(seconds: 3),
    this.cacheDuration = const Duration(minutes: 15),
    this.optimisticUpdates = true,
    this.trackAnalytics = true,
    this.trackHistory = false,
    this.maxHistoryItems = 50,
    this.debugMode = false,
  });
}

/// A feature-rich abstract data store class that can be extended by specific stores
abstract class AdvancedDataStore<T> extends ChangeNotifier {
  // Core data
  List<T> _items = [];
  LoadingEver _loadingState = LoadingEver.idle;
  NetworkFailure? _error;
  T? _selectedItem;

  // Pagination
  int _currentPage = 1;
  int _pageSize;
  bool _hasMoreData = true;
  bool _isPaginationEnabled;
  DateTime? _lastPageFetch;

  // State tracking
  bool _isInitialized = false;
  DateTime? _lastUpdated;
  DateTime? _lastInitialized;
  Map<String, dynamic> _metadata = {};
  final List<T> _recentlyAddedItems = [];
  Completer<void>? _pendingOperation;

  // Configuration
  final DataStoreConfig _config;

  // History tracking
  final ListQueue<Map<String, dynamic>> _operationHistory = ListQueue<Map<String, dynamic>>();

  // Analytics
  int _totalFetchCount = 0;
  int _errorCount = 0;
  int _successCount = 0;
  Map<String, int> _operationCounts = {};
  List<NetworkFailure> _errorHistory = [];
  Stopwatch? _operationTimer;
  Map<String, List<int>> _operationTiming = {};

  // Transaction support
  bool _inTransaction = false;
  List<Function> _transactionOperations = [];

  /// Constructor with optional initial values and configuration
  AdvancedDataStore({
    List<T>? initialItems,
    LoadingEver loadingState = LoadingEver.idle,
    NetworkFailure? error,
    T? selectedItem,
    DataStoreConfig? config,
  })  : _items = initialItems ?? [],
        _loadingState = loadingState,
        _error = error,
        _selectedItem = selectedItem,
        _config = config ?? const DataStoreConfig(),
        _pageSize = config?.pageSize ?? 10,
        _isPaginationEnabled = config?.enablePagination ?? true {
    _initializeStore();
  }

  // MARK: - Core getters
  List<T> get items => UnmodifiableListView(_items);
  LoadingEver get loadingState => _loadingState;
  bool get isLoading => _loadingState == LoadingEver.loading ||
      _loadingState == LoadingEver.refreshing ||
      _loadingState == LoadingEver.paginating;
  bool get isRefreshing => _loadingState == LoadingEver.refreshing;
  NetworkFailure? get error => _error;
  T? get selectedItem => _selectedItem;
  bool get hasItems => _items.isNotEmpty;
  bool get hasError => _error != null;
  bool get hasSelected => _selectedItem != null;
  bool get hasMoreData => _hasMoreData && _isPaginationEnabled;
  bool get isInitialized => _isInitialized;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get isPaginationEnabled => _isPaginationEnabled;
  DateTime? get lastUpdated => _lastUpdated;
  DateTime? get lastInitialized => _lastInitialized;
  Map<String, dynamic> get metadata => Map.unmodifiable(_metadata);
  List<T> get recentlyAddedItems => UnmodifiableListView(_recentlyAddedItems);
  bool get isOperationPending => _pendingOperation != null && !_pendingOperation!.isCompleted;
  bool get isEmpty => _items.isEmpty;
  bool get inTransaction => _inTransaction;
  DataStoreConfig get config => _config;

  // MARK: - Analytics getters
  int get totalFetchCount => _totalFetchCount;
  int get errorCount => _errorCount;
  int get successCount => _successCount;
  double get successRate => _totalFetchCount > 0 ? ((_totalFetchCount - _errorCount) / _totalFetchCount) * 100 : 0.0;
  List<Map<String, dynamic>> get operationHistory => _config.trackHistory ? List.unmodifiable(_operationHistory) : [];
  List<NetworkFailure> get errorHistory => _config.trackAnalytics ? List.unmodifiable(_errorHistory) : [];
  Map<String, List<int>> get operationTiming => _config.trackAnalytics ? Map.unmodifiable(_operationTiming) : {};
  Map<String, double> get averageOperationTiming {
    final result = <String, double>{};
    if (!_config.trackAnalytics) return result;
    _operationTiming.forEach((key, timings) {
      if (timings.isNotEmpty) {
        result[key] = timings.reduce((a, b) => a + b) / timings.length;
      }
    });
    return result;
  }

  // MARK: - Initialization and configuration
  void _initializeStore() {
    if (_config.autoInitialize && !_isInitialized) {
      initialize();
    }
  }

  void togglePagination(bool enable) {
    if (_isPaginationEnabled != enable) {
      _isPaginationEnabled = enable;
      notifyListeners();
    }
  }

  void setPageSize(int size) {
    if (size > 0 && _pageSize != size) {
      _pageSize = size;
      if (_isPaginationEnabled) {
        _currentPage = 1;
        _hasMoreData = true;
      }
      notifyListeners();
    }
  }

  void setLoadingState(LoadingEver state) {
    if (_loadingState != state) {
      _loadingState = state;
      notifyListeners();
    }
  }

  void setError(NetworkFailure? failure, {bool notify = true}) {
    _error = failure;
    if (failure != null) {
      _loadingState = LoadingEver.error;
      _errorCount++;
      if (_config.trackAnalytics) {
        _errorHistory.add(failure);
      }
      _logOperation('error', {
        'timestamp': DateTime.now().toIso8601String(),
        'error': failure.message,
        'code': failure.code,
      });
    }
    if (notify) notifyListeners();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      if (_loadingState == LoadingEver.error) {
        _loadingState = hasItems ? LoadingEver.success : LoadingEver.empty;
      }
      notifyListeners();
    }
  }

  void setMetadata(Map<String, dynamic> metadata) {
    _metadata = Map.from(metadata);
    notifyListeners();
  }

  void updateMetadata(Map<String, dynamic> updates) {
    _metadata.addAll(updates);
    notifyListeners();
  }

  // MARK: - Item operations
  void setItems(List<T> newItems, {bool append = false, bool updateLastUpdated = true, Map<String, dynamic>? metadata, bool notify = true}) {
    if (append) {
      if (newItems.isNotEmpty) _items.addAll(newItems);
    } else {
      _items = List.from(newItems);
    }
    _error = null;
    _loadingState = _items.isEmpty ? LoadingEver.empty : LoadingEver.success;
    _isInitialized = true;
    if (_isPaginationEnabled && newItems.length < _pageSize) _hasMoreData = false;
    if (updateLastUpdated) _lastUpdated = DateTime.now();
    if (metadata != null) _metadata = Map.from(metadata);
    _logOperation('setItems', {'count': newItems.length, 'append': append, 'timestamp': DateTime.now().toIso8601String()});
    if (notify) notifyListeners();
  }

  void selectItem(T item) {
    if (_selectedItem != item) {
      _selectedItem = item;
      notifyListeners();
    }
  }

  bool selectWhere(bool Function(T item) predicate) {
    final index = _items.indexWhere(predicate);
    if (index != -1) {
      selectItem(_items[index]);
      return true;
    }
    return false;
  }

  void clearSelection() {
    if (_selectedItem != null) {
      _selectedItem = null;
      notifyListeners();
    }
  }

  void trackRecentlyAdded(T item, {int? maxItems}) {
    final limit = maxItems ?? 5;
    _recentlyAddedItems.insert(0, item);
    if (_recentlyAddedItems.length > limit) _recentlyAddedItems.removeLast();
  }

  void clearRecentlyAdded() {
    if (_recentlyAddedItems.isNotEmpty) {
      _recentlyAddedItems.clear();
      notifyListeners();
    }
  }

  T? getItemAt(int index) => (index >= 0 && index < _items.length) ? _items[index] : null;
  T? findItem(bool Function(T item) predicate) => _items.firstWhere(predicate, orElse: () => null as T);
  List<T> findItems(bool Function(T item) predicate) => _items.where(predicate).toList();
  int countWhere(bool Function(T item) predicate) => _items.where(predicate).length;

  // MARK: - Data fetching and refreshing
  Future<StoreResult<List<T>>> refresh() async {
    if (_loadingState == LoadingEver.refreshing) return StoreResult.error(NetworkFailure(message: 'Refresh in progress'));
    final timer = _startOperationTimer('refresh');
    _loadingState = LoadingEver.refreshing;
    _error = null;
    if (_isPaginationEnabled) {
      _currentPage = 1;
      _hasMoreData = true;
    }
    notifyListeners();
    try {
      _totalFetchCount++;
      final result = await fetchData();
      if (result.isSuccess) _successCount++;
      _stopOperationTimer(timer, 'refresh');
      return result;
    } catch (e) {
      _stopOperationTimer(timer, 'refresh');
      final failure = e is NetworkFailure ? e : NetworkFailure(message: e.toString());
      setError(failure, notify: false);
      return StoreResult.error(failure);
    } finally {
      _loadingState = _items.isEmpty ? LoadingEver.empty : LoadingEver.success;
      notifyListeners();
    }
  }

  Future<StoreResult<List<T>>> loadMore() async {
    if (!_isPaginationEnabled) return StoreResult.error(NetworkFailure(message: 'Pagination disabled'));
    if (!_hasMoreData) return StoreResult.error(NetworkFailure(message: 'No more data'));
    if (_loadingState == LoadingEver.paginating) return StoreResult.error(NetworkFailure(message: 'Pagination in progress'));
    if (_lastPageFetch != null && DateTime.now().difference(_lastPageFetch!) < const Duration(milliseconds: 300)) {
      return StoreResult.error(NetworkFailure(message: 'Pagination throttled'));
    }
    final timer = _startOperationTimer('pagination');
    _currentPage++;
    _loadingState = LoadingEver.paginating;
    _lastPageFetch = DateTime.now();
    notifyListeners();
    try {
      _totalFetchCount++;
      final result = await fetchData(page: _currentPage, append: true);
      if (result.isSuccess) _successCount++;
      _stopOperationTimer(timer, 'pagination');
      return result;
    } catch (e) {
      _stopOperationTimer(timer, 'pagination');
      _currentPage--;
      final failure = e is NetworkFailure ? e : NetworkFailure(message: e.toString());
      setError(failure, notify: false);
      return StoreResult.error(failure);
    } finally {
      _loadingState = _items.isEmpty ? LoadingEver.empty : LoadingEver.success;
      notifyListeners();
    }
  }

  Future<StoreResult<List<T>>> initialize() async {
    if (_isInitialized || _loadingState == LoadingEver.loading) return StoreResult.error(NetworkFailure(message: 'Already initialized'));
    final timer = _startOperationTimer('initialize');
    _loadingState = LoadingEver.loading;
    _lastInitialized = DateTime.now();
    notifyListeners();
    try {
      final result = await refresh();
      _isInitialized = true;
      _stopOperationTimer(timer, 'initialize');
      return result;
    } catch (e) {
      _stopOperationTimer(timer, 'initialize');
      final failure = e is NetworkFailure ? e : NetworkFailure(message: e.toString());
      setError(failure, notify: false);
      return StoreResult.error(failure);
    }
  }

  Future<StoreResult<List<T>>> fetchData({int? page, bool append = false});

  Future<StoreResult<R>> safeOperation<R>(Future<StoreResult<R>> Function() operation, {String operationName = 'operation'}) async {
    final timer = _startOperationTimer(operationName);
    try {
      final result = await operation();
      if (result.isSuccess) {
        _successCount++;
        _logOperation(operationName, {'success': true, 'timestamp': DateTime.now().toIso8601String()});
      } else {
        _errorCount++;
        if (result.error != null && _config.trackAnalytics) _errorHistory.add(result.error!);
        _logOperation(operationName, {'success': false, 'error': result.message ?? 'Unknown error', 'timestamp': DateTime.now().toIso8601String()});
      }
      _stopOperationTimer(timer, operationName);
      return result;
    } catch (e) {
      _stopOperationTimer(timer, operationName);
      final failure = e is NetworkFailure ? e : NetworkFailure(message: e.toString());
      _errorCount++;
      if (_config.trackAnalytics) _errorHistory.add(failure);
      _logOperation(operationName, {'success': false, 'error': failure.message, 'timestamp': DateTime.now().toIso8601String()});
      return StoreResult.error(failure);
    }
  }

  // MARK: - Item manipulation methods
  void updateItem(T item, bool Function(T current) finder, {bool notify = true}) {
    final index = _items.indexWhere(finder);
    if (index != -1) {
      final newList = List<T>.from(_items);
      newList[index] = item;
      _items = newList;
      if (_selectedItem != null && finder(_selectedItem!)) _selectedItem = item;
      _logOperation('updateItem', {'index': index, 'timestamp': DateTime.now().toIso8601String()});
      if (notify) notifyListeners();
    }
  }

  void updateItemAt(int index, T item, {bool notify = true}) {
    if (index >= 0 && index < _items.length) {
      final newList = List<T>.from(_items);
      newList[index] = item;
      _items = newList;
      _logOperation('updateItemAt', {'index': index, 'timestamp': DateTime.now().toIso8601String()});
      if (notify) notifyListeners();
    }
  }

  void batchUpdateItems(List<T> updatedItems, bool Function(T item, T updatedItem) matcher, {bool notify = true}) {
    bool madeChanges = false;
    final newList = List<T>.from(_items);
    for (final updatedItem in updatedItems) {
      final index = newList.indexWhere((item) => matcher(item, updatedItem));
      if (index != -1) {
        newList[index] = updatedItem;
        madeChanges = true;
        if (_selectedItem != null && matcher(_selectedItem!, updatedItem)) _selectedItem = updatedItem;
      }
    }
    if (madeChanges) {
      _items = newList;
      _logOperation('batchUpdateItems', {'count': updatedItems.length, 'timestamp': DateTime.now().toIso8601String()});
      if (notify) notifyListeners();
    }
  }

  void addItem(T item, {bool selectAfterAdd = false, bool trackAsRecent = true, bool notify = true}) {
    _items = [..._items, item];
    if (selectAfterAdd) _selectedItem = item;
    if (trackAsRecent) trackRecentlyAdded(item);
    _logOperation('addItem', {'timestamp': DateTime.now().toIso8601String()});
    _loadingState = LoadingEver.success;
    if (notify) notifyListeners();
  }

  void prependItem(T item, {bool selectAfterAdd = false, bool trackAsRecent = true, bool notify = true}) {
    _items = [item, ..._items];
    if (selectAfterAdd) _selectedItem = item;
    if (trackAsRecent) trackRecentlyAdded(item);
    _loadingState = LoadingEver.success;
    _logOperation('prependItem', {'timestamp': DateTime.now().toIso8601String()});
    if (notify) notifyListeners();
  }

  void addItems(List<T> newItems, {bool prepend = false, bool trackAsRecent = false, bool notify = true}) {
    if (newItems.isEmpty) return;
    if (prepend) {
      _items = [...newItems, ..._items];
    } else {
      _items = [..._items, ...newItems];
    }
    if (trackAsRecent) for (final item in newItems) trackRecentlyAdded(item);
    _loadingState = LoadingEver.success;
    _logOperation('addItems', {'count': newItems.length, 'prepend': prepend, 'timestamp': DateTime.now().toIso8601String()});
    if (notify) notifyListeners();
  }

  void removeItem(bool Function(T item) finder, {bool notify = true}) {
    final existingIndex = _items.indexWhere(finder);
    if (existingIndex != -1) {
      final newList = List<T>.from(_items);
      newList.removeAt(existingIndex);
      _items = newList;
      if (_selectedItem != null && finder(_selectedItem!)) _selectedItem = null;
      _logOperation('removeItem', {'index': existingIndex, 'timestamp': DateTime.now().toIso8601String()});
      if (_items.isEmpty) _loadingState = LoadingEver.empty;
      if (notify) notifyListeners();
    }
  }

  void removeItemAt(int index, {bool notify = true}) {
    if (index >= 0 && index < _items.length) {
      final item = _items[index];
      final newList = List<T>.from(_items);
      newList.removeAt(index);
      _items = newList;
      if (_selectedItem == item) _selectedItem = null;
      _logOperation('removeItemAt', {'index': index, 'timestamp': DateTime.now().toIso8601String()});
      if (_items.isEmpty) _loadingState = LoadingEver.empty;
      if (notify) notifyListeners();
    }
  }

  void removeItems(bool Function(T item) filter, {bool notify = true}) {
    final newList = _items.where((item) => !filter(item)).toList();
    if (newList.length != _items.length) {
      _items = newList;
      if (_selectedItem != null && filter(_selectedItem!)) _selectedItem = null;
      _logOperation('removeItems', {'count': _items.length - newList.length, 'timestamp': DateTime.now().toIso8601String()});
      if (_items.isEmpty) _loadingState = LoadingEver.empty;
      if (notify) notifyListeners();
    }
  }

  void swapItems(int oldIndex, int newIndex, {bool notify = true}) {
    if (oldIndex < 0 || oldIndex >= _items.length || newIndex < 0 || newIndex >= _items.length) return;
    final newList = List<T>.from(_items);
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    _items = newList;
    _logOperation('swapItems', {'oldIndex': oldIndex, 'newIndex': newIndex, 'timestamp': DateTime.now().toIso8601String()});
    if (notify) notifyListeners();
  }

  void moveItem(int fromIndex, int toIndex, {bool notify = true}) {
    if (fromIndex == toIndex || fromIndex < 0 || fromIndex >= _items.length || toIndex < 0 || toIndex >= _items.length) return;
    final newList = List<T>.from(_items);
    final item = newList.removeAt(fromIndex);
    newList.insert(toIndex, item);
    _items = newList;
    _logOperation('moveItem', {'fromIndex': fromIndex, 'toIndex': toIndex, 'timestamp': DateTime.now().toIso8601String()});
    if (notify) notifyListeners();
  }

  void reorderItems(int Function(T a, T b) comparator, {bool notify = true}) {
    final newList = List<T>.from(_items);
    newList.sort(comparator);
    _items = newList;
    _logOperation('reorderItems', {'timestamp': DateTime.now().toIso8601String()});
    if (notify) notifyListeners();
  }

  // MARK: - Transaction support
  void beginTransaction() {
    if (_inTransaction) throw StateError('A transaction is already in progress');
    _inTransaction = true;
    _transactionOperations = [];
  }

  void commitTransaction() {
    if (!_inTransaction) throw StateError('No transaction in progress');
    for (final operation in _transactionOperations) {
      operation();
    }
    _inTransaction = false;
    _transactionOperations.clear();
    _logOperation('commitTransaction', {'operations': _transactionOperations.length, 'timestamp': DateTime.now().toIso8601String()});
    notifyListeners();
  }

  void rollbackTransaction() {
    if (!_inTransaction) throw StateError('No transaction in progress');
    _inTransaction = false;
    _transactionOperations.clear();
    _logOperation('rollbackTransaction', {'timestamp': DateTime.now().toIso8601String()});
    notifyListeners();
  }

  void addTransactionOperation(Function operation) {
    if (!_inTransaction) throw StateError('No transaction in progress');
    _transactionOperations.add(operation);
  }

  // MARK: - Analytics and Logging
  Stopwatch _startOperationTimer(String operationName) {
    final timer = Stopwatch()..start();
    _operationTimer = timer;
    return timer;
  }

  void _stopOperationTimer(Stopwatch timer, String operationName) {
    timer.stop();
    if (_config.trackAnalytics) {
      _operationTiming.putIfAbsent(operationName, () => []).add(timer.elapsedMilliseconds);
    }
  }

  void _logOperation(String operationName, Map<String, dynamic> details) {
    if (_config.debugMode) dev.log('[$operationName] $details');
    if (_config.trackHistory) {
      _operationHistory.add({'operation': operationName, 'details': details});
      while (_operationHistory.length > _config.maxHistoryItems) {
        _operationHistory.removeFirst();
      }
    }
    _operationCounts.update(operationName, (count) => count + 1, ifAbsent: () => 1);
  }

  // MARK: - Cleanup
  void clear() {
    _items.clear();
    _selectedItem = null;
    _recentlyAddedItems.clear();
    _currentPage = 1;
    _hasMoreData = true;
    _error = null;
    _loadingState = LoadingEver.empty;
    _isInitialized = false;
    _metadata.clear();
    _logOperation('clear', {'timestamp': DateTime.now().toIso8601String()});
    notifyListeners();
  }

  @override
  void dispose() {
    _pendingOperation?.complete();
    _operationTimer?.stop();
    super.dispose();
  }
}