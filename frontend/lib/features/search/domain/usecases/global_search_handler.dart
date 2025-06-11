// Path: frontend/lib/features/search/domain/usecases/global_search_handler.dart
import '../entities/search_result_entity.dart';
import '../entities/search_filter_entity.dart';
import '../entities/search_analytics_entity.dart';
import '../repositories/search_repository.dart';
import '../../data/exceptions/search_exceptions.dart';
import 'query_validator.dart';

/// Handles comprehensive global search with advanced features
/// Provides full-featured search with pagination, filtering, and sorting
class GlobalSearchHandler {
  final SearchRepository _repository;
  final QueryValidator _validator;
  final int _defaultLimit;
  final int _maxLimit;
  final List<String> _defaultEntities;

  // Performance tracking
  final Map<String, DateTime> _searchTimes = {};
  final Map<String, int> _searchCounts = {};

  GlobalSearchHandler(
    this._repository,
    this._validator, {
    int defaultLimit = 20,
    int maxLimit = 100,
    List<String> defaultEntities = const ['assets'],
  }) : _defaultLimit = defaultLimit,
       _maxLimit = maxLimit,
       _defaultEntities = defaultEntities;

  /// Perform comprehensive global search
  Future<SearchResult<List<SearchResultEntity>>> search(
    String query, {
    List<String>? entities,
    int? page,
    int? limit,
    String? sort,
    SearchFilterEntity? filters,
    bool exactMatch = false,
  }) async {
    final startTime = DateTime.now();

    try {
      // Validate query
      final queryValidation = _validator.validateQuery(query);
      if (!queryValidation.isValid) {
        throw SearchQueryException(queryValidation.error!);
      }
      final validatedQuery = queryValidation.data!;

      // Validate and normalize parameters
      final searchParams = await _validateAndNormalizeParams(
        entities: entities,
        page: page,
        limit: limit,
        sort: sort,
        filters: filters,
      );

      // Track search frequency
      _trackSearchFrequency(validatedQuery);

      // Perform search based on strategy
      final searchResult = await _executeSearch(
        validatedQuery,
        searchParams,
        exactMatch,
        startTime,
      );

      // Post-process results
      return await _postProcessResults(
        searchResult,
        validatedQuery,
        searchParams,
        startTime,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      await _logSearchAnalytics(
        query,
        entities ?? _defaultEntities,
        0,
        duration,
        error: e.toString(),
      );
      return SearchResult.failure(error: createSearchExceptionFromError(e));
    }
  }

  /// Get search recommendations based on context
  Future<List<String>> getSearchRecommendations(
    String query, {
    List<String>? entities,
    int limit = 5,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return await _getPopularSearches(limit);
      }

      final relatedSearches = await _repository.getRelatedSearches(
        query.trim(),
        limit: limit,
      );

      return relatedSearches;
    } catch (e) {
      return [];
    }
  }

  /// Get filter options for dynamic facets
  Future<Map<String, List<String>>> getFilterOptions(
    List<String> entities,
  ) async {
    try {
      final filterOptions = <String, List<String>>{};

      for (final entity in entities) {
        final options = await _repository.getFilterOptions(entity);
        filterOptions.addAll(options);
      }

      return filterOptions;
    } catch (e) {
      return {};
    }
  }

  /// Validate and normalize search parameters
  Future<SearchParameters> _validateAndNormalizeParams({
    List<String>? entities,
    int? page,
    int? limit,
    String? sort,
    SearchFilterEntity? filters,
  }) async {
    // Validate entities
    final entityValidation = _validator.validateEntities(
      entities ?? _defaultEntities,
    );
    if (!entityValidation.isValid) {
      throw SearchException(entityValidation.error!);
    }

    // Validate search options
    final optionsValidation = _validator.validateSearchOptions(
      limit: limit,
      page: page,
      sort: sort,
    );
    if (!optionsValidation.isValid) {
      throw SearchException(optionsValidation.error!);
    }

    // Validate filters
    final filterValidation = _validator.validateFilters(filters);
    if (!filterValidation.isValid) {
      throw SearchException(filterValidation.error!);
    }

    return SearchParameters(
      entities: entityValidation.data!,
      page: page ?? 1,
      limit: (limit ?? _defaultLimit).clamp(1, _maxLimit),
      sort: sort ?? 'relevance',
      filters: filterValidation.data!,
    );
  }

  /// Execute the search with appropriate strategy
  Future<SearchResult<List<SearchResultEntity>>> _executeSearch(
    String query,
    SearchParameters params,
    bool exactMatch,
    DateTime startTime,
  ) async {
    // Choose search strategy based on query characteristics
    final queryType = _validator.detectQueryType(query);

    switch (queryType) {
      case QueryType.assetCode:
      case QueryType.serialNumber:
        return await _performExactSearch(query, params, startTime);

      case QueryType.description:
        return await _performFuzzySearch(query, params, startTime);

      default:
        return exactMatch
            ? await _performExactSearch(query, params, startTime)
            : await _performStandardSearch(query, params, startTime);
    }
  }

