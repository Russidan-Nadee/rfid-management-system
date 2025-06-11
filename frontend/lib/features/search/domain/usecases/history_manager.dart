// Path: frontend/lib/features/search/domain/usecases/history_manager.dart
import 'dart:async';
import '../entities/search_history_entity.dart';
import '../entities/search_filter_entity.dart';
import '../repositories/search_repository.dart';

/// Manages search history operations and analytics
/// Provides comprehensive history tracking, analysis, and management
class HistoryManager {
  final SearchRepository _repository;
  final int _maxHistoryItems;
  final Duration _historyRetentionPeriod;

  // Local cache for recent operations
  final List<SearchHistoryEntity> _recentHistory = [];
  final Map<String, int> _queryFrequency = {};
  Timer? _cleanupTimer;

  HistoryManager(
    this._repository, {
    int maxHistoryItems = 500,
    Duration historyRetentionPeriod = const Duration(days: 90),
  }) : _maxHistoryItems = maxHistoryItems,
       _historyRetentionPeriod = historyRetentionPeriod {
    _startPeriodicCleanup();
  }

  /// Save search to history
  Future<void> saveSearch({
    required String query,
    required String searchType,
    required List<String> entities,
    required int resultsCount,
    String? userId,
    bool wasSuccessful = true,
    SearchFilterEntity? filters,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Create history entity
      final historyEntity = SearchHistoryEntity.create(
        query: query,
        searchType: searchType,
        entities: entities,
        resultsCount: resultsCount,
        userId: userId,
        wasSuccessful: wasSuccessful,
        filters: _convertFiltersToMap(filters),
      );

      // Save to repository
      await _repository.saveSearchToHistory(
        query,
        searchType: searchType,
        entities: entities,
        resultsCount: resultsCount,
        wasSuccessful: wasSuccessful,
        filters: _convertFiltersToMap(filters),
      );

      // Update local cache
      _updateLocalCache(historyEntity);

      // Update frequency tracking
      _updateQueryFrequency(query);
    } catch (e) {
      // Log error but don't throw - history saving shouldn't break search
      print('Failed to save search history: $e');
    }
  }

  /// Get search history with optional filtering
  Future<SearchHistoryCollectionEntity> getHistory({
    String? userId,
    int? limit,
    DateTime? from,
    DateTime? to,
    String? queryFilter,
    String? entityType,
    bool successfulOnly = false,
  }) async {
    try {
      final detailedHistory = await _repository.getDetailedSearchHistory(
        limit: limit ?? 50,
        from: from,
        to: to,
        queryFilter: queryFilter,
      );

      // Apply additional filters
      var filteredHistory = detailedHistory.items;

      if (entityType != null) {
        filteredHistory = filteredHistory
            .where((item) => item.entities.contains(entityType))
            .toList();
      }

      if (successfulOnly) {
        filteredHistory = filteredHistory
            .where((item) => item.wasSuccessful)
            .toList();
      }

      return SearchHistoryCollectionEntity.fromList(filteredHistory);
    } catch (e) {
      return SearchHistoryCollectionEntity.empty();
    }
  }

  /// Get recent searches as simple strings
  Future<List<String>> getRecentSearchQueries({
    int limit = 10,
    String? userId,
  }) async {
    try {
      return await _repository.getRecentSearches(limit: limit);
    } catch (e) {
      // Fallback to local cache
      return _recentHistory.take(limit).map((item) => item.query).toList();
    }
  }

