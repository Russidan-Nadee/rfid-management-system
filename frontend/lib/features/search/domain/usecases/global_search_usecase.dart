// Path: frontend/lib/features/search/domain/usecases/global_search_usecase.dart
import '../entities/search_result_entity.dart';
import '../entities/search_filter_entity.dart';
import '../entities/search_meta_entity.dart';
import '../repositories/search_repository.dart';

/// Use case for global search functionality
/// Provides comprehensive search with filtering, pagination, and sorting
class GlobalSearchUseCase {
  final SearchRepository repository;

  // Configuration constants
  static const int _defaultLimit = 20;
  static const int _maxLimit = 100;
  static const int _minQueryLength = 2;
  static const Duration _searchTimeout = Duration(seconds: 30);

  GlobalSearchUseCase(this.repository);

  /// Execute comprehensive global search
  ///
  /// Parameters:
  /// - [query]: Search query (required, min 2 characters)
  /// - [entities]: Entity types to search (default: ['assets'])
  /// - [page]: Page number for pagination (default: 1)
  /// - [limit]: Results per page (default: 20, max: 100)
  /// - [sort]: Sort order ('relevance', 'created_date', 'alphabetical')
  /// - [filters]: Advanced filters for refining results
  /// - [exactMatch]: Whether to use exact matching
  ///
  /// Returns:
  /// - [GlobalSearchResult] with paginated results and metadata
  Future<GlobalSearchResult> execute({
    required String query,
    List<String> entities = const ['assets'],
    int page = 1,
    int limit = _defaultLimit,
    String sort = 'relevance',
    SearchFilterEntity? filters,
    bool exactMatch = false,
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
        return GlobalSearchResult.invalid(validation.errorMessage!);
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
      );

      // Execute search with timeout protection
      final result = await _executeWithTimeout(
        () => repository.globalSearch(
          optimizedParams.query,
          entities: optimizedParams.entities,
          page: optimizedParams.page,
          limit: optimizedParams.limit,
          sort: optimizedParams.sort,
          filters: optimizedParams.filters,
          exactMatch: optimizedParams.exactMatch,
        ),
        timeout: _searchTimeout,
      );

      final duration = DateTime.now().difference(startTime);

      if (result.success && result.data != null) {
        // Post-process results
        final processedResults = _postProcessResults(
          result.data!,
          optimizedParams,
        );

        // Log search analytics
        _logSearchAnalytics(
          query: optimizedParams.query,
          entities: optimizedParams.entities,
          resultsCount: processedResults.length,
          duration: duration,
          filters: optimizedParams.filters,
          userId: userId,
          success: true,
        );

        return GlobalSearchResult.success(
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
        );
      } else {
        // Log failed search
        _logSearchAnalytics(
          query: optimizedParams.query,
          entities: optimizedParams.entities,
          resultsCount: 0,
          duration: duration,
          filters: optimizedParams.filters,
          userId: userId,
          success: false,
          error: result.error,
        );

        return GlobalSearchResult.failure(
          error: result.error ?? 'Search failed',
          query: optimizedParams.query,
          duration: duration,
        );
      }
    } catch (e) {
      final duration = DateTime.now().difference(startTime);

      return GlobalSearchResult.failure(
        error: 'Unexpected error: ${e.toString()}',
        query: query,
        duration: duration,
      );
    }
  }

  /// Execute search with advanced options
  Future<GlobalSearchResult> executeAdvanced({
    required String query,
    required SearchOptions options,
    String? userId,
  }) async {
    return execute(
      query: query,
      entities: options.entities,
      page: options.page,
      limit: options.limit,
      sort: options.sort,
      filters: options.filters,
      exactMatch: options.exactMatch,
      userId: userId,
    );
  }

  /// Search within specific context (plant, location, etc.)
  Future<GlobalSearchResult> searchInContext({
    required String query,
    required SearchContextFilter context,
    int page = 1,
    int limit = _defaultLimit,
    String sort = 'relevance',
    String? userId,
  }) async {
    // Build filters based on context
    final contextFilters = _buildContextFilters(context);

    return execute(
      query: query,
      entities: context.entities,
      page: page,
      limit: limit,
      sort: sort,
      filters: contextFilters,
      userId: userId,
    );
  }

  /// Get search results with faceted filters
  Future<FacetedSearchResult> executeWithFacets({
    required String query,
    List<String> entities = const ['assets'],
    int page = 1,
    int limit = _defaultLimit,
    SearchFilterEntity? filters,
    List<String> facetFields = const ['plant_code', 'location_code', 'status'],
    String? userId,
  }) async {
    // Execute main search
    final searchResult = await execute(
      query: query,
      entities: entities,
      page: page,
      limit: limit,
      filters: filters,
      userId: userId,
    );

    if (!searchResult.success) {
      return FacetedSearchResult.failure(
        error: searchResult.error!,
        query: query,
      );
    }

    // Get facet counts
    final facets = await _getFacetCounts(
      query: query,
      entities: entities,
      filters: filters,
      facetFields: facetFields,
    );

    return FacetedSearchResult.success(
      searchResult: searchResult,
      facets: facets,
    );
  }

  /// Get search with related suggestions
  Future<EnhancedSearchResult> executeWithEnhancements({
    required String query,
    List<String> entities = const ['assets'],
    int page = 1,
    int limit = _defaultLimit,
    SearchFilterEntity? filters,
    bool includeRelated = true,
    bool includeSimilar = true,
    String? userId,
  }) async {
    // Execute main search
    final searchResult = await execute(
      query: query,
      entities: entities,
      page: page,
      limit: limit,
      filters: filters,
      userId: userId,
    );

    final enhancements = <String, dynamic>{};

    // Get related searches if enabled
    if (includeRelated) {
      try {
        final related = await repository.getRelatedSearches(query, limit: 5);
        enhancements['related'] = related;
      } catch (e) {
        // Ignore enhancement errors
      }
    }

    // Get similar items if enabled and results exist
    if (includeSimilar && searchResult.hasResults) {
      try {
        final firstResult = searchResult.results!.first;
        final similar = await repository.similaritySearch(
          firstResult.id,
          firstResult.entityType,
          limit: 5,
        );
        if (similar.success && similar.data != null) {
          enhancements['similar'] = similar.data;
        }
      } catch (e) {
        // Ignore enhancement errors
      }
    }

    return EnhancedSearchResult(
      searchResult: searchResult,
      enhancements: enhancements,
    );
  }

  /// Export search results
  Future<String> exportResults({
    required String query,
    List<String> entities = const ['assets'],
    SearchFilterEntity? filters,
    String format = 'csv',
    String? userId,
  }) async {
    try {
      // Get all results (no pagination limit)
      final result = await execute(
        query: query,
        entities: entities,
        page: 1,
        limit: 1000, // Large limit for export
        filters: filters,
        userId: userId,
      );

      if (!result.success || result.results == null) {
        throw Exception('No results to export');
      }

      return await repository.exportSearchData(
        userId ?? 'anonymous',
        format: format,
      );
    } catch (e) {
      throw Exception('Export failed: ${e.toString()}');
    }
  }

  /// Get search statistics for query
  Future<SearchQueryStatistics> getQueryStatistics(String query) async {
    try {
      final stats = await repository.getSearchStatistics();

      // Extract statistics for specific query
      final queryStats = stats.topQueries
          .where((q) => q.query.toLowerCase() == query.toLowerCase())
          .firstOrNull;

      if (queryStats != null) {
        return SearchQueryStatistics(
          query: query,
          searchCount: queryStats.searchCount,
          avgResults: queryStats.avgResults,
          avgDuration: queryStats.avgDuration,
          successRate: queryStats.successRate,
          popularEntities: queryStats.popularEntities,
        );
      }

      return SearchQueryStatistics.empty(query);
    } catch (e) {
      return SearchQueryStatistics.empty(query);
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
    final validSorts = ['relevance', 'created_date', 'alphabetical', 'recent'];
    if (!validSorts.contains(sort)) {
      return SearchValidationResult.invalid(
        'Invalid sort option: $sort. Valid options: ${validSorts.join(', ')}',
      );
    }

    return SearchValidationResult.valid();
  }

  /// Optimize search parameters
  OptimizedSearchParameters _optimizeSearchParameters({
    required String query,
    required List<String> entities,
    required int page,
    required int limit,
    required String sort,
    SearchFilterEntity? filters,
    required bool exactMatch,
  }) {
    return OptimizedSearchParameters(
      query: query.trim(),
      entities: _optimizeEntities(entities),
      page: page,
      limit: limit.clamp(1, _maxLimit),
      sort: sort,
      filters: _optimizeFilters(filters),
      exactMatch: exactMatch,
    );
  }

  /// Optimize entities order for performance
  List<String> _optimizeEntities(List<String> entities) {
    // Sort by expected result count and performance
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

  /// Optimize filters for performance
  SearchFilterEntity? _optimizeFilters(SearchFilterEntity? filters) {
    if (filters == null || !filters.hasFilters) return filters;

    // Remove empty filter arrays
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
    OptimizedSearchParameters params,
  ) {
    // Sort by relevance if not explicitly sorted
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

    return results;
  }

  /// Build context filters
  SearchFilterEntity _buildContextFilters(SearchContextFilter context) {
    return SearchFilterEntity(
      plantCodes: context.plantCode != null ? [context.plantCode!] : null,
      locationCodes: context.locationCode != null
          ? [context.locationCode!]
          : null,
      status: context.status,
      dateRange: context.dateRange,
    );
  }

  /// Get facet counts for search results
  Future<Map<String, Map<String, int>>> _getFacetCounts({
    required String query,
    required List<String> entities,
    SearchFilterEntity? filters,
    required List<String> facetFields,
  }) async {
    // This would typically involve additional API calls to get facet counts
    // For now, return empty facets
    final facets = <String, Map<String, int>>{};

    for (final field in facetFields) {
      facets[field] = <String, int>{};
    }

    return facets;
  }

  /// Execute with timeout protection
  Future<T> _executeWithTimeout<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      return await operation().timeout(timeout);
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Search timeout - please refine your search criteria');
      }
      rethrow;
    }
  }

  /// Log search analytics asynchronously
  void _logSearchAnalytics({
    required String query,
    required List<String> entities,
    required int resultsCount,
    required Duration duration,
    SearchFilterEntity? filters,
    String? userId,
    required bool success,
    String? error,
  }) {
    Future.microtask(() async {
      try {
        await repository.saveSearchToHistory(
          query,
          searchType: 'global',
          entities: entities,
          resultsCount: resultsCount,
          wasSuccessful: success,
          filters: filters?.toJson(),
        );
      } catch (e) {
        // Ignore logging errors
      }
    });
  }
}

