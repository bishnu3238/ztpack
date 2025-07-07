import 'package:logger/logger.dart';

import '../core/models/search_config.dart';
import 'search_data_store.dart';
import '../core/models/search_failure.dart';
import '../core/models/search_result_type.dart';
import '../core/models/searchable.dart';
import 'package:dartz/dartz.dart';

import 'search_repository.dart';

/// Implementation that fetches from various stores
class SearchRepositoryImpl implements SearchRepository {
  final List<SearchDataStore> _stores;
  final int _maxSuggestionsPerType;
  int _currentPage = 0;
  final SearchConfig _config;
  final Logger _logger = Logger();

  SearchRepositoryImpl({
    required List<SearchDataStore> stores,
    int maxSuggestionsPerType = 5,
    SearchConfig config = const SearchConfig(),
  }) : _stores = stores,
       _maxSuggestionsPerType = maxSuggestionsPerType,
       _config = config;

  @override
  Future<Either<SearchFailure, List<Searchable>>> search(String query) async {
    try {
      _currentPage = 0;
      final results = await _searchAcrossStores(query);
      return Right(results);
    } catch (e) {
      return Left(
        SearchFailure(
          message: 'Failed to perform search',
          exception: e as Exception?,
        ),
      );
    }
  }

  @override
  Future<Either<SearchFailure, List<Searchable>>> getSuggestions(
    String query,
  ) async {
    try {
      final suggestions = <Searchable>[];

      // Collect suggestions from each store
      for (final store in _stores) {
        final storeResults = await store.searchItems(query);

        // Group results by type
        final resultsByType = <SearchResultType, List<Searchable>>{};
        for (final result in storeResults) {
          resultsByType.putIfAbsent(result.resultType, () => []).add(result);
        }

        // Add limited number of suggestions per type
        for (final typeGroup in resultsByType.values) {
          suggestions.addAll(typeGroup.take(_maxSuggestionsPerType));
        }
      }

      return Right(suggestions);
    } catch (e) {
      _logger.w('Failed to get suggestions', error: e);
      return Left(
        SearchFailure(
          message: 'Failed to get suggestions',
          exception: e as Exception?,
        ),
      );
    }
  }

  @override
  Future<Either<SearchFailure, List<Searchable>>> loadMoreResults(
    String query,
  ) async {
    try {
      _currentPage++;
      final results = await _searchAcrossStores(query);
      return Right(results);
    } catch (e) {
      _logger.w('Failed to load more results', error: e);
      return Left(
        SearchFailure(
          message: 'Failed to load more results',
          exception: e as Exception?,
        ),
      );
    }
  }

  Future<List<Searchable>> _searchAcrossStores(String query) async {
    final allResults = <Searchable>[];

    // Search across all stores
    for (final store in _stores) {
      final storeResults = await store.searchItems(
        query,
        skip: _currentPage * _config.resultsPerPage,
        take: _config.resultsPerPage,
      );
      allResults.addAll(storeResults);
    }

    return allResults;
  }
}