  /// Perform exact match search
  Future<SearchResult<List<SearchResultEntity>>> _performExactSearch(
    String query,
    SearchParameters params,
    DateTime startTime,
  ) async {
    return await _repository.globalSearch(
      query,
      entities: params.entities,
      page: params.page,
      limit: params.limit,
      sort: params.sort,
      filters: params.filters,
      exactMatch: true,
    );
  }

  /// Perform standard search with ranking
  Future<SearchResult<List<SearchResultEntity>>> _performStandardSearch(
    String query,
    SearchParameters params,
    DateTime startTime,
  ) async {
    return await _repository.globalSearch(
      query,
      entities: params.entities,
      page: params.page,
      limit: params.limit,
      sort: params.sort,
      filters: params.filters,
      exactMatch: false,
    );
  }

  /// Perform fuzzy search for descriptions
  Future<SearchResult<List<SearchResultEntity>>> _performFuzzySearch(
    String query,
    SearchParameters params,
    DateTime startTime,
  ) async {
    // Use advanced search for better fuzzy matching
    return await _repository.advancedSearch(
      query,
      entities: params.entities,
      page: params.page,
      limit: params.limit,
      sort: params.sort,
      filters: params.filters,
      exactMatch: false,
      includeAnalytics: false,
      includeRelated: false,
      highlightMatches: true,
    );
  }

  /// Post-process search results
  Future<SearchResult<List<SearchResultEntity>>> _postProcessResults(
    SearchResult<List<SearchResultEntity>> result,
    String query,
    SearchParameters params,
    DateTime startTime,
  ) async {
    if (!result.success || !result.hasData) {
      return result;
    }

    // Save successful search to history
    await _saveToHistory(query, params, result.totalResults);

    // Log analytics
    final duration = DateTime.now().difference(startTime).inMilliseconds;
    await _logSearchAnalytics(
      query,
      params.entities,
      result.totalResults,
      duration,
      fromCache: result.fromCache,
    );

    return result;
  }

  /// Track search frequency for analytics
  void _trackSearchFrequency(String query) {
    final normalizedQuery = query.toLowerCase().trim();
    _searchCounts[normalizedQuery] = (_searchCounts[normalizedQuery] ?? 0) + 1;
    _searchTimes[normalizedQuery] = DateTime.now();
  }

  /// Save search to history
  Future<void> _saveToHistory(
    String query,
    SearchParameters params,
    int resultsCount,
  ) async {
    try {
      await _repository.saveSearchToHistory(
        query,
        searchType: 'global',
        entities: params.entities,
        resultsCount: resultsCount,
        wasSuccessful: true,
        filters: params.filters.hasFilters
            ? {'applied_filters': params.filters.activeFilterCount}
            : null,
      );
    } catch (e) {
      // Silently fail - don't break search functionality
    }
  }

  /// Get popular searches for recommendations
  Future<List<String>> _getPopularSearches(int limit) async {
    try {
      return await _repository.getPopularSearches(limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Log search analytics
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
              searchType: 'global',
              entities: entities,
              durationMs: durationMs,
              errorType: error,
            )
          : SearchAnalyticsEntity.successful(
              query: query,
              searchType: 'global',
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

  /// Get search statistics
  Map<String, dynamic> getSearchStats() {
    final topQueries = _searchCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'total_searches': _searchCounts.values.fold(0, (a, b) => a + b),
      'unique_queries': _searchCounts.length,
      'top_queries': topQueries
          .take(10)
          .map(
            (e) => {
              'query': e.key,
              'count': e.value,
              'last_searched': _searchTimes[e.key]?.toIso8601String(),
            },
          )
          .toList(),
    };
  }

  /// Clear search statistics
  void clearStats() {
    _searchTimes.clear();
    _searchCounts.clear();
  }

  /// Dispose resources and cleanup
  void dispose() {
    _searchTimes.clear();
    _searchCounts.clear();
  }
}

/// Search parameters container
class SearchParameters {
  final List<String> entities;
  final int page;
  final int limit;
  final String sort;
  final SearchFilterEntity filters;

  const SearchParameters({
    required this.entities,
    required this.page,
    required this.limit,
    required this.sort,
    required this.filters,
  });

  @override
  String toString() {
    return 'SearchParameters(entities: $entities, page: $page, limit: $limit, sort: $sort, hasFilters: ${filters.hasFilters})';
  }
}