/// Result wrapper for global search operations
class GlobalSearchResult {
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
  final String? error;

  const GlobalSearchResult({
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
    this.error,
  });

  factory GlobalSearchResult.success({
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
  }) {
    return GlobalSearchResult(
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
    );
  }

  factory GlobalSearchResult.failure({
    required String error,
    required String query,
    Duration? duration,
  }) {
    return GlobalSearchResult(
      success: false,
      query: query,
      error: error,
      duration: duration,
    );
  }

  factory GlobalSearchResult.invalid(String error) {
    return GlobalSearchResult(success: false, query: '', error: error);
  }

  bool get hasResults => success && results != null && results!.isNotEmpty;
  bool get isEmpty => success && (results == null || results!.isEmpty);
  bool get hasError => !success || error != null;
  bool get hasNextPage => meta?.pagination?.hasNextPage ?? false;
  bool get hasPrevPage => meta?.pagination?.hasPrevPage ?? false;
  bool get isFirstPage => (page ?? 1) == 1;
  bool get isFast => duration != null && duration!.inMilliseconds < 500;
  bool get isSlow => duration != null && duration!.inMilliseconds > 2000;
}

/// Supporting classes for global search

class SearchOptions {
  final List<String> entities;
  final int page;
  final int limit;
  final String sort;
  final SearchFilterEntity? filters;
  final bool exactMatch;

