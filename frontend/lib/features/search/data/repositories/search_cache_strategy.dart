// Path: frontend/lib/features/search/data/repositories/search_cache_strategy.dart
import 'package:tp_rfid/features/search/data/models/search_suggestion_model.dart';

import '../contracts/search_datasource_contracts.dart';
import '../models/search_response_model.dart';

/// Search cache strategy for managing cache policies and optimization
class SearchCacheStrategy {
  final SearchCacheDataSource cacheDataSource;

  // Cache configuration
  static const Duration _instantSearchTtl = Duration(minutes: 5);
  static const Duration _globalSearchTtl = Duration(minutes: 10);
  static const Duration _suggestionsTtl = Duration(minutes: 15);
  static const Duration _popularSearchesTtl = Duration(hours: 6);

  // Cache priorities
  static const int _maxInstantCacheSize = 50;
  static const int _maxGlobalCacheSize = 30;
  static const int _maxSuggestionsCacheSize = 100;

  // Performance thresholds
  static const int _fastSearchThreshold = 200; // ms
  static const int _slowSearchThreshold = 1000; // ms

  SearchCacheStrategy(this.cacheDataSource);

  /// Generate cache key for search requests
  String generateCacheKey(
    String searchType,
    String query,
    Map<String, String> options,
  ) {
    final cleanQuery = _sanitizeQuery(query);
    final sortedOptions = Map.fromEntries(
      options.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    final keyParts = [
      searchType,
      cleanQuery,
      ...sortedOptions.entries.map((e) => '${e.key}:${e.value}'),
    ];

    final keyString = keyParts.join('|');
    return _hashKey(keyString);
  }

  /// Cache search results with appropriate TTL
  Future<void> cacheSearchResults(
    String cacheKey,
    SearchResponseModel results, {
    String searchType = 'instant',
  }) async {
    try {
      final ttl = _getTtlForSearchType(searchType);

      // Check if results are worth caching
      if (_shouldCacheResults(results, searchType)) {
        await cacheDataSource.cacheSearchResults(cacheKey, results, ttl: ttl);
      }
    } catch (e) {
      // Don't fail the search if caching fails
      print('Cache storage failed: $e');
    }
  }

  /// Cache suggestions with optimized TTL
  Future<void> cacheSuggestions(String query, List<dynamic> suggestions) async {
    try {
      if (suggestions.isNotEmpty && query.length >= 2) {
        // Convert to suggestion models if needed
        final suggestionModels = suggestions
            .map(
              (s) => s is Map<String, dynamic>
                  ? SearchSuggestionModel.fromJson(s)
                  : s as SearchSuggestionModel,
            )
            .toList();

        await cacheDataSource.cacheSuggestions(
          query,
          suggestionModels,
          ttl: _suggestionsTtl,
        );
      }
    } catch (e) {
      print('Suggestions cache failed: $e');
    }
  }

  /// Determine cache priority based on search patterns
  CachePriority determineCachePriority(
    String query,
    String searchType,
    Map<String, dynamic>? metadata,
  ) {
    // High priority for short, common queries
    if (query.length <= 3) {
      return CachePriority.high;
    }

    // Medium priority for instant searches
    if (searchType == 'instant') {
      return CachePriority.medium;
    }

    // Low priority for complex searches with filters
    if (metadata != null && metadata.containsKey('filters')) {
      return CachePriority.low;
    }

    return CachePriority.medium;
  }

  /// Adaptive cache TTL based on query characteristics
  Duration getAdaptiveTtl(
    String query,
    String searchType,
    int? resultsCount,
    int? searchDurationMs,
  ) {
    var baseTtl = _getTtlForSearchType(searchType);

    // Extend TTL for popular queries
    if (query.length <= 5 && resultsCount != null && resultsCount > 0) {
      baseTtl = Duration(milliseconds: (baseTtl.inMilliseconds * 1.5).round());
    }

    // Reduce TTL for slow searches (they might be complex/dynamic)
    if (searchDurationMs != null && searchDurationMs > _slowSearchThreshold) {
      baseTtl = Duration(milliseconds: (baseTtl.inMilliseconds * 0.5).round());
    }

    // Extend TTL for fast searches (they're likely to be stable)
    if (searchDurationMs != null && searchDurationMs < _fastSearchThreshold) {
      baseTtl = Duration(milliseconds: (baseTtl.inMilliseconds * 1.2).round());
    }

    return baseTtl;
  }

  /// Cache warming strategy for popular searches
  Future<void> warmUpCacheWithPopularSearches(
    List<String> popularQueries,
  ) async {
    for (final query in popularQueries.take(10)) {
      try {
        // Pre-cache suggestions
        await cacheSuggestions(query, [
          SearchSuggestionModel(value: query, type: 'popular', label: query),
        ]);
      } catch (e) {
        print('Cache warming failed for query: $query');
      }
    }
  }

  /// Cache cleanup strategy
  Future<void> performCacheCleanup() async {
    try {
      // Clear expired entries
      await cacheDataSource.clearExpiredCache();

      // Get cache stats to determine if more cleanup is needed
      final stats = await cacheDataSource.getCacheStats();
      final totalEntries = stats['total_cache_entries'] as int? ?? 0;

      // If cache is getting too large, clean up low priority items
      if (totalEntries >
          (_maxInstantCacheSize +
              _maxGlobalCacheSize +
              _maxSuggestionsCacheSize)) {
        await _cleanupLowPriorityCache();
      }
    } catch (e) {
      print('Cache cleanup failed: $e');
    }
  }

  /// Get cache statistics and performance metrics
  Map<String, dynamic> getStats() {
    return {
      'strategy': 'adaptive',
      'instant_search_ttl_minutes': _instantSearchTtl.inMinutes,
      'global_search_ttl_minutes': _globalSearchTtl.inMinutes,
      'suggestions_ttl_minutes': _suggestionsTtl.inMinutes,
      'max_instant_cache_size': _maxInstantCacheSize,
      'max_global_cache_size': _maxGlobalCacheSize,
      'max_suggestions_cache_size': _maxSuggestionsCacheSize,
      'fast_search_threshold_ms': _fastSearchThreshold,
      'slow_search_threshold_ms': _slowSearchThreshold,
    };
  }

  /// Cache invalidation strategies
  Future<void> invalidateCacheByPattern(String pattern) async {
    // This would require the cache data source to support pattern-based deletion
    // For now, we'll clear all cache
    await cacheDataSource.clearAllCache();
  }

  Future<void> invalidateCacheByEntityType(String entityType) async {
    // Invalidate cache entries related to specific entity type
    // Implementation would depend on cache key structure
    await cacheDataSource.clearAllCache();
  }

  /// Smart cache preloading
  Future<void> preloadCache(List<String> predictedQueries) async {
    for (final query in predictedQueries.take(5)) {
      if (query.length >= 2) {
        try {
          // Check if already cached
          final suggestions = await cacheDataSource.getCachedSuggestions(query);
          if (suggestions == null) {
            // Pre-cache empty suggestions to avoid unnecessary API calls
            await cacheSuggestions(query, []);
          }
        } catch (e) {
          print('Preload failed for: $query');
        }
      }
    }
  }

  /// Cache hit optimization
  String optimizeCacheKey(String originalKey, Map<String, String> context) {
    // Normalize similar queries to improve cache hit rate
    var optimizedKey = originalKey.toLowerCase().trim();

    // Remove common stopwords for better cache hits
    const stopwords = [
      'the',
      'and',
      'or',
      'but',
      'in',
      'on',
      'at',
      'to',
      'for',
    ];
    for (final stopword in stopwords) {
      optimizedKey = optimizedKey.replaceAll(' $stopword ', ' ');
    }

    // Normalize whitespace
    optimizedKey = optimizedKey.replaceAll(RegExp(r'\s+'), ' ');

    return _hashKey(optimizedKey);
  }

  /// Private helper methods

  String _sanitizeQuery(String query) {
    return query.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s-]'), '');
  }

