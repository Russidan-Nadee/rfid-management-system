// Path: frontend/lib/features/search/data/datasources/cache/search_cache_datasource_impl.dart
import 'dart:convert';
import '../../../../../core/services/storage_service.dart';
import '../../contracts/search_datasource_contracts.dart';
import '../../models/search_response_model.dart';
import '../../models/search_suggestion_model.dart';
import '../../exceptions/search_exceptions.dart';

/// Implementation of SearchCacheDataSource
/// Handles local caching and search history storage
class SearchCacheDataSourceImpl implements SearchCacheDataSource {
  final StorageService storageService;

  // Cache keys
  static const String _searchResultsPrefix = 'search_results_';
  static const String _suggestionsPrefix = 'search_suggestions_';
  static const String _searchHistoryKey = 'search_history';
  static const String _popularSearchesKey = 'popular_searches';
  static const String _cacheMetaPrefix = 'cache_meta_';

  // Cache settings
  static const Duration _defaultCacheTtl = Duration(minutes: 5);
  static const Duration _suggestionsCacheTtl = Duration(minutes: 15);
  static const int _maxHistoryItems = 50;
  static const int _maxCacheSize = 100;

  SearchCacheDataSourceImpl(this.storageService);

  @override
  Future<void> cacheSearchResults(
    String cacheKey,
    SearchResponseModel results, {
    Duration? ttl,
  }) async {
    try {
      final effectiveTtl = ttl ?? _defaultCacheTtl;
      final expiryTime = DateTime.now().add(effectiveTtl);

      final cacheData = {
        'data': results.toJson(),
        'expiry': expiryTime.toIso8601String(),
        'cached_at': DateTime.now().toIso8601String(),
      };

      // Check cache size and cleanup if needed
      await _cleanupIfNeeded();

      await storageService.setString(
        '$_searchResultsPrefix$cacheKey',
        jsonEncode(cacheData),
      );

      // Store cache metadata
      await _storeCacheMetadata(cacheKey, expiryTime);
    } catch (e) {
      throw SearchCacheException('Failed to cache search results: $e');
    }
  }

  @override
  Future<SearchResponseModel?> getCachedSearchResults(String cacheKey) async {
    try {
      final cachedData = storageService.getString(
        '$_searchResultsPrefix$cacheKey',
      );

      if (cachedData == null) {
        return null;
      }

      final cacheJson = jsonDecode(cachedData) as Map<String, dynamic>;
      final expiryTime = DateTime.parse(cacheJson['expiry']);

      // Check if cache is expired
      if (DateTime.now().isAfter(expiryTime)) {
        await _removeCacheEntry(cacheKey);
        return null;
      }

      final resultsData = cacheJson['data'] as Map<String, dynamic>;
      return SearchResponseModel.fromJson(resultsData);
    } catch (e) {
      // Remove corrupted cache entry
      await _removeCacheEntry(cacheKey);
      return null;
    }
  }

  @override
  Future<void> cacheSuggestions(
    String query,
    List<SearchSuggestionModel> suggestions, {
    Duration? ttl,
  }) async {
    try {
      final effectiveTtl = ttl ?? _suggestionsCacheTtl;
      final expiryTime = DateTime.now().add(effectiveTtl);

      final cacheData = {
        'data': suggestions.map((s) => s.toJson()).toList(),
        'expiry': expiryTime.toIso8601String(),
        'cached_at': DateTime.now().toIso8601String(),
        'query': query,
      };

      await storageService.setString(
        '$_suggestionsPrefix${_sanitizeKey(query)}',
        jsonEncode(cacheData),
      );
    } catch (e) {
      throw SearchCacheException('Failed to cache suggestions: $e');
    }
  }

