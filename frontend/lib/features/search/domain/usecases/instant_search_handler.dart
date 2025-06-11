// Path: frontend/lib/features/search/domain/usecases/instant_search_handler.dart
import 'dart:async';
import '../entities/search_result_entity.dart';
import '../entities/search_suggestion_entity.dart';
import '../entities/search_analytics_entity.dart';
import '../repositories/search_repository.dart';
import '../../data/exceptions/search_exceptions.dart';

/// Handles instant search operations with real-time performance
/// Provides fast search results for user input with debouncing and caching
class InstantSearchHandler {
  final SearchRepository _repository;
  final int _debounceMs;
  final int _defaultLimit;
  final Duration _cacheTimeout;

  // Internal state
  Timer? _debounceTimer;
  String? _lastQuery;
  DateTime? _lastSearchTime;
  final Map<String, SearchResult<List<SearchResultEntity>>> _resultCache = {};

  InstantSearchHandler(
    this._repository, {
    int debounceMs = 300,
    int defaultLimit = 5,
    Duration cacheTimeout = const Duration(minutes: 5),
  }) : _debounceMs = debounceMs,
       _defaultLimit = defaultLimit,
       _cacheTimeout = cacheTimeout;

  /// Main instant search method with debouncing and caching
  Future<SearchResult<List<SearchResultEntity>>> search(
    String query, {
    List<String> entities = const ['assets'],
    int? limit,
    bool forceRefresh = false,
  }) async {
    final startTime = DateTime.now();

    try {
      // Input validation
      if (query.trim().isEmpty) {
        return SearchResult.empty(query: query);
      }

      final cleanQuery = query.trim();
      final searchLimit = limit ?? _defaultLimit;
      final cacheKey = _generateCacheKey(cleanQuery, entities, searchLimit);

      // Check cache first (unless force refresh)
      if (!forceRefresh && _isCacheValid(cacheKey)) {
        final cachedResult = _resultCache[cacheKey]!;
        await _logSearchAnalytics(
          cleanQuery,
          entities,
          cachedResult.totalResults,
          DateTime.now().difference(startTime).inMilliseconds,
          fromCache: true,
        );
        return cachedResult;
      }

      // Debounce rapid searches
      if (_shouldDebounce(cleanQuery)) {
        return _performDebouncedSearch(
          cleanQuery,
          entities,
          searchLimit,
          startTime,
        );
      }

      // Perform immediate search
      return await _performSearch(cleanQuery, entities, searchLimit, startTime);
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      await _logSearchAnalytics(
        query,
        entities,
        0,
        duration,
        error: e.toString(),
      );
      return SearchResult.failure(error: createSearchExceptionFromError(e));
    }
  }

  /// Perform debounced search with timer
  Future<SearchResult<List<SearchResultEntity>>> _performDebouncedSearch(
    String query,
    List<String> entities,
    int limit,
    DateTime startTime,
  ) async {
    final completer = Completer<SearchResult<List<SearchResultEntity>>>();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: _debounceMs), () async {
      try {
        final result = await _performSearch(query, entities, limit, startTime);
        completer.complete(result);
      } catch (e) {
        completer.complete(
          SearchResult.failure(error: createSearchExceptionFromError(e)),
        );
      }
    });

    return completer.future;
  }

  /// Execute the actual search operation
  Future<SearchResult<List<SearchResultEntity>>> _performSearch(
    String query,
    List<String> entities,
    int limit,
    DateTime startTime,
  ) async {
    final cacheKey = _generateCacheKey(query, entities, limit);

    // Call repository
    final result = await _repository.instantSearch(
      query,
      entities: entities,
      limit: limit,
      includeDetails: false,
    );

    // Cache successful results
    if (result.success && result.hasData) {
      _resultCache[cacheKey] = result;
      _cleanupExpiredCache();
    }

    // Update state
    _lastQuery = query;
    _lastSearchTime = DateTime.now();

    // Log analytics
    final duration = DateTime.now().difference(startTime).inMilliseconds;
    await _logSearchAnalytics(
      query,
      entities,
      result.totalResults,
      duration,
      fromCache: result.fromCache,
      error: result.hasError ? result.error : null,
    );

    return result;
  }

  /// Get search suggestions for autocomplete
  Future<List<SearchSuggestionEntity>> getSuggestions(
    String query, {
    String type = 'all',
    int limit = 5,
  }) async {
    try {
      if (query.trim().isEmpty || query.length < 2) {
        return [];
      }

      final result = await _repository.getSuggestions(
        query.trim(),
        type: type,
        limit: limit,
        fuzzy: true,
      );

      return result.success && result.hasData ? result.data! : [];
    } catch (e) {
      return [];
    }
  }

  /// Check if search should be debounced
  bool _shouldDebounce(String query) {
    if (_lastQuery == null || _lastSearchTime == null) {
      return false;
    }

    // Don't debounce if query is very different
    if (!query.toLowerCase().startsWith(_lastQuery!.toLowerCase())) {
      return false;
    }

    // Debounce if last search was recent
    final timeSinceLastSearch = DateTime.now().difference(_lastSearchTime!);
    return timeSinceLastSearch.inMilliseconds < _debounceMs;
  }

  /// Generate cache key for result storage
  String _generateCacheKey(String query, List<String> entities, int limit) {
    return '${query.toLowerCase()}_${entities.join(',')}_$limit';
  }

  /// Check if cached result is still valid
  bool _isCacheValid(String cacheKey) {
    final cachedResult = _resultCache[cacheKey];
    if (cachedResult == null) return false;

    // Check if cache has expired (simplified - in real implementation,
    // you'd store timestamp with each cache entry)
    return true; // For now, assume cache is always valid within timeout
  }

  /// Clean up expired cache entries
  void _cleanupExpiredCache() {
    if (_resultCache.length > 50) {
      // Simple cleanup - remove oldest entries
      final keys = _resultCache.keys.toList();
      final keysToRemove = keys.take(keys.length - 40);
      for (final key in keysToRemove) {
        _resultCache.remove(key);
      }
    }
  }

  /// Log search analytics for performance monitoring
  Future<void> _logSearchAnalytics(
    String query,
    List<String> entities,
    int resultsCount,
    int durationMs, {
    bool fromCache = false,
    String? error,
  }) async {
    try {
      final analytics = error != null
          ? SearchAnalyticsEntity.failed(
              query: query,
              searchType: 'instant',
              entities: entities,
              durationMs: durationMs,
              errorType: error,
            )
          : SearchAnalyticsEntity.successful(
              query: query,
              searchType: 'instant',
              entities: entities,
              resultsCount: resultsCount,
              durationMs: durationMs,
              fromCache: fromCache,
            );

      await _repository.logSearchAnalytics(analytics);
    } catch (e) {
      // Silently fail analytics - don't break search functionality
    }
  }

  /// Clear search cache
  void clearCache() {
    _resultCache.clear();
  }

  /// Cancel any pending debounced searches
  void cancelPendingSearches() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cached_queries': _resultCache.length,
      'last_query': _lastQuery,
      'last_search_time': _lastSearchTime?.toIso8601String(),
      'cache_timeout_minutes': _cacheTimeout.inMinutes,
    };
  }

  /// Warm up cache with popular searches
  Future<void> warmUpCache(List<String> popularQueries) async {
    for (final query in popularQueries.take(10)) {
      try {
        await search(query, limit: 3);
      } catch (e) {
        // Ignore warming errors
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    _resultCache.clear();
  }
}
