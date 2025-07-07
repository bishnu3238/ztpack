 import 'package:dartz/dartz.dart';

import '../core/models/search_failure.dart';
import '../core/models/searchable.dart';

/// Abstract repository for search operations
abstract class SearchRepository {
  Future<Either<SearchFailure, List<Searchable>>> search(String query);
  Future<Either<SearchFailure, List<Searchable>>> getSuggestions(String query);
  Future<Either<SearchFailure, List<Searchable>>> loadMoreResults(String query);
}