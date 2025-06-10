// Path: frontend/lib/features/search/domain/repositories/search_repository.dart
import '../entities/search_result_entity.dart';
import '../entities/search_suggestion_entity.dart';
import '../entities/search_filter_entity.dart';
import '../entities/search_history_entity.dart';
import '../entities/search_analytics_entity.dart';

/// Search repository interface defining contracts for search operations
/// This is the domain layer contract that data layer must implement
abstract class SearchRepository {
  
  /// ⚡ INSTANT SEARCH OPERATIONS
  
  /// Perform instant search with fast response
  /// Returns search results for real-time search functionality
  Future<SearchResult<List<SearchResultEntity>>> instantSearch(
    String query, {
    List<String> entities = const ['assets'],
    int limit = 5,
    bool includeDetails = false,
  });

  /// Get search suggestions for autocomplete
  /// Returns suggestions based on query input
  Future<SearchResult<List<SearchSuggestionEntity>>> getSuggestions(
    String query, {
    String type = 'all',
    int limit = 5,
    bool fuzzy = false,
  });

  /// 🌐 COMPREHENSIVE SEARCH OPERATIONS
  
  /// Perform global search with pagination and filters
  /// Returns comprehensive search results with full details
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
  /// Returns detailed search results with analytics and related queries
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
  /// Returns list of recent search queries
  Future<List<String>> getRecentSearches({int limit = 10});

  /// Get popular search terms
  /// Returns list of trending/popular search queries
  Future<List<String>> getPopularSearches({int limit = 10});

  /// Clear user's search history
  /// Removes all stored search history for the current user
  Future<void> clearSearchHistory();

  /// Get detailed search history with metadata
  /// Returns comprehensive search history with filters and analytics
  Future<SearchHistoryCollectionEntity> getDetailedSearchHistory({
    int limit = 50,
    DateTime? from,
    DateTime? to,
    String? queryFilter,
  });

  /// Save search to history
  /// Records a search query for history tracking
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
  /// Records search behavior for performance analysis
  Future<void> logSearchAnalytics(SearchAnalyticsEntity analytics);

  /// Get search statistics
  /// Returns aggregated search performance metrics
  Future<SearchStatisticsEntity> getSearchStatistics({
    String period = 'week',
    String? userId,
  });

  /// Get user search behavior
  /// Returns detailed user search patterns and preferences
  Future<UserSearchBehaviorEntity> getUserSearchBehavior(String userId);

  /// 🎯 SEARCH OPTIMIZATION OPERATIONS
  
  /// Get search suggestions based on user behavior
  /// Returns personalized suggestions based on search history
  Future<List<SearchSuggestionEntity>> getPersonalizedSuggestions(
    String userId, {
    int limit = 10,
  });

  /// Get related searches for a query
  /// Returns queries similar or related to the input query
  Future<List<String>> getRelatedSearches(
    String query, {
    int limit = 5,
  });

  /// Get search recommendations
  /// Returns recommended searches based on user context
  Future<List<SearchSuggestionEntity>> getSearchRecommendations(
    String userId, {
    List<String> preferredEntities = const ['assets'],
    int limit = 10,
  });

  /// 🗂️ SEARCH FILTERING & SORTING OPERATIONS
  
  /// Get available filter options for entity type
  /// Returns possible filter values for search refinement
  Future<Map<String, List<String>>> getFilterOptions(String entityType);

  /// Validate search filters
  /// Checks if provided filters are valid for the search context
  Future<bool> validateFilters(
    SearchFilterEntity filters,
    List<String> entities,
  );

  /// Get search suggestions for filters
  /// Returns filter value suggestions based on partial input
  Future<List<String>> getFilterSuggestions(
    String filterType,
    String partialValue, {
    int limit = 10,
  });

  /// 💾 CACHE MANAGEMENT OPERATIONS
  
  /// Clear search cache
  /// Removes all cached search results and suggestions
  Future<void> clearSearchCache();

  /// Check if cache is valid for query
  /// Verifies if cached results exist and are still valid
  Future<bool> isCacheValid(String query, Map<String, String> options);

  /// Warm up cache with popular searches
  /// Pre-loads cache with frequently searched queries
  Future<void> warmUpCache(List<String> popularQueries);

  /// Invalidate specific cache entries
  /// Removes cache for specific queries or patterns
  Future<void> invalidateCache({String? query});

  /// Get cache statistics
  /// Returns cache performance metrics and storage info
  Future<Map<String, dynamic>> getCacheStats();

  /// 🔧 UTILITY OPERATIONS
  
  /// Get search configuration
  /// Returns current search system configuration
  Future<Map<String, dynamic>> getSearchConfig();

