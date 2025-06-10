// Path: frontend/lib/features/search/domain/usecases/manage_search_history_usecase.dart
import '../entities/search_history_entity.dart';
import '../entities/search_filter_entity.dart';
import '../repositories/search_repository.dart';

/// Use case for managing search history
/// Handles all operations related to user search history tracking and management
class ManageSearchHistoryUseCase {
  final SearchRepository repository;

  // Configuration constants
  static const int _maxHistoryItems = 100;
  static const int _defaultLimit = 20;
  static const Duration _historyRetentionPeriod = Duration(days: 90);

  ManageSearchHistoryUseCase(this.repository);

  /// Get user's search history with filtering and pagination
  ///
  /// Parameters:
  /// - [userId]: User identifier (optional for anonymous users)
  /// - [limit]: Number of history items to return (default: 20)
  /// - [offset]: Number of items to skip for pagination
  /// - [from]: Start date for filtering history
  /// - [to]: End date for filtering history
  /// - [queryFilter]: Filter history by query pattern
  /// - [entityFilter]: Filter by searched entity types
  /// - [successOnly]: Only return successful searches
  ///
  /// Returns:
  /// - [SearchHistoryResult] with filtered and paginated history
  Future<SearchHistoryResult> getSearchHistory({
    String? userId,
    int limit = _defaultLimit,
    int offset = 0,
    DateTime? from,
    DateTime? to,
    String? queryFilter,
    List<String>? entityFilter,
    bool successOnly = false,
  }) async {
    try {
      // Validate input parameters
      final validation = _validateHistoryInput(limit, offset);
      if (!validation.isValid) {
        return SearchHistoryResult.invalid(validation.errorMessage!);
      }

      // Get detailed search history from repository
      final historyCollection = await repository.getDetailedSearchHistory(
        limit: limit + offset, // Get more to handle offset
        from: from,
        to: to,
        queryFilter: queryFilter,
      );

      // Apply additional filters
      var filteredHistory = historyCollection.items;

      // Filter by entity types
      if (entityFilter != null && entityFilter.isNotEmpty) {
        filteredHistory = filteredHistory.where((item) {
          return item.entities.any((entity) => entityFilter.contains(entity));
        }).toList();
      }

      // Filter by success status
      if (successOnly) {
        filteredHistory = filteredHistory
            .where((item) => item.wasSuccessful)
            .toList();
      }

      // Apply pagination manually since we may have additional filters
      final paginatedItems = filteredHistory.skip(offset).take(limit).toList();

      // Create result collection
      final resultCollection = SearchHistoryCollectionEntity.fromList(
        paginatedItems,
      );

      // Get additional metadata
      final metadata = await _getHistoryMetadata(userId, filteredHistory);

      return SearchHistoryResult.success(
        history: resultCollection,
        totalCount: filteredHistory.length,
        hasMore: filteredHistory.length > (offset + limit),
        metadata: metadata,
      );
    } catch (e) {
      return SearchHistoryResult.failure(
        error: 'Failed to get search history: ${e.toString()}',
      );
    }
  }

  /// Save a search query to history
  ///
  /// Parameters:
  /// - [query]: The search query to save
  /// - [searchType]: Type of search performed
  /// - [entities]: Entity types that were searched
  /// - [resultsCount]: Number of results returned
  /// - [wasSuccessful]: Whether the search was successful
  /// - [filters]: Any filters that were applied
  /// - [userId]: User identifier (optional)
  ///
  /// Returns:
  /// - [SaveHistoryResult] indicating success or failure
  Future<SaveHistoryResult> saveSearchToHistory({
    required String query,
    String searchType = 'instant',
    List<String> entities = const ['assets'],
    int resultsCount = 0,
    bool wasSuccessful = true,
    Map<String, dynamic>? filters,
    String? userId,
  }) async {
    try {
      // Validate input
      if (query.trim().isEmpty) {
        return SaveHistoryResult.invalid('Query cannot be empty');
      }

      if (query.length > 200) {
        return SaveHistoryResult.invalid('Query too long (max 200 characters)');
      }

      // Check if we should save this query (avoid spam)
      final shouldSave = await _shouldSaveQuery(query, userId);
      if (!shouldSave) {
        return SaveHistoryResult.skipped('Query not saved (duplicate or spam)');
      }

      // Save to repository
      await repository.saveSearchToHistory(
        query,
        searchType: searchType,
        entities: entities,
        resultsCount: resultsCount,
        wasSuccessful: wasSuccessful,
        filters: filters,
      );

      // Cleanup old history if needed
      await _cleanupOldHistory(userId);

      return SaveHistoryResult.success();
    } catch (e) {
      return SaveHistoryResult.failure(
        error: 'Failed to save search to history: ${e.toString()}',
      );
    }
  }