  const SearchOptions({
    this.entities = const ['assets'],
    this.page = 1,
    this.limit = 20,
    this.sort = 'relevance',
    this.filters,
    this.exactMatch = false,
  });
}

class SearchContextFilter {
  final List<String> entities;
  final String? plantCode;
  final String? locationCode;
  final List<String>? status;
  final DateRangeFilterEntity? dateRange;

  const SearchContextFilter({
    this.entities = const ['assets'],
    this.plantCode,
    this.locationCode,
    this.status,
    this.dateRange,
  });
}

class FacetedSearchResult {
  final bool success;
  final GlobalSearchResult? searchResult;
  final Map<String, Map<String, int>>? facets;
  final String? error;

  const FacetedSearchResult({
    required this.success,
    this.searchResult,
    this.facets,
    this.error,
  });

  factory FacetedSearchResult.success({
    required GlobalSearchResult searchResult,
    required Map<String, Map<String, int>> facets,
  }) {
    return FacetedSearchResult(
      success: true,
      searchResult: searchResult,
      facets: facets,
    );
  }

  factory FacetedSearchResult.failure({
    required String error,
    required String query,
  }) {
    return FacetedSearchResult(success: false, error: error);
  }
}

class EnhancedSearchResult {
  final GlobalSearchResult searchResult;
  final Map<String, dynamic> enhancements;

  const EnhancedSearchResult({
    required this.searchResult,
    this.enhancements = const {},
  });

  List<String>? get relatedSearches => enhancements['related'] as List<String>?;
  List<SearchResultEntity>? get similarItems =>
      enhancements['similar'] as List<SearchResultEntity>?;
}

class SearchQueryStatistics {
  final String query;
  final int searchCount;
  final double avgResults;
  final double avgDuration;
  final double successRate;
  final List<String> popularEntities;

  const SearchQueryStatistics({
    required this.query,
    required this.searchCount,
    required this.avgResults,
    required this.avgDuration,
    required this.successRate,
    required this.popularEntities,
  });

  factory SearchQueryStatistics.empty(String query) {
    return SearchQueryStatistics(
      query: query,
      searchCount: 0,
      avgResults: 0.0,
      avgDuration: 0.0,
      successRate: 0.0,
      popularEntities: [],
    );
  }
}

class SearchValidationResult {
  final bool isValid;
  final String? errorMessage;

  const SearchValidationResult({required this.isValid, this.errorMessage});

  factory SearchValidationResult.valid() =>
      const SearchValidationResult(isValid: true);

  factory SearchValidationResult.invalid(String message) =>
      SearchValidationResult(isValid: false, errorMessage: message);
}

class OptimizedSearchParameters {
  final String query;
  final List<String> entities;
  final int page;
  final int limit;
  final String sort;
  final SearchFilterEntity? filters;
  final bool exactMatch;

  const OptimizedSearchParameters({
    required this.query,
    required this.entities,
    required this.page,
    required this.limit,
    required this.sort,
    this.filters,
    required this.exactMatch,
  });
}