  /// Update search preferences
  /// Saves user search preferences and settings
  Future<void> updateSearchPreferences(
    String userId,
    Map<String, dynamic> preferences,
  );

  /// Get search health status
  /// Returns search system health and performance indicators
  Future<Map<String, dynamic>> getSearchHealth();

  /// Export search data
  /// Exports search history and analytics data
  Future<String> exportSearchData(
    String userId, {
    DateTime? from,
    DateTime? to,
    String format = 'json',
  });

  /// Import search data
  /// Imports search history from external data
  Future<void> importSearchData(
    String userId,
    String data,
    String format,
  });

  /// 🔍 ADVANCED SEARCH FEATURES
  
  /// Perform similarity search
  /// Finds items similar to a given reference item
  Future<SearchResult<List<SearchResultEntity>>> similaritySearch(
    String referenceId,
    String entityType, {
    int limit = 10,
    double threshold = 0.7,
  });

  /// Perform semantic search
  /// Uses AI/ML for context-aware search
  Future<SearchResult<List<SearchResultEntity>>> semanticSearch(
    String query,
    List<String> entities, {
    int limit = 20,
    String context = 'general',
  });

  /// Get search insights
  /// Returns AI-powered insights about search patterns
  Future<List<String>> getSearchInsights(String userId);

  /// Predict next search
  /// Suggests what user might search next
  Future<List<SearchSuggestionEntity>> predictNextSearch(
    String userId,
    String currentQuery,
  );

  /// 📱 MOBILE-SPECIFIC OPERATIONS
  
  /// Get offline search results
  /// Returns cached results for offline access
  Future<SearchResult<List<SearchResultEntity>>> getOfflineSearchResults(
    String query, {
    List<String> entities = const ['assets'],
  });

  /// Sync search data
  /// Synchronizes local and remote search data
  Future<void> syncSearchData(String userId);

  /// Get lightweight search results
  /// Returns minimal data for mobile/bandwidth optimization
  Future<SearchResult<List<SearchResultEntity>>> getLightweightSearch(
    String query, {
    List<String> entities = const ['assets'],
    int limit = 10,
  });

  /// 🎨 UI HELPER OPERATIONS
  
  /// Get search result templates
  /// Returns UI templates for different result types
  Future<Map<String, dynamic>> getSearchResultTemplates();

  /// Get search UI configuration
  /// Returns UI settings for search components
  Future<Map<String, dynamic>> getSearchUIConfig();

  /// Save search UI state
  /// Persists search interface state for session
  Future<void> saveSearchUIState(
    String userId,
    Map<String, dynamic> uiState,
  });

  /// Get saved search UI state
  /// Retrieves previously saved search interface state
  Future<Map<String, dynamic>?> getSavedSearchUIState(String userId);
}

/// Search operation result wrapper with additional metadata
/// Generic wrapper for all search operation results
class SearchOperationResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final SearchMetaEntity? metadata;
  final Duration? duration;

  const SearchOperationResult({
    required this.success,
    this.data,
    this.error,
    this.metadata,
    this.duration,
  });

  factory SearchOperationResult.success(T data, {SearchMetaEntity? metadata}) {
    return SearchOperationResult(
      success: true,
      data: data,
      metadata: metadata,
    );
  }

  factory SearchOperationResult.failure(String error) {
    return SearchOperationResult(
      success: false,
      error: error,
    );
  }

  bool get hasData => success && data != null;
  bool get hasError => !success || error != null;
}

/// Search repository configuration
/// Configuration options for search repository behavior
class SearchRepositoryConfig {
  final Duration cacheTimeout;
  final int maxCacheSize;
  final bool enableAnalytics;
  final bool enablePersonalization;
  final String defaultSortOrder;
  final List<String> defaultEntities;
  final Map<String, dynamic> customSettings;

  const SearchRepositoryConfig({
    this.cacheTimeout = const Duration(minutes: 5),
    this.maxCacheSize = 100,
    this.enableAnalytics = true,
    this.enablePersonalization = true,
    this.defaultSortOrder = 'relevance',
    this.defaultEntities = const ['assets'],
    this.customSettings = const {},
  });

  SearchRepositoryConfig copyWith({
    Duration? cacheTimeout,
    int? maxCacheSize,
    bool? enableAnalytics,
    bool? enablePersonalization,
    String? defaultSortOrder,
    List<String>? defaultEntities,
    Map<String, dynamic>? customSettings,
  }) {
    return SearchRepositoryConfig(
      cacheTimeout: cacheTimeout ?? this.cacheTimeout,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enablePersonalization: enablePersonalization ?? this.enablePersonalization,
      defaultSortOrder: defaultSortOrder ?? this.defaultSortOrder,
      defaultEntities: defaultEntities ?? this.defaultEntities,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}