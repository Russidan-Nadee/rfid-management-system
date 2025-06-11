// Path: frontend/lib/features/search/domain/usecases/suggestion_builder.dart
import 'dart:async';
import '../entities/search_suggestion_entity.dart';
import '../repositories/search_repository.dart';
import 'ranking_calculator.dart';

/// Builds intelligent search suggestions from multiple sources
/// Combines entity data, history, and popular searches for optimal UX
class SuggestionBuilder {
  final SearchRepository _repository;
  final RankingCalculator _rankingCalculator;
  final int _defaultLimit;
  final Duration _cacheTimeout;

  // Internal cache
  final Map<String, List<SearchSuggestionEntity>> _suggestionsCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  SuggestionBuilder(
    this._repository,
    this._rankingCalculator, {
    int defaultLimit = 8,
    Duration cacheTimeout = const Duration(minutes: 10),
  }) : _defaultLimit = defaultLimit,
       _cacheTimeout = cacheTimeout;

  /// Build comprehensive suggestions for query
  Future<List<SearchSuggestionEntity>> buildSuggestions(
    String query, {
    int? limit,
    List<String> entities = const ['assets'],
    String? userId,
  }) async {
    final searchLimit = limit ?? _defaultLimit;

    try {
      // Return empty for very short queries
      if (query.trim().length < 2) {
        return await _getDefaultSuggestions(searchLimit);
      }

      final cacheKey = _generateCacheKey(query, entities, searchLimit);

      // Check cache first
      if (_isCacheValid(cacheKey)) {
        return _suggestionsCache[cacheKey]!;
      }

      // Build suggestions from multiple sources
      final suggestions = await _buildFromMultipleSources(
        query,
        entities,
        searchLimit,
        userId,
      );

      // Cache the results
      _cacheResults(cacheKey, suggestions);

      return suggestions;
    } catch (e) {
      // Fallback to basic suggestions on error
      return await _getFallbackSuggestions(query, searchLimit);
    }
  }

  /// Build suggestions from multiple sources and rank them
  Future<List<SearchSuggestionEntity>> _buildFromMultipleSources(
    String query,
    List<String> entities,
    int limit,
    String? userId,
  ) async {
    final futures = <String, Future<List<SearchSuggestionEntity>>>{};

    // Source 1: Entity-based suggestions
    futures['entity'] = _getEntitySuggestions(query, entities, limit);

    // Source 2: Recent search history
    futures['recent'] = _getRecentSuggestions(query, limit);

    // Source 3: Popular searches
    futures['popular'] = _getPopularSuggestions(query, limit);

    // Source 4: Personalized suggestions (if user provided)
    if (userId != null) {
      futures['personalized'] = _getPersonalizedSuggestions(
        query,
        userId,
        limit,
      );
    }

    // Execute all sources in parallel
    final results = <String, List<SearchSuggestionEntity>>{};
    await Future.wait(
      futures.entries.map((entry) async {
        try {
          results[entry.key] = await entry.value;
        } catch (e) {
          results[entry.key] = [];
        }
      }),
    );

    // Combine and rank suggestions
    return _rankingCalculator.combineAndRankSuggestions(results, query, limit);
  }

