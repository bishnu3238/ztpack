import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../core/models/search_config.dart';
import '../core/models/search_failure.dart';
import '../core/models/searchable.dart';
import '../repository/search_repository.dart';
import '../storage/recent_search_storage.dart';
import 'package:dartz/dartz.dart';

/// Main search state management class
class SearchProvider extends ChangeNotifier {
  // Dependencies
  final SearchRepository _repository;
  final RecentSearchStorage _recentSearchStorage;
  final SearchConfig _config;
  final Logger _logger = Logger();

  // State variables
  String _query = '';
  bool _isLoading = false;
  bool _showSuggestions = false;
  bool _isLoadingMore = false;
  bool _isFocused = false;
  Either<SearchFailure, List<Searchable>> _searchResult = Right([]);
  List<Searchable> _suggestions = [];
  List<String> _recentSearches = [];
  Timer? _debounceTimer;

  // Getters
  String get query => _query;
  bool get isLoading => _isLoading;
  bool get isFocused => _isFocused;
  bool get isLoadingMore => _isLoadingMore;
  bool get showSuggestions => _showSuggestions && _query.isNotEmpty;
  List<String> get recentSearches => _recentSearches;
  List<Searchable> get suggestions => _suggestions;

  Either<SearchFailure, List<Searchable>> get searchResult => _searchResult;

  // Constructor
  SearchProvider({
    required SearchRepository repository,
    required RecentSearchStorage recentSearchStorage,
    SearchConfig config = const SearchConfig(),
  }) : _repository = repository,
       _recentSearchStorage = recentSearchStorage,
       _config = config {
    _loadRecentSearches();
  }


  // Add method to update focus state
  void setFocus(bool focused) {
    _isFocused = focused;
    notifyListeners();
  }

  // Initialize recent searches
  Future<void> _loadRecentSearches() async {
    try {
      final searches = await _recentSearchStorage.getRecentSearches();
      _recentSearches = searches;
      notifyListeners();
    } catch (e) {
      // Fallback to empty list if storage fails
      _logger.e('Failed to load recent searches', error: e);
      _recentSearches = [];
      notifyListeners();
    }
  }

  // Handle search query changes
  void onQueryChanged(String query) {
    _query = query;

    // Cancel previous timer
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    // Show suggestions while typing
    if (query.isNotEmpty) {
      _showSuggestions = true;
      // Debounce search/suggestions
      _debounceTimer = Timer(_config.debounceDuration, () {
        _fetchSuggestions();
      });
    } else {
      _showSuggestions = false;
      _suggestions = [];
      // Clear search results when query is empty
      _searchResult = Right([]);
      notifyListeners();
    }
  }

  // Search with current query
  Future<void> search() async {
    if (_query.isEmpty) return;

    _showSuggestions = false;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.search(_query);
      _searchResult = result;

      // Add to recent searches if search was successful
      if (result.isRight()) {
        await _addToRecentSearches(_query);
      }
    } catch (e) {
      _logger.e('Search failed',error: e);
      _searchResult = Left(
        SearchFailure(message: 'An unexpected error occurred',exception:  e as Exception?),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch suggestions based on query
  Future<void> _fetchSuggestions() async {
    if (_query.isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }

    try {
      final suggestions = await _repository.getSuggestions(_query);
      _suggestions = suggestions.getOrElse(() => []);
    } catch (e) {
      _logger.w('Failed to fetch suggestions',error:  e);
      _suggestions = [];
    }

    notifyListeners();
  }

  // Use a recent search
  void useRecentSearch(String query) {
    _query = query;
    search();
  }

  // Clear search query
  void clearSearch() {
    _query = '';
    _showSuggestions = false;
    _suggestions = [];
    _searchResult = Right([]);
    notifyListeners();
  }

  // Add to recent searches
  Future<void> _addToRecentSearches(String query) async {
    try {
      await _recentSearchStorage.addRecentSearch(query);
      await _loadRecentSearches();
    } catch (e) {
      // Handle storage error silently
      _logger.e('Failed to add recent search', error: e);
      notifyListeners();
    }
  }

  // Clear all recent searches
  Future<void> clearRecentSearches() async {
    try {
      await _recentSearchStorage.clearRecentSearches();
      _recentSearches = [];
      notifyListeners();
    } catch (e) {
      // Handle storage error
      _logger.e('Failed to clear recent searches', error: e);
    }
  }

  // Load more results (for pagination)
  Future<void> loadMoreResults() async {
    if (_isLoadingMore) return;

    final currentResults = _searchResult.getOrElse(() => []);
    if (currentResults.isEmpty) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final moreResults = await _repository.loadMoreResults(_query);

      moreResults.fold(
        (failure) {
          // If error, keep current results
        },
        (newResults) {
          _searchResult = Right([...currentResults, ...newResults]);
        },
      );
    } catch (e) {
      // Keep current results on error
      _logger.w('Failed to load more results', error: e);
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
