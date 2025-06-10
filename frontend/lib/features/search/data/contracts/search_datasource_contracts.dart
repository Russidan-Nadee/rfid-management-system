// Path: frontend/lib/features/search/data/contracts/search_datasource_contracts.dart
import '../models/search_result_model.dart';
import '../models/search_suggestion_model.dart';
import '../models/search_filter_model.dart';
import '../models/search_response_model.dart';

/// Remote API data source interface
abstract class SearchRemoteDataSource {
  /// Instant search - fast response for real-time search
  /// Matches backend: GET /api/v1/search/instant
  Future<SearchResponseModel> instantSearch(
    String query, {
    List<String> entities = const ['assets'],
    int limit = 5,
    bool includeDetails = false,
  });

  /// Get search suggestions/autocomplete
  /// Matches backend: GET /api/v1/search/suggestions
  Future<List<SearchSuggestionModel>> getSuggestions(
    String query, {
    String type = 'all',
    int limit = 5,
    bool fuzzy = false,
  });

  /// Global search with pagination and filters
  /// Matches backend: GET /api/v1/search/global
  Future<SearchResponseModel> globalSearch(
    String query, {
    List<String> entities = const ['assets'],
    int page = 1,
    int limit = 20,
    String sort = 'relevance',
    SearchFilterModel? filters,
    bool exactMatch = false,
  });

  /// Advanced search with complex options
  /// Matches backend: GET /api/v1/search/advanced
  Future<SearchResponseModel> advancedSearch(
    String query, {
    List<String> entities = const ['assets'],
    int page = 1,
    int limit = 20,
    String sort = 'relevance',
    SearchFilterModel? filters,
    bool exactMatch = false,
    bool includeAnalytics = true,
    bool includeRelated = true,
    bool highlightMatches = true,
  });

  /// Get user's recent searches
  /// Matches backend: GET /api/v1/search/recent
  Future<List<String>> getRecentSearches({int limit = 10, int days = 30});

  /// Get popular search terms
  /// Matches backend: GET /api/v1/search/popular
  Future<List<String>> getPopularSearches({int limit = 10, int days = 7});

  /// Clear user's search history
  /// Matches backend: DELETE /api/v1/search/recent
  Future<void> clearSearchHistory();
}

/// Cache data source interface
abstract class SearchCacheDataSource {
  /// Cache search results
  Future<void> cacheSearchResults(
    String cacheKey,
    SearchResponseModel results, {
    Duration? ttl,
  });

  /// Get cached search results
  Future<SearchResponseModel?> getCachedSearchResults(String cacheKey);

  /// Cache search suggestions
  Future<void> cacheSuggestions(
    String query,
    List<SearchSuggestionModel> suggestions, {
    Duration? ttl,
  });

  /// Get cached suggestions
  Future<List<SearchSuggestionModel>?> getCachedSuggestions(String query);

  /// Save search query to local history
  Future<void> saveSearchToHistory(String query);

  /// Get local search history
  Future<List<String>> getSearchHistory({int limit = 10});

  /// Clear local search history
  Future<void> clearLocalSearchHistory();

  /// Save popular searches for offline access
  Future<void> cachePopularSearches(List<String> searches);

  /// Get cached popular searches
  Future<List<String>?> getCachedPopularSearches();

  /// Check if cache key exists and is valid
  Future<bool> isCacheValid(String cacheKey);

  /// Clear expired cache entries
  Future<void> clearExpiredCache();

  /// Clear all search cache
  Future<void> clearAllCache();

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats();
}

/// Search analytics interface (for tracking)
abstract class SearchAnalyticsDataSource {
  /// Log search activity
  Future<void> logSearchActivity({
    required String query,
    required String searchType,
    required List<String> entities,
    required int resultsCount,
    required int durationMs,
    String? userId,
  });

  /// Log search suggestion usage
  Future<void> logSuggestionUsage({
    required String query,
    required String selectedSuggestion,
    required int suggestionIndex,
  });

  /// Log search filter usage
  Future<void> logFilterUsage({
    required Map<String, dynamic> filters,
    required int resultsCount,
  });

  /// Get search performance metrics
  Future<Map<String, dynamic>> getSearchMetrics({int days = 7});
}

/// Combined contract for dependency injection
abstract class SearchDataSourceContracts {
  SearchRemoteDataSource get remote;
  SearchCacheDataSource get cache;
  SearchAnalyticsDataSource get analytics;
}