  /// Clear user's search history
  ///
  /// Parameters:
  /// - [userId]: User identifier (optional)
  /// - [olderThan]: Clear only items older than this date
  /// - [queryPattern]: Clear only items matching this pattern
  /// - [entityTypes]: Clear only items for these entity types
  ///
  /// Returns:
  /// - [ClearHistoryResult] indicating success or failure
  Future<ClearHistoryResult> clearSearchHistory({
    String? userId,
    DateTime? olderThan,
    String? queryPattern,
    List<String>? entityTypes,
  }) async {
    try {
      int clearedCount = 0;

      if (olderThan == null && queryPattern == null && entityTypes == null) {
        // Clear all history
        await repository.clearSearchHistory();
        clearedCount = -1; // Indicate all cleared
      } else {
        // Selective clearing - get current history first
        final currentHistory = await repository.getDetailedSearchHistory(
          limit: _maxHistoryItems * 2, // Get more to ensure we catch all
        );

        var itemsToKeep = currentHistory.items;

        // Filter out items to be cleared
        if (olderThan != null) {
          itemsToKeep = itemsToKeep
              .where((item) => item.timestamp.isAfter(olderThan))
              .toList();
        }

        if (queryPattern != null) {
          itemsToKeep = itemsToKeep
              .where(
                (item) => !item.query.toLowerCase().contains(
                  queryPattern.toLowerCase(),
                ),
              )
              .toList();
        }

        if (entityTypes != null && entityTypes.isNotEmpty) {
          itemsToKeep = itemsToKeep
              .where(
                (item) => !item.entities.any(
                  (entity) => entityTypes.contains(entity),
                ),
              )
              .toList();
        }

        clearedCount = currentHistory.items.length - itemsToKeep.length;

        // Clear all and re-save what we want to keep
        await repository.clearSearchHistory();

        for (final item in itemsToKeep) {
          await repository.saveSearchToHistory(
            item.query,
            searchType: item.searchType,
            entities: item.entities,
            resultsCount: item.resultsCount,
            wasSuccessful: item.wasSuccessful,
            filters: item.filters,
          );
        }
      }

      return ClearHistoryResult.success(clearedCount: clearedCount);
    } catch (e) {
      return ClearHistoryResult.failure(
        error: 'Failed to clear search history: ${e.toString()}',
      );
    }
  }

  /// Get search history statistics
  ///
  /// Parameters:
  /// - [userId]: User identifier (optional)
  /// - [period]: Time period for statistics (day, week, month)
  ///
  /// Returns:
  /// - [HistoryStatistics] with aggregated data
  Future<HistoryStatistics> getHistoryStatistics({
    String? userId,
    String period = 'week',
  }) async {
    try {
      // Get history for the specified period
      final DateTime fromDate;
      switch (period) {
        case 'day':
          fromDate = DateTime.now().subtract(const Duration(days: 1));
          break;
        case 'week':
          fromDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case 'month':
          fromDate = DateTime.now().subtract(const Duration(days: 30));
          break;
        default:
          fromDate = DateTime.now().subtract(const Duration(days: 7));
      }

      final historyCollection = await repository.getDetailedSearchHistory(
        from: fromDate,
        limit: 1000, // Large number to get all items in period
      );

      return _calculateHistoryStatistics(historyCollection, period);
    } catch (e) {
      return HistoryStatistics.empty();
    }
  }

