
import 'package:flutter/cupertino.dart';

import 'data_store_status.dart';
import 'operation_failure.dart';


/// Base interface for all data stores
abstract class IDataStore extends ChangeNotifier {
  DataStoreStatus get status;
  OperationFailure? get error;
  bool get isInitial;
  bool get isLoading;
  bool get isLoaded;
  bool get isError;
  bool get isRefreshing;
  bool get isUpdating;

  void setStatus(DataStoreStatus status);
  void setError(OperationFailure failure);
  void clearError();
  void reset();
}