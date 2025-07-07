import '../data_store_status.dart';
import '../i_data_store.dart';
import '../operation_failure.dart';
import '../store_coordinator.dart';

/// Flexible interface for repositories that can define their own operations
abstract class IRepository {
  // Base interface only requires identification
  String get repositoryName;
}


/// Repository that works with multiple stores
abstract class IMultiStoreRepository implements IRepository {
  // Get the StoreCoordinator instance
  StoreCoordinator get storeCoordinator;

  // Utility to update a specific store
  void updateStore<T extends IDataStore>(
    String key,
    void Function(T store) updater,
  ) {
    final store = storeCoordinator.getStoreAs<T>(key);
    if (store != null) {
      updater(store);
    }
  }
}