  /// Get frequent queries from history
  ///
  /// Parameters:
  /// - [userId]: User identifier (optional)
  /// - [limit]: Number of frequent queries to return
  /// - [minFrequency]: Minimum frequency threshold
  ///
  /// Returns:
  /// - [List<FrequentQueryEntity>] sorted by frequency
  Future<List<FrequentQueryEntity>> getFrequentQueries({
    String? userId,
    int limit = 10,
    int minFrequency = 2,
  }) async {
    try {
      final historyCollection = await repository.getDetailedSearchHistory(
        limit: _maxHistoryItems,
      );

      final frequentQueries = historyCollection.frequentQueries
          .where((query) => query.frequency >= minFrequency)
          .take(limit)
          .toList();

      return frequentQueries;
    } catch (e) {
      return [];
    }
  }

  /// Export search history
  ///
  /// Parameters:
  /// - [userId]: User identifier (required for export)
  /// - [format]: Export format (json, csv)
  /// - [from]: Start date for export
  /// - [to]: End date for export
  ///
  /// Returns:
  /// - [String] with exported data
  Future<String> exportSearchHistory({
    required String userId,
    String format = 'json',
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      return await repository.exportSearchData(
        userId,
        from: from,
        to: to,
        format: format,
      );
    } catch (e) {
      throw Exception('Failed to export search history: ${e.toString()}');
    }
  }

  /// Import search history
  ///
  /// Parameters:
  /// - [userId]: User identifier (required for import)
  /// - [data]: Data to import
  /// - [format]: Import format (json, csv)
  /// - [mergeStrategy]: How to handle conflicts (replace, merge, skip)
  ///
  /// Returns:
  /// - [ImportHistoryResult] indicating success or failure
  Future<ImportHistoryResult> importSearchHistory({
    required String userId,
    required String data,
    String format = 'json',
    String mergeStrategy = 'merge',
  }) async {
    try {
      // Validate import data
      final validation = _validateImportData(data, format);
      if (!validation.isValid) {
        return ImportHistoryResult.invalid(validation.errorMessage!);
      }

      // Handle merge strategy
      if (mergeStrategy == 'replace') {
        await repository.clearSearchHistory();
      }

      // Import data
      await repository.importSearchData(userId, data, format);

      return ImportHistoryResult.success();
    } catch (e) {
      return ImportHistoryResult.failure(
        error: 'Failed to import search history: ${e.toString()}',
      );
    }
  }

  /// Get search patterns and insights
  ///
  /// Parameters:
  /// - [userId]: User identifier (optional)
  /// - [analysisType]: Type of analysis (temporal, frequency, success_rate)
  ///
  /// Returns:
  /// - [SearchPatternInsights] with analysis results
  Future<SearchPatternInsights> getSearchPatterns({
    String? userId,
    String analysisType = 'all',
  }) async {
    try {
      final historyCollection = await repository.getDetailedSearchHistory(
        limit: _maxHistoryItems,
      );

      return _analyzeSearchPatterns(historyCollection, analysisType);
    } catch (e) {
      return SearchPatternInsights.empty();
    }
  }

  /// Private helper methods

  /// Validate history input parameters
  ValidationResult _validateHistoryInput(int limit, int offset) {
    if (limit < 1 || limit > _maxHistoryItems) {
      return ValidationResult.invalid(
        'Limit must be between 1 and $_maxHistoryItems',
      );
    }

    if (offset < 0) {
      return ValidationResult.invalid('Offset cannot be negative');
    }

    return ValidationResult.valid();
  }

  /// Check if query should be saved to history
  Future<bool> _shouldSaveQuery(String query, String? userId) async {
    try {
      // Get recent history to check for duplicates
      final recentHistory = await repository.getRecentSearches(limit: 5);

      // Don't save if it's the same as the last query
      if (recentHistory.isNotEmpty &&
          recentHistory.first.toLowerCase() == query.toLowerCase()) {
        return false;
      }

      // Don't save very short queries unless they're successful
      if (query.length < 2) {
        return false;
      }

      return true;
    } catch (e) {
      return true; // Default to saving if we can't check
    }
  }

