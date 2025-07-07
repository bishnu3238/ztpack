
import 'package:flutter/foundation.dart';

import 'data_store_status.dart';
import 'i_data_store.dart';
import 'operation_failure.dart';

/// Base class for entity/model data stores
abstract class EntityStore<T> extends ChangeNotifier implements IDataStore {
  T? _entity;
  DataStoreStatus _status = DataStoreStatus.initial;
  OperationFailure? _error;
  DateTime? _lastUpdated;
  bool _isCached = false;

  EntityStore({
    T? initialEntity,
    DataStoreStatus status = DataStoreStatus.initial,
  }) : _entity = initialEntity,
        _status = initialEntity != null ? DataStoreStatus.loaded : status;

  // Getters
  T? get entity => _entity;
  @override DataStoreStatus get status => _status;
  @override OperationFailure? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  bool get hasEntity => _entity != null;
  bool get isCached => _isCached;

  // Status checks
  @override bool get isInitial => _status == DataStoreStatus.initial;
  @override bool get isLoading => _status == DataStoreStatus.loading;
  @override bool get isLoaded => _status == DataStoreStatus.loaded;
  @override bool get isError => _status == DataStoreStatus.error;
  @override bool get isRefreshing => _status == DataStoreStatus.refreshing;
  @override bool get isUpdating => _status == DataStoreStatus.updating;

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
      // Restore previous state based on entity presence
      setStatus(_entity == null ? DataStoreStatus.initial : DataStoreStatus.loaded);
    }
  }

  /// Set entity with proper status updates
  void setEntity(T? entity) {
    _entity = entity;
    _error = null;
    _lastUpdated = DateTime.now();
    _isCached = true;

    // Update status based on entity
    setStatus(entity == null ? DataStoreStatus.empty : DataStoreStatus.loaded);
  }

  /// Update only specific fields of the entity using a transform function
  void updateEntity(T Function(T? current) transform) {
    if (_entity != null || transform(null) != null) {
      _entity = transform(_entity);
      _lastUpdated = DateTime.now();

      if (_entity == null) {
        setStatus(DataStoreStatus.empty);
      } else {
        notifyListeners();
      }
    }
  }

  /// Clear the entity
  void clearEntity() {
    if (_entity != null) {
      _entity = null;
      setStatus(DataStoreStatus.empty);
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
    _entity = null;
    _error = null;
    _isCached = false;
    _lastUpdated = null;
    setStatus(DataStoreStatus.initial);
  }
}
