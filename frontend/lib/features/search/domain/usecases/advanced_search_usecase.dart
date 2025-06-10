// Path: frontend/lib/features/search/domain/usecases/advanced_search_usecase.dart
import '../entities/search_result_entity.dart';
import '../entities/search_filter_entity.dart';
import '../entities/search_meta_entity.dart';
import '../entities/search_analytics_entity.dart';
import '../repositories/search_repository.dart';

/// Use case for advanced search functionality
/// Provides comprehensive search with analytics, related queries, and advanced filtering
class AdvancedSearchUseCase {
  final SearchRepository repository;

  // Configuration constants
  static const int _defaultLimit = 20;
  static const int _maxLimit = 100;
  static const int _minQueryLength = 2;
  static const Duration _searchTimeout = Duration(seconds: 45);

  AdvancedSearchUseCase(this.repository);

  /// Execute advanced search with full features
  ///
  /// Parameters:
  /// - [query]: Search query (required, min 2 characters)
  /// - [entities]: Entity types to search (default: ['assets'])
  /// - [page]: Page number for pagination (default: 1)
  /// - [limit]: Results per page (default: 20, max: 100)
  /// - [sort]: Sort order ('relevance', 'created_at', 'alphabetical')
  /// - [filters]: Advanced filters for refining results
  /// - [exactMatch]: Whether to use exact matching
  /// - [includeAnalytics]: Include search performance analytics
  /// - [includeRelated]: Include related search suggestions
  /// - [highlightMatches]: Highlight matching text in results
  ///
  /// Returns:
  /// - [AdvancedSearchResult] with comprehensive results and metadata
  Future<AdvancedSearchResult> execute({
    required String query,
    List<String> entities = const ['assets'],
    int page = 1,
    int limit = _defaultLimit,
    String sort = 'relevance',
    SearchFilterEntity? filters,
    bool exactMatch = false,
    bool includeAnalytics = true,
    bool includeRelated = true,
    bool highlightMatches = true,
    String? userId,
  }) async {
    final startTime = DateTime.now();

    try {
      // Validate input parameters
      final validation = _validateInput(
        query: query,
        entities: entities,
        page: page,
        limit: limit,
        sort: sort,
      );

      if (!validation.isValid) {
        return AdvancedSearchResult.invalid(validation.errorMessage!);
      }

      // Optimize search parameters
      final optimizedParams = _optimizeSearchParameters(
        query: query,
        entities: entities,
        page: page,
        limit: limit,
        sort: sort,
        filters: filters,
        exactMatch: exactMatch,
        includeAnalytics: includeAnalytics,
        includeRelated: includeRelated,
        highlightMatches: highlightMatches,
      );

      // Execute advanced search with timeout protection
      final result = await _executeWithTimeout(
        () => repository.advancedSearch(
          optimizedParams.query,
          entities: optimizedParams.entities,
          page: optimizedParams.page,
          limit: optimizedParams.limit,
          sort: optimizedParams.sort,
          filters: optimizedParams.filters,
          exactMatch: optimizedParams.exactMatch,
          includeAnalytics: optimizedParams.includeAnalytics,
          includeRelated: optimizedParams.includeRelated,
          highlightMatches: optimizedParams.highlightMatches,
        ),
        timeout: _searchTimeout,
      );

      final duration = DateTime.now().difference(startTime);

      if (result.success && result.data != null) {
        // Post-process results for advanced features
        final processedResults = _postProcessResults(
          result.data!,
          optimizedParams,
        );

        // Get additional advanced features
        final advancedFeatures = await _getAdvancedFeatures(
          optimizedParams,
          result.meta,
          userId,
        );

        // Create analytics entry
        final analytics = SearchAnalyticsEntity.successful(
          query: optimizedParams.query,
          searchType: 'advanced',
          entities: optimizedParams.entities,
          resultsCount: processedResults.length,
          durationMs: duration.inMilliseconds,
          userId: userId,
          filters: optimizedParams.filters?.toJson(),
          fromCache: result.fromCache,
        );

        // Log analytics asynchronously
        _logSearchAnalytics(analytics);

        return AdvancedSearchResult.success(
          results: processedResults,
          query: optimizedParams.query,
          entities: optimizedParams.entities,
          page: optimizedParams.page,
          limit: optimizedParams.limit,
          totalResults: result.totalResults,
          fromCache: result.fromCache,
          duration: duration,
          meta: result.meta,
          filters: optimizedParams.filters,
          sort: optimizedParams.sort,
          relatedQueries: advancedFeatures.relatedQueries,
          similarItems: advancedFeatures.similarItems,
          searchInsights: advancedFeatures.searchInsights,
          analytics: analytics,
        );
      } else {
        // Create failed analytics entry
        final analytics = SearchAnalyticsEntity.failed(
          query: optimizedParams.query,
          searchType: 'advanced',
          entities: optimizedParams.entities,
          durationMs: duration.inMilliseconds,
          errorType: result.error ?? 'unknown_error',
          userId: userId,
          filters: optimizedParams.filters?.toJson(),
        );

        _logSearchAnalytics(analytics);

        return AdvancedSearchResult.failure(
          error: result.error ?? 'Advanced search failed',
          query: optimizedParams.query,
          duration: duration,
          analytics: analytics,
        );
      }
    } catch (e) {
      final duration = DateTime.now().difference(startTime);

      final analytics = SearchAnalyticsEntity.failed(
        query: query,
        searchType: 'advanced',
        entities: entities,
        durationMs: duration.inMilliseconds,
        errorType: 'exception',
        userId: userId,
        filters: filters?.toJson(),
      );

      _logSearchAnalytics(analytics);

      return AdvancedSearchResult.failure(
        error: 'Unexpected error: ${e.toString()}',
        query: query,
        duration: duration,
        analytics: analytics,
      );
    }
  }