  /// Cleanup old history items
  Future<void> _cleanupOldHistory(String? userId) async {
    try {
      final cutoffDate = DateTime.now().subtract(_historyRetentionPeriod);

      await clearSearchHistory(userId: userId, olderThan: cutoffDate);
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  /// Get history metadata
  Future<HistoryMetadata> _getHistoryMetadata(
    String? userId,
    List<SearchHistoryEntity> history,
  ) async {
    final totalQueries = history.length;
    final uniqueQueries = history.map((h) => h.query).toSet().length;
    final successfulQueries = history.where((h) => h.wasSuccessful).length;
    final successRate = totalQueries > 0
        ? successfulQueries / totalQueries
        : 0.0;

    final mostSearchedEntities = <String, int>{};
    for (final item in history) {
      for (final entity in item.entities) {
        mostSearchedEntities[entity] = (mostSearchedEntities[entity] ?? 0) + 1;
      }
    }

    final topEntity = mostSearchedEntities.isNotEmpty
        ? mostSearchedEntities.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key
        : 'none';

    return HistoryMetadata(
      totalQueries: totalQueries,
      uniqueQueries: uniqueQueries,
      successRate: successRate,
      mostSearchedEntity: topEntity,
      retentionPeriodDays: _historyRetentionPeriod.inDays,
    );
  }

  /// Calculate history statistics
  HistoryStatistics _calculateHistoryStatistics(
    SearchHistoryCollectionEntity history,
    String period,
  ) {
    final items = history.items;
    final totalSearches = items.length;
    final successfulSearches = items.where((item) => item.wasSuccessful).length;
    final successRate = totalSearches > 0
        ? successfulSearches / totalSearches
        : 0.0;

    final avgResultsPerSearch = items.isNotEmpty
        ? items.fold(0, (sum, item) => sum + item.resultsCount) / items.length
        : 0.0;

    final searchesByDay = <String, int>{};
    for (final item in items) {
      final dayKey =
          '${item.timestamp.year}-${item.timestamp.month}-${item.timestamp.day}';
      searchesByDay[dayKey] = (searchesByDay[dayKey] ?? 0) + 1;
    }

    final mostActiveDay = searchesByDay.isNotEmpty
        ? searchesByDay.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'none';

    return HistoryStatistics(
      period: period,
      totalSearches: totalSearches,
      successfulSearches: successfulSearches,
      successRate: successRate,
      avgResultsPerSearch: avgResultsPerSearch,
      searchesByDay: searchesByDay,
      mostActiveDay: mostActiveDay,
      topQueries: history.frequentQueries.take(5).toList(),
    );
  }

  /// Validate import data
  ValidationResult _validateImportData(String data, String format) {
    if (data.trim().isEmpty) {
      return ValidationResult.invalid('Import data cannot be empty');
    }

    if (format != 'json' && format != 'csv') {
      return ValidationResult.invalid('Unsupported format: $format');
    }

    // Basic format validation
    if (format == 'json') {
      try {
        // Simple JSON validation - would need proper parsing in real implementation
        if (!data.trim().startsWith('{') && !data.trim().startsWith('[')) {
          return ValidationResult.invalid('Invalid JSON format');
        }
      } catch (e) {
        return ValidationResult.invalid('Invalid JSON format');
      }
    }

    return ValidationResult.valid();
  }

  /// Analyze search patterns
  SearchPatternInsights _analyzeSearchPatterns(
    SearchHistoryCollectionEntity history,
    String analysisType,
  ) {
    final insights = SearchPatternInsights();

    if (analysisType == 'all' || analysisType == 'temporal') {
      insights.temporalPatterns = history.searchPatternsByHour;
      insights.weeklyPatterns = history.searchPatternsByWeekday;
    }

    if (analysisType == 'all' || analysisType == 'frequency') {
      insights.frequentQueries = history.frequentQueries;
    }

    if (analysisType == 'all' || analysisType == 'success_rate') {
      insights.successRate = history.successRate;
      insights.avgResultsPerSearch = history.avgResultsPerSearch;
    }

    return insights;
  }
}

/// Result classes

class SearchHistoryResult {
  final bool success;
  final SearchHistoryCollectionEntity? history;
  final int? totalCount;
  final bool? hasMore;
  final HistoryMetadata? metadata;
  final String? error;

  const SearchHistoryResult({
    required this.success,
    this.history,
    this.totalCount,
    this.hasMore,
    this.metadata,
    this.error,
  });

  factory SearchHistoryResult.success({
    required SearchHistoryCollectionEntity history,
    required int totalCount,
    required bool hasMore,
    HistoryMetadata? metadata,
  }) {
    return SearchHistoryResult(
      success: true,
      history: history,
      totalCount: totalCount,
      hasMore: hasMore,
      metadata: metadata,
    );
  }

  factory SearchHistoryResult.failure({required String error}) {
    return SearchHistoryResult(success: false, error: error);
  }

  factory SearchHistoryResult.invalid(String error) {
    return SearchHistoryResult(success: false, error: error);
  }

  bool get hasHistory => success && history != null && history!.isNotEmpty;
  bool get isEmpty => success && (history == null || history!.isEmpty);
}

class SaveHistoryResult {
  final bool success;
  final bool skipped;
  final String? error;

  const SaveHistoryResult({
    required this.success,
    this.skipped = false,
    this.error,
  });

  factory SaveHistoryResult.success() {
    return const SaveHistoryResult(success: true);
  }

  factory SaveHistoryResult.skipped(String reason) {
    return SaveHistoryResult(success: true, skipped: true, error: reason);
  }

  factory SaveHistoryResult.failure({required String error}) {
    return SaveHistoryResult(success: false, error: error);
  }

  factory SaveHistoryResult.invalid(String error) {
    return SaveHistoryResult(success: false, error: error);
  }
}

class ClearHistoryResult {
  final bool success;
  final int? clearedCount;
  final String? error;

  const ClearHistoryResult({
    required this.success,
    this.clearedCount,
    this.error,
  });

  factory ClearHistoryResult.success({int? clearedCount}) {
    return ClearHistoryResult(success: true, clearedCount: clearedCount);
  }

  factory ClearHistoryResult.failure({required String error}) {
    return ClearHistoryResult(success: false, error: error);
  }
}

class ImportHistoryResult {
  final bool success;
  final String? error;

  const ImportHistoryResult({required this.success, this.error});

  factory ImportHistoryResult.success() {
    return const ImportHistoryResult(success: true);
  }

  factory ImportHistoryResult.failure({required String error}) {
    return ImportHistoryResult(success: false, error: error);
  }

  factory ImportHistoryResult.invalid(String error) {
    return ImportHistoryResult(success: false, error: error);
  }
}

class HistoryMetadata {
  final int totalQueries;
  final int uniqueQueries;
  final double successRate;
  final String mostSearchedEntity;
  final int retentionPeriodDays;

  const HistoryMetadata({
    required this.totalQueries,
    required this.uniqueQueries,
    required this.successRate,
    required this.mostSearchedEntity,
    required this.retentionPeriodDays,
  });
}

class HistoryStatistics {
  final String period;
  final int totalSearches;
  final int successfulSearches;
  final double successRate;
  final double avgResultsPerSearch;
  final Map<String, int> searchesByDay;
  final String mostActiveDay;
  final List<FrequentQueryEntity> topQueries;

  const HistoryStatistics({
    required this.period,
    required this.totalSearches,
    required this.successfulSearches,
    required this.successRate,
    required this.avgResultsPerSearch,
    required this.searchesByDay,
    required this.mostActiveDay,
    required this.topQueries,
  });

  factory HistoryStatistics.empty() {
    return const HistoryStatistics(
      period: 'none',
      totalSearches: 0,
      successfulSearches: 0,
      successRate: 0.0,
      avgResultsPerSearch: 0.0,
      searchesByDay: {},
      mostActiveDay: 'none',
      topQueries: [],
    );
  }
}

class SearchPatternInsights {
  Map<int, int>? temporalPatterns;
  Map<int, int>? weeklyPatterns;
  List<FrequentQueryEntity>? frequentQueries;
  double? successRate;
  double? avgResultsPerSearch;

  SearchPatternInsights({
    this.temporalPatterns,
    this.weeklyPatterns,
    this.frequentQueries,
    this.successRate,
    this.avgResultsPerSearch,
  });

  factory SearchPatternInsights.empty() {
    return SearchPatternInsights();
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({required this.isValid, this.errorMessage});

  factory ValidationResult.valid() => const ValidationResult(isValid: true);
  factory ValidationResult.invalid(String message) =>
      ValidationResult(isValid: false, errorMessage: message);
}