  String _hashKey(String input) {
    // Simple hash function for cache keys
    var hash = 0;
    for (var i = 0; i < input.length; i++) {
      final char = input.codeUnitAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    return hash.abs().toString();
  }

  Duration _getTtlForSearchType(String searchType) {
    switch (searchType.toLowerCase()) {
      case 'instant':
        return _instantSearchTtl;
      case 'global':
      case 'advanced':
        return _globalSearchTtl;
      case 'suggestions':
        return _suggestionsTtl;
      case 'popular':
        return _popularSearchesTtl;
      default:
        return _instantSearchTtl;
    }
  }

  bool _shouldCacheResults(SearchResponseModel results, String searchType) {
    // Don't cache if no results
    if (!results.success || results.totalResults == 0) {
      return false;
    }

    // Don't cache error responses
    if (results.hasErrors) {
      return false;
    }

    // Always cache instant searches with results
    if (searchType == 'instant' && results.totalResults > 0) {
      return true;
    }

    // Cache global searches only if they have good results
    if (searchType == 'global' && results.totalResults >= 3) {
      return true;
    }

    // Don't cache advanced searches (too complex/dynamic)
    if (searchType == 'advanced') {
      return false;
    }

    return results.totalResults > 0;
  }

  Future<void> _cleanupLowPriorityCache() async {
    // This would require the cache data source to support priority-based cleanup
    // For now, we'll just clear expired cache
    await cacheDataSource.clearExpiredCache();
  }
}

/// Cache priority levels
enum CachePriority { high, medium, low }

/// Cache performance metrics
class CachePerformanceMetrics {
  final int hitCount;
  final int missCount;
  final int totalRequests;
  final double averageResponseTime;
  final DateTime lastUpdated;

  CachePerformanceMetrics({
    required this.hitCount,
    required this.missCount,
    required this.totalRequests,
    required this.averageResponseTime,
    required this.lastUpdated,
  });

  double get hitRate => totalRequests > 0 ? hitCount / totalRequests : 0.0;
  double get missRate => totalRequests > 0 ? missCount / totalRequests : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'hit_count': hitCount,
      'miss_count': missCount,
      'total_requests': totalRequests,
      'hit_rate': hitRate,
      'miss_rate': missRate,
      'average_response_time_ms': averageResponseTime,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

/// Cache configuration model
class CacheConfig {
  final Duration defaultTtl;
  final int maxSize;
  final bool enableCompression;
  final bool enableEncryption;
  final CachePriority defaultPriority;

  const CacheConfig({
    required this.defaultTtl,
    required this.maxSize,
    this.enableCompression = false,
    this.enableEncryption = false,
    this.defaultPriority = CachePriority.medium,
  });

  static const CacheConfig instant = CacheConfig(
    defaultTtl: Duration(minutes: 5),
    maxSize: 50,
    defaultPriority: CachePriority.high,
  );

  static const CacheConfig global = CacheConfig(
    defaultTtl: Duration(minutes: 10),
    maxSize: 30,
    defaultPriority: CachePriority.medium,
  );

  static const CacheConfig suggestions = CacheConfig(
    defaultTtl: Duration(minutes: 15),
    maxSize: 100,
    defaultPriority: CachePriority.high,
  );
}