  /// Get entity-based suggestions from repository
  Future<List<SearchSuggestionEntity>> _getEntitySuggestions(
    String query,
    List<String> entities,
    int limit,
  ) async {
    try {
      final result = await _repository.getSuggestions(
        query,
        type: 'all',
        limit: limit * 2, // Get more to allow for filtering
      );

      if (!result.success || !result.hasData) {
        return [];
      }

      // Filter by requested entities
      return result.data!
          .where(
            (suggestion) =>
                entities.contains(suggestion.entity) ||
                suggestion.entity == null,
          )
          .take(limit)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get suggestions from recent search history
  Future<List<SearchSuggestionEntity>> _getRecentSuggestions(
    String query,
    int limit,
  ) async {
    try {
      final recentSearches = await _repository.getRecentSearches(
        limit: limit * 2,
      );

      return recentSearches
          .where(
            (search) =>
                search.toLowerCase().contains(query.toLowerCase()) &&
                search.toLowerCase() != query.toLowerCase(),
          )
          .take(limit)
          .map(
            (search) => SearchSuggestionEntity.recent(
              query: search,
              lastSearched: DateTime.now().subtract(
                Duration(hours: recentSearches.indexOf(search)),
              ),
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get suggestions from popular searches
  Future<List<SearchSuggestionEntity>> _getPopularSuggestions(
    String query,
    int limit,
  ) async {
    try {
      final popularSearches = await _repository.getPopularSearches(
        limit: limit * 2,
      );

      return popularSearches
          .where(
            (search) =>
                search.toLowerCase().contains(query.toLowerCase()) &&
                search.toLowerCase() != query.toLowerCase(),
          )
          .take(limit)
          .map(
            (search) => SearchSuggestionEntity.popular(
              query: search,
              searchCount: 100 - (popularSearches.indexOf(search) * 10),
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get personalized suggestions for user
  Future<List<SearchSuggestionEntity>> _getPersonalizedSuggestions(
    String query,
    String userId,
    int limit,
  ) async {
    try {
      return await _repository.getPersonalizedSuggestions(userId, limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Get default suggestions when query is empty/short
  Future<List<SearchSuggestionEntity>> _getDefaultSuggestions(int limit) async {
    try {
      final popular = await _repository.getPopularSearches(limit: limit);

      return popular
          .map(
            (search) =>
                SearchSuggestionEntity.popular(query: search, searchCount: 100),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get fallback suggestions on error
  Future<List<SearchSuggestionEntity>> _getFallbackSuggestions(
    String query,
    int limit,
  ) async {
    // Return simple suggestions based on query patterns
    final suggestions = <SearchSuggestionEntity>[];

    // Asset code pattern suggestions
    if (RegExp(r'^[A-Z0-9]{1,6}$').hasMatch(query.toUpperCase())) {
      suggestions.add(
        SearchSuggestionEntity.asset(
          value: query.toUpperCase(),
          type: 'asset_no',
          description: 'Search by asset number',
        ),
      );
    }

    // Plant/Location pattern suggestions
    if (RegExp(r'^[A-Z0-9]{1,4}$').hasMatch(query.toUpperCase())) {
      suggestions.add(
        SearchSuggestionEntity.plant(
          plantCode: query.toUpperCase(),
          description: 'Search by plant code',
        ),
      );
    }

    return suggestions.take(limit).toList();
  }

  /// Build contextual suggestions based on current search context
  Future<List<SearchSuggestionEntity>> buildContextualSuggestions(
    String query,
    Map<String, dynamic> context, {
    int limit = 5,
  }) async {
    final suggestions = <SearchSuggestionEntity>[];

    try {
      // Current entity context
      if (context['current_entity'] != null) {
        final entitySuggestions = await _getEntitySuggestions(query, [
          context['current_entity'],
        ], limit);
        suggestions.addAll(entitySuggestions);
      }

      // Location context
      if (context['current_plant'] != null) {
        final locationSuggestions = await _getLocationBasedSuggestions(
          query,
          context['current_plant'],
          limit,
        );
        suggestions.addAll(locationSuggestions);
      }

      // Recent context
      if (context['recent_queries'] != null) {
        final recentContext = context['recent_queries'] as List<String>;
        final contextualSuggestions = _generateContextualSuggestions(
          query,
          recentContext,
          limit,
        );
        suggestions.addAll(contextualSuggestions);
      }

      // Rank and deduplicate
      return _rankingCalculator
          .rankSuggestions(suggestions, query: query)
          .take(limit)
          .toList();
    } catch (e) {
      return suggestions.take(limit).toList();
    }
  }

  /// Get location-based suggestions
  Future<List<SearchSuggestionEntity>> _getLocationBasedSuggestions(
    String query,
    String plantCode,
    int limit,
  ) async {
    try {
      // This would typically call repository with location filters
      // For now, return empty as it depends on specific implementation
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Generate suggestions based on recent query patterns
  List<SearchSuggestionEntity> _generateContextualSuggestions(
    String query,
    List<String> recentQueries,
    int limit,
  ) {
    final suggestions = <SearchSuggestionEntity>[];

    for (final recentQuery in recentQueries.take(limit)) {
      if (recentQuery.toLowerCase().contains(query.toLowerCase()) &&
          recentQuery.toLowerCase() != query.toLowerCase()) {
        suggestions.add(
          SearchSuggestionEntity.recent(
            query: recentQuery,
            lastSearched: DateTime.now(),
          ),
        );
      }
    }

    return suggestions;
  }

  /// Cache management methods
  String _generateCacheKey(String query, List<String> entities, int limit) {
    return '${query.toLowerCase()}_${entities.join(',')}_$limit';
  }

  bool _isCacheValid(String cacheKey) {
    if (!_suggestionsCache.containsKey(cacheKey)) return false;

    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheTimeout;
  }

  void _cacheResults(
    String cacheKey,
    List<SearchSuggestionEntity> suggestions,
  ) {
    _suggestionsCache[cacheKey] = suggestions;
    _cacheTimestamps[cacheKey] = DateTime.now();

    // Clean up old cache entries
    _cleanupCache();
  }

  void _cleanupCache() {
    if (_suggestionsCache.length > 100) {
      final oldestKeys = _cacheTimestamps.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      final keysToRemove = oldestKeys.take(20).map((e) => e.key);
      for (final key in keysToRemove) {
        _suggestionsCache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }
  }

  /// Clear all cached suggestions
  void clearCache() {
    _suggestionsCache.clear();
    _cacheTimestamps.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final validCacheCount = _cacheTimestamps.entries
        .where(
          (entry) => DateTime.now().difference(entry.value) < _cacheTimeout,
        )
        .length;

    return {
      'total_cached': _suggestionsCache.length,
      'valid_cached': validCacheCount,
      'cache_timeout_minutes': _cacheTimeout.inMinutes,
      'cache_hit_rate': validCacheCount / _suggestionsCache.length,
    };
  }

  /// Dispose resources
  void dispose() {
    _suggestionsCache.clear();
    _cacheTimestamps.clear();
  }
}
