// Configuration Class
class SearchConfig {
  final int maxRecentSearches;
  final int resultsPerPage;
  final Duration debounceDuration;

const  SearchConfig({
    this.maxRecentSearches = 10,
    this.resultsPerPage = 20,
    this.debounceDuration = const Duration(milliseconds: 300),
  });
}