  /// Execute semantic search using AI/ML
  Future<AdvancedSearchResult> executeSemanticSearch({
    required String query,
    List<String> entities = const ['assets'],
    int limit = _defaultLimit,
    String context = 'general',
    String? userId,
  }) async {
    try {
      final validation = _validateInput(
        query: query,
        entities: entities,
        page: 1,
        limit: limit,
        sort: 'relevance',
      );

      if (!validation.isValid) {
        return AdvancedSearchResult.invalid(validation.errorMessage!);
      }

      final result = await repository.semanticSearch(
        query,
        entities,
        limit: limit,
        context: context,
      );

      if (result.success && result.data != null) {
        return AdvancedSearchResult.success(
          results: result.data!,
          query: query,
          entities: entities,
          page: 1,
          limit: limit,
          totalResults: result.totalResults,
          fromCache: result.fromCache,
          searchType: 'semantic',
        );
      } else {
        return AdvancedSearchResult.failure(
          error: result.error ?? 'Semantic search failed',
          query: query,
        );
      }
    } catch (e) {
      return AdvancedSearchResult.failure(error: e.toString(), query: query);
    }
  }

  /// Execute similarity search
  Future<AdvancedSearchResult> executeSimilaritySearch({
    required String referenceId,
    required String entityType,
    int limit = 10,
    double threshold = 0.7,
    String? userId,
  }) async {
    try {
      final result = await repository.similaritySearch(
        referenceId,
        entityType,
        limit: limit,
        threshold: threshold,
      );

      if (result.success && result.data != null) {
        return AdvancedSearchResult.success(
          results: result.data!,
          query: 'Similar to: $referenceId',
          entities: [entityType],
          page: 1,
          limit: limit,
          totalResults: result.totalResults,
          fromCache: result.fromCache,
          searchType: 'similarity',
        );
      } else {
        return AdvancedSearchResult.failure(
          error: result.error ?? 'Similarity search failed',
          query: 'Similar to: $referenceId',
        );
      }
    } catch (e) {
      return AdvancedSearchResult.failure(
        error: e.toString(),
        query: 'Similar to: $referenceId',
      );
    }
  }

  /// Execute search with custom scoring
  Future<AdvancedSearchResult> executeWithCustomScoring({
    required String query,
    required Map<String, double> scoringWeights,
    List<String> entities = const ['assets'],
    int page = 1,
    int limit = _defaultLimit,
    SearchFilterEntity? filters,
    String? userId,
  }) async {
    // Execute regular advanced search first
    final result = await execute(
      query: query,
      entities: entities,
      page: page,
      limit: limit,
      filters: filters,
      userId: userId,
    );

    if (result.success && result.results != null) {
      // Apply custom scoring
      final rescored = _applyCustomScoring(result.results!, scoringWeights);

      return result.copyWith(results: rescored);
    }

    return result;
  }

