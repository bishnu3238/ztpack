

import '../core/models/searchable.dart';

/// Abstract data store interface
abstract class SearchDataStore {
  Future<List<Searchable>> searchItems(String query, {int? skip, int? take});
  Future<List<Searchable>> getAll();
}