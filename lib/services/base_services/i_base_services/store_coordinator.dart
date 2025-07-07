import 'data_store_status.dart';
import 'i_data_store.dart';
import 'operation_failure.dart';

/// Multiple-store coordinator to update related stores
class StoreCoordinator {
  final Map<String, IDataStore> _stores = {};

  void registerStore(String key, IDataStore store) {
    _stores[key] = store;
  }

  void unregisterStore(String key) {
    _stores.remove(key);
  }

  IDataStore? getStore(String key) {
    return _stores[key];
  }

  T? getStoreAs<T extends IDataStore>(String key) {
    final store = _stores[key];
    if (store is T) {
      return store;
    }
    return null;
  }

  void setLoadingOnAll() {
    for (final store in _stores.values) {
      store.setStatus(DataStoreStatus.loading);
    }
  }

  void setErrorOnAll(OperationFailure failure) {
    for (final store in _stores.values) {
      store.setError(failure);
    }
  }

  void resetAll() {
    for (final store in _stores.values) {
      store.reset();
    }
  }
}
