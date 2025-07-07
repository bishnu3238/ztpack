
import 'package:logger/logger.dart';
import 'package:pack/services/search_service/search_utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/search_config.dart';

class RecentSearchStorage {
  static const _recentSearchesKey = 'recent_searches';
  final SharedPreferences _prefs;
  final SearchConfig _config;
  final Logger _logger = Logger();

  RecentSearchStorage(this._prefs, {SearchConfig config = const SearchConfig()}) : _config = config;

  static Future<RecentSearchStorage> create({SearchConfig config = const SearchConfig()}) async {
    final prefs = await SharedPreferences.getInstance();
    return RecentSearchStorage(prefs, config: config);
  }

  Future<List<String>> getRecentSearches() async {
    try {
      return _prefs.getStringList(_recentSearchesKey) ?? [];
    } catch (e) {
      _logger.e('Failed to get recent searches', error: e);
      return [];
    }
  }

  Future<void> addRecentSearch(String query) async {
    try {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) return;

      final searches = await getRecentSearches();
      searches.remove(trimmedQuery);
      searches.insert(0, trimmedQuery);

      if (searches.length > _config.maxRecentSearches) {
        searches.removeLast();
      }

      await _prefs.setStringList(_recentSearchesKey, searches);
    } catch (e) {
      throw SearchFailure(message: 'Failed to save recent search',exception:  e as Exception?);
    }
  }

  Future<void> clearRecentSearches() async {
    try {
      await _prefs.remove(_recentSearchesKey);
    } catch (e) {
      throw SearchFailure(message: 'Failed to clear recent searches',exception:  e as Exception?);
    }
  }
}