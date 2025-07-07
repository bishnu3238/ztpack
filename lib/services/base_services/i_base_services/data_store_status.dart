
/// Base data store status to track different states
enum DataStoreStatus {
  initial,
  loading,
  loaded,
  error,
  empty,
  refreshing,
  updating,
}