  /// Get search recommendations based on context
  Future<List<String>> getSearchRecommendations({
    required String currentQuery,
    String? userId,
    List<String> context = const [],
  }) async {
    try {
      if (userId != null) {
        final suggestions = await repository.getSearchRecommendations(
          userId,
          limit: 10,
        );
        return suggestions.map((s) => s.value).toList();
      }

      // Fallback to popular searches
      return await repository.getPopularSearches(limit: 5);
    } catch (e) {
      return [];
    }
  }

  /// Get search insights for optimization
  Future<List<String>> getSearchInsights({
    required String query,
    String? userId,
  }) async {
    try {
      if (userId != null) {
        return await repository.getSearchInsights(userId);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Private helper methods

  /// Validate input parameters
  SearchValidationResult _validateInput({
    required String query,
    required List<String> entities,
    required int page,
    required int limit,
    required String sort,
  }) {
    // Validate query
    if (query.trim().isEmpty) {
      return SearchValidationResult.invalid('Search query cannot be empty');
    }

    if (query.length < _minQueryLength) {
      return SearchValidationResult.invalid(
        'Search query must be at least $_minQueryLength characters',
      );
    }

    if (query.length > 200) {
      return SearchValidationResult.invalid(
        'Search query too long (max 200 characters)',
      );
    }

    // Validate entities
    if (entities.isEmpty) {
      return SearchValidationResult.invalid(
        'At least one entity type must be specified',
      );
    }

    final validEntities = ['assets', 'plants', 'locations', 'users'];
    final invalidEntities = entities.where((e) => !validEntities.contains(e));

    if (invalidEntities.isNotEmpty) {
      return SearchValidationResult.invalid(
        'Invalid entity types: ${invalidEntities.join(', ')}',
      );
    }

    // Validate pagination
    if (page < 1) {
      return SearchValidationResult.invalid(
        'Page number must be greater than 0',
      );
    }

    if (limit < 1 || limit > _maxLimit) {
      return SearchValidationResult.invalid(
        'Limit must be between 1 and $_maxLimit',
      );
    }

    // Validate sort
    final validSorts = ['relevance', 'created_at', 'alphabetical', 'recent'];
    if (!validSorts.contains(sort)) {
      return SearchValidationResult.invalid('Invalid sort option: $sort');
    }

    return SearchValidationResult.valid();
  }

  /// Optimize search parameters
  OptimizedAdvancedSearchParameters _optimizeSearchParameters({
    required String query,
    required List<String> entities,
    required int page,
    required int limit,
    required String sort,
    SearchFilterEntity? filters,
    required bool exactMatch,
    required bool includeAnalytics,
    required bool includeRelated,
    required bool highlightMatches,
  }) {
    return OptimizedAdvancedSearchParameters(
      query: query.trim(),
      entities: _optimizeEntities(entities),
      page: page,
      limit: limit.clamp(1, _maxLimit),
      sort: sort,
      filters: _optimizeFilters(filters),
      exactMatch: exactMatch,
      includeAnalytics: includeAnalytics,
      includeRelated: includeRelated,
      highlightMatches: highlightMatches,
    );
  }

  /// Optimize entities order
  List<String> _optimizeEntities(List<String> entities) {
    final priorityOrder = ['assets', 'plants', 'locations', 'users'];
    entities.sort((a, b) {
      final aIndex = priorityOrder.indexOf(a);
      final bIndex = priorityOrder.indexOf(b);
      if (aIndex == -1 && bIndex == -1) return 0;
      if (aIndex == -1) return 1;
      if (bIndex == -1) return -1;
      return aIndex.compareTo(bIndex);
    });
    return entities;
  }

  /// Optimize filters
  SearchFilterEntity? _optimizeFilters(SearchFilterEntity? filters) {
    if (filters == null || !filters.hasFilters) return filters;

    return filters.copyWith(
      plantCodes: filters.plantCodes?.where((c) => c.isNotEmpty).toList(),
      locationCodes: filters.locationCodes?.where((c) => c.isNotEmpty).toList(),
      unitCodes: filters.unitCodes?.where((c) => c.isNotEmpty).toList(),
      status: filters.status?.where((s) => s.isNotEmpty).toList(),
      roles: filters.roles?.where((r) => r.isNotEmpty).toList(),
      createdBy: filters.createdBy?.where((u) => u.isNotEmpty).toList(),
    );
  }

  /// Post-process search results
  List<SearchResultEntity> _postProcessResults(
    List<SearchResultEntity> results,
    OptimizedAdvancedSearchParameters params,
  ) {
    // Apply advanced sorting if needed
    if (params.sort == 'relevance') {
      results.sort((a, b) {
        final aScore = a.relevanceScore ?? 0.0;
        final bScore = b.relevanceScore ?? 0.0;
        final scoreCompare = bScore.compareTo(aScore);

        if (scoreCompare == 0) {
          return a.displayPriority.compareTo(b.displayPriority);
        }

        return scoreCompare;
      });
    }

    // Apply advanced filtering if needed
    if (params.filters != null) {
      return _applyAdvancedFiltering(results, params.filters!);
    }

    return results;
  }

  /// Apply advanced filtering
  List<SearchResultEntity> _applyAdvancedFiltering(
    List<SearchResultEntity> results,
    SearchFilterEntity filters,
  ) {
    return results.where((result) {
      // Apply plant code filter
      if (filters.plantCodes?.isNotEmpty == true) {
        final plantCode = result.plantCode;
        if (plantCode == null || !filters.plantCodes!.contains(plantCode)) {
          return false;
        }
      }

      // Apply location code filter
      if (filters.locationCodes?.isNotEmpty == true) {
        final locationCode = result.locationCode;
        if (locationCode == null ||
            !filters.locationCodes!.contains(locationCode)) {
          return false;
        }
      }

      // Apply status filter
      if (filters.status?.isNotEmpty == true) {
        final status = result.status;
        if (status == null || !filters.status!.contains(status)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Get advanced features
  Future<AdvancedSearchFeatures> _getAdvancedFeatures(
    OptimizedAdvancedSearchParameters params,
    SearchMetaEntity? meta,
    String? userId,
  ) async {
    final features = AdvancedSearchFeatures();

    try {
      // Get related queries if enabled
      if (params.includeRelated) {
        features.relatedQueries = await repository.getRelatedSearches(
          params.query,
          limit: 5,
        );
      }

      // Get search insights if user context available
      if (userId != null) {
        features.searchInsights = await repository.getSearchInsights(userId);
      }

      // Get similar items from first result if available
      // This would be implemented based on search results
    } catch (e) {
      // Ignore feature enhancement errors
    }

    return features;
  }

  /// Apply custom scoring weights
  List<SearchResultEntity> _applyCustomScoring(
    List<SearchResultEntity> results,
    Map<String, double> weights,
  ) {
    for (final result in results) {
      double customScore = result.relevanceScore ?? 0.0;

      // Apply weights based on entity type
      final entityWeight = weights[result.entityType] ?? 1.0;
      customScore *= entityWeight;

      // Apply weights based on data fields
      for (final entry in weights.entries) {
        if (result.data.containsKey(entry.key)) {
          customScore *= entry.value;
        }
      }

      // Update the result with new score
      results[results.indexOf(result)] = result.withScore(customScore);
    }

    // Re-sort by new scores
    results.sort(
      (a, b) => (b.relevanceScore ?? 0.0).compareTo(a.relevanceScore ?? 0.0),
    );

    return results;
  }

  /// Execute with timeout protection
  Future<T> _executeWithTimeout<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 45),
  }) async {
    try {
      return await operation().timeout(timeout);
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception(
          'Advanced search timeout - please refine your criteria',
        );
      }
      rethrow;
    }
  }

  /// Log search analytics asynchronously
  void _logSearchAnalytics(SearchAnalyticsEntity analytics) {
    Future.microtask(() async {
      try {
        await repository.logSearchAnalytics(analytics);
      } catch (e) {
        // Ignore logging errors
      }
    });
  }
}

/// Result wrapper for advanced search operations
class AdvancedSearchResult {
  final bool success;
  final List<SearchResultEntity>? results;
  final String query;
  final List<String>? entities;
  final int? page;
  final int? limit;
  final int? totalResults;
  final bool? fromCache;
  final Duration? duration;
  final SearchMetaEntity? meta;
  final SearchFilterEntity? filters;
  final String? sort;
  final List<String>? relatedQueries;
  final List<SearchResultEntity>? similarItems;
  final List<String>? searchInsights;
  final SearchAnalyticsEntity? analytics;
  final String? searchType;
  final String? error;

  const AdvancedSearchResult({
    required this.success,
    this.results,
    required this.query,
    this.entities,
    this.page,
    this.limit,
    this.totalResults,
    this.fromCache,
    this.duration,
    this.meta,
    this.filters,
    this.sort,
    this.relatedQueries,
    this.similarItems,
    this.searchInsights,
    this.analytics,
    this.searchType,
    this.error,
  });

  factory AdvancedSearchResult.success({
    required List<SearchResultEntity> results,
    required String query,
    required List<String> entities,
    required int page,
    required int limit,
    required int totalResults,
    bool fromCache = false,
    Duration? duration,
    SearchMetaEntity? meta,
    SearchFilterEntity? filters,
    String? sort,
    List<String>? relatedQueries,
    List<SearchResultEntity>? similarItems,
    List<String>? searchInsights,
    SearchAnalyticsEntity? analytics,
    String searchType = 'advanced',
  }) {
    return AdvancedSearchResult(
      success: true,
      results: results,
      query: query,
      entities: entities,
      page: page,
      limit: limit,
      totalResults: totalResults,
      fromCache: fromCache,
      duration: duration,
      meta: meta,
      filters: filters,
      sort: sort,
      relatedQueries: relatedQueries,
      similarItems: similarItems,
      searchInsights: searchInsights,
      analytics: analytics,
      searchType: searchType,
    );
  }

  factory AdvancedSearchResult.failure({
    required String error,
    required String query,
    Duration? duration,
    SearchAnalyticsEntity? analytics,
  }) {
    return AdvancedSearchResult(
      success: false,
      query: query,
      error: error,
      duration: duration,
      analytics: analytics,
    );
  }

  factory AdvancedSearchResult.invalid(String error) {
    return AdvancedSearchResult(success: false, query: '', error: error);
  }

  bool get hasResults => success && results != null && results!.isNotEmpty;
  bool get isEmpty => success && (results == null || results!.isEmpty);
  bool get hasError => !success || error != null;
  bool get hasRelatedQueries =>
      relatedQueries != null && relatedQueries!.isNotEmpty;
  bool get hasSimilarItems => similarItems != null && similarItems!.isNotEmpty;
  bool get hasInsights => searchInsights != null && searchInsights!.isNotEmpty;
  bool get hasNextPage => meta?.pagination?.hasNextPage ?? false;
  bool get hasPrevPage => meta?.pagination?.hasPrevPage ?? false;
  bool get isFast => duration != null && duration!.inMilliseconds < 1000;
  bool get isSlow => duration != null && duration!.inMilliseconds > 5000;

  AdvancedSearchResult copyWith({
    List<SearchResultEntity>? results,
    List<String>? relatedQueries,
    List<SearchResultEntity>? similarItems,
    List<String>? searchInsights,
  }) {
    return AdvancedSearchResult(
      success: success,
      results: results ?? this.results,
      query: query,
      entities: entities,
      page: page,
      limit: limit,
      totalResults: totalResults,
      fromCache: fromCache,
      duration: duration,
      meta: meta,
      filters: filters,
      sort: sort,
      relatedQueries: relatedQueries ?? this.relatedQueries,
      similarItems: similarItems ?? this.similarItems,
      searchInsights: searchInsights ?? this.searchInsights,
      analytics: analytics,
      searchType: searchType,
      error: error,
    );
  }
}

/// Supporting classes

class SearchValidationResult {
  final bool isValid;
  final String? errorMessage;

  const SearchValidationResult({required this.isValid, this.errorMessage});

  factory SearchValidationResult.valid() =>
      const SearchValidationResult(isValid: true);
  factory SearchValidationResult.invalid(String message) =>
      SearchValidationResult(isValid: false, errorMessage: message);
}

class OptimizedAdvancedSearchParameters {
  final String query;
  final List<String> entities;
  final int page;
  final int limit;
  final String sort;
  final SearchFilterEntity? filters;
  final bool exactMatch;
  final bool includeAnalytics;
  final bool includeRelated;
  final bool highlightMatches;

  const OptimizedAdvancedSearchParameters({
    required this.query,
    required this.entities,
    required this.page,
    required this.limit,
    required this.sort,
    this.filters,
    required this.exactMatch,
    required this.includeAnalytics,
    required this.includeRelated,
    required this.highlightMatches,
  });
}

class AdvancedSearchFeatures {
  List<String>? relatedQueries;
  List<SearchResultEntity>? similarItems;
  List<String>? searchInsights;

  AdvancedSearchFeatures({
    this.relatedQueries,
    this.similarItems,
    this.searchInsights,
  });
}