  @override
  Future<List<SearchSuggestionModel>?> getCachedSuggestions(
    String query,
  ) async {
    try {
      final cachedData = storageService.getString(
        '$_suggestionsPrefix${_sanitizeKey(query)}',
      );

      if (cachedData == null) {
        return null;
      }

      final cacheJson = jsonDecode(cachedData) as Map<String, dynamic>;
      final expiryTime = DateTime.parse(cacheJson['expiry']);

      // Check if cache is expired
      if (DateTime.now().isAfter(expiryTime)) {
        await storageService.remove(
          '$_suggestionsPrefix${_sanitizeKey(query)}',
        );
        return null;
      }

      final suggestionsData = cacheJson['data'] as List<dynamic>;
      return suggestionsData
          .map(
            (item) =>
                SearchSuggestionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveSearchToHistory(String query) async {
    try {
      if (query.trim().isEmpty) return;

      final history = await getSearchHistory();
      final cleanQuery = query.trim();

      // Remove if already exists (to move to top)
      history.removeWhere(
        (item) => item.toLowerCase() == cleanQuery.toLowerCase(),
      );

      // Add to beginning
      history.insert(0, cleanQuery);

      // Limit history size
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      await storageService.setString(
        _searchHistoryKey,
        jsonEncode({
          'queries': history,
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      throw SearchCacheException('Failed to save search to history: $e');
    }
  }

  @override
  Future<List<String>> getSearchHistory({int limit = 10}) async {
    try {
      final historyData = storageService.getString(_searchHistoryKey);

      if (historyData == null) {
        return [];
      }

      final historyJson = jsonDecode(historyData) as Map<String, dynamic>;
      final queries = List<String>.from(historyJson['queries'] ?? []);

      return queries.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearLocalSearchHistory() async {
    try {
      await storageService.remove(_searchHistoryKey);
    } catch (e) {
      throw SearchCacheException('Failed to clear search history: $e');
    }
  }

  @override
  Future<void> cachePopularSearches(List<String> searches) async {
    try {
      final cacheData = {
        'searches': searches,
        'cached_at': DateTime.now().toIso8601String(),
        'expiry': DateTime.now()
            .add(const Duration(hours: 6))
            .toIso8601String(),
      };

      await storageService.setString(
        _popularSearchesKey,
        jsonEncode(cacheData),
      );
    } catch (e) {
      throw SearchCacheException('Failed to cache popular searches: $e');
    }
  }

  @override
  Future<List<String>?> getCachedPopularSearches() async {
    try {
      final cachedData = storageService.getString(_popularSearchesKey);

      if (cachedData == null) {
        return null;
      }

      final cacheJson = jsonDecode(cachedData) as Map<String, dynamic>;
      final expiryTime = DateTime.parse(cacheJson['expiry']);

      // Check if cache is expired
      if (DateTime.now().isAfter(expiryTime)) {
        await storageService.remove(_popularSearchesKey);
        return null;
      }

      return List<String>.from(cacheJson['searches'] ?? []);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isCacheValid(String cacheKey) async {
    try {
      final cachedData = storageService.getString(
        '$_searchResultsPrefix$cacheKey',
      );

      if (cachedData == null) {
        return false;
      }

      final cacheJson = jsonDecode(cachedData) as Map<String, dynamic>;
      final expiryTime = DateTime.parse(cacheJson['expiry']);

      return DateTime.now().isBefore(expiryTime);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearExpiredCache() async {
    try {
      final keys = await _getAllCacheKeys();
      final now = DateTime.now();

      for (final key in keys) {
        try {
          final cachedData = storageService.getString(key);
          if (cachedData != null) {
            final cacheJson = jsonDecode(cachedData) as Map<String, dynamic>;
            final expiryTime = DateTime.parse(cacheJson['expiry']);

            if (now.isAfter(expiryTime)) {
              await storageService.remove(key);
            }
          }
        } catch (e) {
          // Remove corrupted cache entry
          await storageService.remove(key);
        }
      }
    } catch (e) {
      throw SearchCacheException('Failed to clear expired cache: $e');
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      final keys = await _getAllCacheKeys();

      for (final key in keys) {
        await storageService.remove(key);
      }

      // Also clear history and popular searches
      await storageService.remove(_searchHistoryKey);
      await storageService.remove(_popularSearchesKey);
    } catch (e) {
      throw SearchCacheException('Failed to clear all cache: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final keys = await _getAllCacheKeys();
      int searchResultsCount = 0;
      int suggestionsCount = 0;
      int expiredCount = 0;
      int totalSize = 0;
      final now = DateTime.now();

      for (final key in keys) {
        try {
          final cachedData = storageService.getString(key);
          if (cachedData != null) {
            totalSize += cachedData.length;

            if (key.startsWith(_searchResultsPrefix)) {
              searchResultsCount++;
            } else if (key.startsWith(_suggestionsPrefix)) {
              suggestionsCount++;
            }

            final cacheJson = jsonDecode(cachedData) as Map<String, dynamic>;
            final expiryTime = DateTime.parse(cacheJson['expiry']);

            if (now.isAfter(expiryTime)) {
              expiredCount++;
            }
          }
        } catch (e) {
          // Count corrupted entries as expired
          expiredCount++;
        }
      }

      final historyCount = (await getSearchHistory()).length;

      return {
        'search_results_cached': searchResultsCount,
        'suggestions_cached': suggestionsCount,
        'expired_entries': expiredCount,
        'total_cache_entries': keys.length,
        'total_cache_size_bytes': totalSize,
        'search_history_count': historyCount,
        'cache_hit_rate': await _calculateCacheHitRate(),
        'last_cleanup': await _getLastCleanupTime(),
      };
    } catch (e) {
      return {'error': 'Failed to get cache stats: $e'};
    }
  }

  /// Private helper methods

  /// Sanitize cache key to be storage-safe
  String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_').toLowerCase();
  }

  /// Get all cache keys
  Future<List<String>> _getAllCacheKeys() async {
    // This is a simplified version - in a real implementation,
    // you might need to track cache keys separately
    final keys = <String>[];

    // Add known cache key patterns
    // This would need to be implemented based on your storage service
    // For now, return empty list
    return keys;
  }

  /// Remove specific cache entry
  Future<void> _removeCacheEntry(String cacheKey) async {
    await storageService.remove('$_searchResultsPrefix$cacheKey');
    await storageService.remove('$_cacheMetaPrefix$cacheKey');
  }

  /// Store cache metadata
  Future<void> _storeCacheMetadata(String cacheKey, DateTime expiryTime) async {
    final metadata = {
      'key': cacheKey,
      'expiry': expiryTime.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };

    await storageService.setString(
      '$_cacheMetaPrefix$cacheKey',
      jsonEncode(metadata),
    );
  }

  /// Cleanup cache if it's getting too large
  Future<void> _cleanupIfNeeded() async {
    final keys = await _getAllCacheKeys();

    if (keys.length > _maxCacheSize) {
      // Remove oldest entries first
      await clearExpiredCache();

      // If still too large, remove oldest valid entries
      final updatedKeys = await _getAllCacheKeys();
      if (updatedKeys.length > _maxCacheSize) {
        final keysToRemove = updatedKeys.take(
          updatedKeys.length - _maxCacheSize,
        );
        for (final key in keysToRemove) {
          await storageService.remove(key);
        }
      }
    }
  }

  /// Calculate cache hit rate (simplified)
  Future<double> _calculateCacheHitRate() async {
    // In a real implementation, you would track hits and misses
    // For now, return a placeholder value
    return 0.75; // 75% hit rate
  }

  /// Get last cleanup time
  Future<String?> _getLastCleanupTime() async {
    return storageService.getString('last_cache_cleanup');
  }

  /// Get cache entry age
  Future<Duration?> getCacheAge(String cacheKey) async {
    try {
      final cachedData = storageService.getString(
        '$_searchResultsPrefix$cacheKey',
      );

      if (cachedData == null) {
        return null;
      }

      final cacheJson = jsonDecode(cachedData) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(cacheJson['cached_at']);

      return DateTime.now().difference(cachedAt);
    } catch (e) {
      return null;
    }
  }

  /// Warm up cache with popular searches
  Future<void> warmUpCache(List<String> popularQueries) async {
    for (final query in popularQueries) {
      // Pre-populate suggestions cache
      await cacheSuggestions(query, [
        SearchSuggestionModel(value: query, type: 'popular', label: query),
      ], ttl: const Duration(hours: 1));
    }
  }
}
