// Path: frontend/lib/features/search/domain/repositories/search_repository.dart
import '../entities/search_result_entity.dart';
import '../entities/search_suggestion_entity.dart';
import '../entities/search_filter_entity.dart';
import '../entities/search_history_entity.dart';
import '../entities/search_analytics_entity.dart';

/// Search repository interface defining contracts for search operations
abstract class SearchRepository {
  /// ⚡ INSTANT SEARCH OPERATIONS

  /// Perform instant search with fast response
  Future<SearchResult<List<SearchResultEntity>>> instantSearch(
    String query, {
    List<String> entities = const ['assets'],
    int limit = 5,
    bool includeDetails = false,
  });

  /// Get search suggestions for autocomplete
  Future<SearchResult<List<SearchSuggestionEntity>>> getSuggestions(
    String query, {
    String type = 'all',
    int limit = 5,
    bool fuzzy = false,
  });

  /// 🌐 COMPREHENSIVE SEARCH OPERATIONS

  /// Perform global search with pagination and filters
  Future<SearchResult<List<SearchResultEntity>>> globalSearch(
    String query, {
    List<String> entities = const ['assets'],
    int page = 1,
    int limit = 20,
    String sort = 'relevance',
    SearchFilterEntity? filters,
    bool exactMatch = false,
  });

  /// Perform advanced search with complex options
  Future<SearchResult<List<SearchResultEntity>>> advancedSearch(
    String query, {
    List<String> entities = const ['assets'],
    int page = 1,
    int limit = 20,
    String sort = 'relevance',
    SearchFilterEntity? filters,
    bool exactMatch = false,
    bool includeAnalytics = true,
    bool includeRelated = true,
    bool highlightMatches = true,
  });

  /// 📜 SEARCH HISTORY OPERATIONS

  /// Get user's recent search history
  Future<List<String>> getRecentSearches({int limit = 10});

  /// Get popular search terms
  Future<List<String>> getPopularSearches({int limit = 10});

  /// Clear user's search history
  Future<void> clearSearchHistory();

  /// Get detailed search history with metadata
  Future<SearchHistoryCollectionEntity> getDetailedSearchHistory({
    int limit = 50,
    DateTime? from,
    DateTime? to,
    String? queryFilter,
  });

  /// Save search to history
  Future<void> saveSearchToHistory(
    String query, {
    String searchType = 'instant',
    List<String> entities = const ['assets'],
    int resultsCount = 0,
    bool wasSuccessful = true,
    Map<String, dynamic>? filters,
  });

  /// 📊 SEARCH ANALYTICS OPERATIONS

  /// Log search analytics
  Future<void> logSearchAnalytics(SearchAnalyticsEntity analytics);

  /// Get search statistics
  Future<SearchStatisticsEntity> getSearchStatistics({
    String period = 'week',
    String? userId,
  });

  /// Get user search behavior
  Future<UserSearchBehaviorEntity> getUserSearchBehavior(String userId);

  /// 🎯 SEARCH OPTIMIZATION OPERATIONS

  /// Get search suggestions based on user behavior
  Future<List<SearchSuggestionEntity>> getPersonalizedSuggestions(
    String userId, {
    int limit = 10,
  });

  /// Get related searches for a query
  Future<List<String>> getRelatedSearches(String query, {int limit = 5});

  /// Get search recommendations
  Future<List<SearchSuggestionEntity>> getSearchRecommendations(
    String userId, {
    List<String> preferredEntities = const ['assets'],
    int limit = 10,
  });

  /// 🗂️ SEARCH FILTERING & SORTING OPERATIONS

  /// Get available filter options for entity type
  Future<Map<String, List<String>>> getFilterOptions(String entityType);

  /// Validate search filters
  Future<bool> validateFilters(
    SearchFilterEntity filters,
    List<String> entities,
  );

  /// Get search suggestions for filters
  Future<List<String>> getFilterSuggestions(
    String filterType,
    String partialValue, {
    int limit = 10,
  });

  /// 💾 CACHE MANAGEMENT OPERATIONS

  /// Clear search cache
  Future<void> clearSearchCache();

  /// Check if cache is valid for query
  Future<bool> isCacheValid(String query, Map<String, String> options);

  /// Warm up cache with popular searches
  Future<void> warmUpCache(List<String> popularQueries);

  /// Invalidate specific cache entries
  Future<void> invalidateCache({String? query});

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats();

  /// 🔧 UTILITY OPERATIONS

  /// Get search configuration
  Future<Map<String, dynamic>> getSearchConfig();

  /// Update search preferences
  Future<void> updateSearchPreferences(
    String userId,
    Map<String, dynamic> preferences,
  );

  /// Get search health status
  Future<Map<String, dynamic>> getSearchHealth();

  /// Export search data
  Future<String> exportSearchData(
    String userId, {
    DateTime? from,
    DateTime? to,
    String format = 'json',
  });

  /// Import search data
  Future<void> importSearchData(String userId, String data, String format);
}