  /// Get frequent searches with analytics
  Future<List<FrequentQueryEntity>> getFrequentSearches({
    int limit = 10,
    int minSearchCount = 2,
    int daysPeriod = 30,
  }) async {
    try {
      final from = DateTime.now().subtract(Duration(days: daysPeriod));
      final history = await getHistory(from: from, limit: 1000);

      return history.frequentQueries
          .where((query) => query.frequency >= minSearchCount)
          .take(limit)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get search patterns and insights
  Future<Map<String, dynamic>> getSearchPatterns({
    String? userId,
    int daysPeriod = 30,
  }) async {
    try {
      final from = DateTime.now().subtract(Duration(days: daysPeriod));
      final history = await getHistory(from: from, limit: 1000);

      return {
        'total_searches': history.totalCount,
        'unique_queries': history.uniqueQueries.length,
        'success_rate': history.successRate,
        'avg_results_per_search': history.avgResultsPerSearch,
        'search_patterns_by_hour': history.searchPatternsByHour,
        'search_patterns_by_weekday': history.searchPatternsByWeekday,
        'top_queries': history.frequentQueries
            .take(10)
            .map(
              (q) => {
                'query': q.query,
                'frequency': q.frequency,
                'popularity': q.popularityDescription,
              },
            )
            .toList(),
        'entity_distribution': _calculateEntityDistribution(history.items),
        'search_type_distribution': _calculateSearchTypeDistribution(
          history.items,
        ),
      };
    } catch (e) {
      return {};
    }
  }

  /// Clear search history
  Future<void> clearHistory({
    String? userId,
    DateTime? olderThan,
    bool clearRemoteOnly = false,
  }) async {
    try {
      if (olderThan != null) {
        // Clear history older than specified date
        await _clearHistoryOlderThan(olderThan, userId);
      } else {
        // Clear all history
        await _repository.clearSearchHistory();
      }

      if (!clearRemoteOnly) {
        _clearLocalCache();
      }
    } catch (e) {
      throw Exception('Failed to clear search history: $e');
    }
  }

  /// Delete specific search from history
  Future<void> deleteSearch(String searchId) async {
    try {
      // Remove from local cache
      _recentHistory.removeWhere((item) => item.id == searchId);

      // In a real implementation, would call repository method
      // await _repository.deleteSearchFromHistory(searchId);
    } catch (e) {
      throw Exception('Failed to delete search: $e');
    }
  }

  /// Get search suggestions based on history
  Future<List<String>> getHistoryBasedSuggestions(
    String partialQuery, {
    int limit = 5,
    String? userId,
  }) async {
    try {
      final recentQueries = await getRecentSearchQueries(limit: limit * 2);

      return recentQueries
          .where(
            (query) =>
                query.toLowerCase().contains(partialQuery.toLowerCase()) &&
                query.toLowerCase() != partialQuery.toLowerCase(),
          )
          .take(limit)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Export search history
  Future<Map<String, dynamic>> exportHistory({
    String? userId,
    DateTime? from,
    DateTime? to,
    String format = 'json',
  }) async {
    try {
      final history = await getHistory(
        userId: userId,
        from: from,
        to: to,
        limit: null, // Get all
      );

      final exportData = {
        'exported_at': DateTime.now().toIso8601String(),
        'user_id': userId,
        'period': {
          'from': from?.toIso8601String(),
          'to': to?.toIso8601String(),
        },
        'total_items': history.totalCount,
        'history': history.items
            .map(
              (item) => {
                'id': item.id,
                'query': item.query,
                'search_type': item.searchType,
                'entities': item.entities,
                'results_count': item.resultsCount,
                'timestamp': item.timestamp.toIso8601String(),
                'was_successful': item.wasSuccessful,
                'filters': item.filters,
                'click_through_count': item.clickThroughCount,
              },
            )
            .toList(),
        'statistics': await getSearchPatterns(userId: userId),
      };

      return exportData;
    } catch (e) {
      return {'error': 'Failed to export history: $e'};
    }
  }

  /// Import search history
  Future<void> importHistory(
    Map<String, dynamic> historyData, {
    String? userId,
    bool mergeWithExisting = true,
  }) async {
    try {
      final historyItems = historyData['history'] as List<dynamic>?;
      if (historyItems == null) {
        throw Exception('Invalid history data format');
      }

      if (!mergeWithExisting) {
        await clearHistory(userId: userId);
      }

      for (final itemData in historyItems) {
        final item = itemData as Map<String, dynamic>;

        await saveSearch(
          query: item['query'] ?? '',
          searchType: item['search_type'] ?? 'unknown',
          entities: List<String>.from(item['entities'] ?? ['assets']),
          resultsCount: item['results_count'] ?? 0,
          userId: userId,
          wasSuccessful: item['was_successful'] ?? true,
          filters: _parseFiltersFromMap(item['filters']),
        );
      }
    } catch (e) {
      throw Exception('Failed to import history: $e');
    }
  }

  /// Get history statistics
  Map<String, dynamic> getLocalStatistics() {
    return {
      'local_cache_size': _recentHistory.length,
      'tracked_queries': _queryFrequency.length,
      'most_frequent_query': _getMostFrequentQuery(),
      'cache_memory_estimate_kb': _recentHistory.length * 2, // Rough estimate
    };
  }

  /// Private helper methods

  void _updateLocalCache(SearchHistoryEntity historyEntity) {
    _recentHistory.insert(0, historyEntity);

    // Keep cache size under limit
    if (_recentHistory.length > _maxHistoryItems) {
      _recentHistory.removeRange(_maxHistoryItems, _recentHistory.length);
    }
  }

  void _updateQueryFrequency(String query) {
    final normalizedQuery = query.toLowerCase().trim();
    _queryFrequency[normalizedQuery] =
        (_queryFrequency[normalizedQuery] ?? 0) + 1;
  }

  void _clearLocalCache() {
    _recentHistory.clear();
    _queryFrequency.clear();
  }

  String? _getMostFrequentQuery() {
    if (_queryFrequency.isEmpty) return null;

    return _queryFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  Map<String, dynamic>? _convertFiltersToMap(SearchFilterEntity? filters) {
    if (filters == null || !filters.hasFilters) return null;

    return {
      'plant_codes': filters.plantCodes,
      'location_codes': filters.locationCodes,
      'status': filters.status,
      'roles': filters.roles,
      'date_range': filters.dateRange?.description,
      'active_filter_count': filters.activeFilterCount,
    };
  }

  SearchFilterEntity? _parseFiltersFromMap(Map<String, dynamic>? filtersMap) {
    if (filtersMap == null) return null;

    return SearchFilterEntity(
      plantCodes: filtersMap['plant_codes'] != null
          ? List<String>.from(filtersMap['plant_codes'])
          : null,
      locationCodes: filtersMap['location_codes'] != null
          ? List<String>.from(filtersMap['location_codes'])
          : null,
      status: filtersMap['status'] != null
          ? List<String>.from(filtersMap['status'])
          : null,
      roles: filtersMap['roles'] != null
          ? List<String>.from(filtersMap['roles'])
          : null,
    );
  }

  Map<String, int> _calculateEntityDistribution(
    List<SearchHistoryEntity> items,
  ) {
    final distribution = <String, int>{};

    for (final item in items) {
      for (final entity in item.entities) {
        distribution[entity] = (distribution[entity] ?? 0) + 1;
      }
    }

    return distribution;
  }

  Map<String, int> _calculateSearchTypeDistribution(
    List<SearchHistoryEntity> items,
  ) {
    final distribution = <String, int>{};

    for (final item in items) {
      distribution[item.searchType] = (distribution[item.searchType] ?? 0) + 1;
    }

    return distribution;
  }

  Future<void> _clearHistoryOlderThan(
    DateTime cutoffDate,
    String? userId,
  ) async {
    // In a real implementation, would call repository method
    // await _repository.clearHistoryOlderThan(cutoffDate, userId);

    // For now, just clear local cache of old items
    _recentHistory.removeWhere((item) => item.timestamp.isBefore(cutoffDate));
  }

  void _startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 24), (_) {
      _performPeriodicCleanup();
    });
  }

  void _performPeriodicCleanup() {
    final cutoffDate = DateTime.now().subtract(_historyRetentionPeriod);

    // Clean up local cache
    _recentHistory.removeWhere((item) => item.timestamp.isBefore(cutoffDate));

    // Clean up frequency tracking for old queries
    if (_queryFrequency.length > 1000) {
      final sortedQueries = _queryFrequency.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      final queriesToRemove = sortedQueries.take(100).map((e) => e.key);
      for (final query in queriesToRemove) {
        _queryFrequency.remove(query);
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _clearLocalCache();
  }
}
