// Path: frontend/lib/features/search/data/repositories/search_repository_impl.dart
import '../../domain/repositories/search_repository.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../domain/entities/search_suggestion_entity.dart';
import '../../domain/entities/search_filter_entity.dart';
import '../contracts/search_datasource_contracts.dart';
import '../models/search_filter_model.dart';
import '../exceptions/search_exceptions.dart';
import 'search_cache_strategy.dart';

/// Implementation of SearchRepository
/// Coordinates between remote and cache data sources
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  final SearchCacheDataSource cacheDataSource;
  final SearchCacheStrategy cacheStrategy;

  SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.cacheDataSource,
    required this.cacheStrategy,
  });

  @override
  Future<SearchResult<List<SearchResultEntity>>> instantSearch(
    String query, {
    List<String> entities = const ['assets'],
    int limit = 5,
    bool includeDetails = false,
  }) async {
    try {
      // Create cache key
      final cacheKey = cacheStrategy.generateCacheKey('instant', query, {
        'entities': entities.join(','),
        'limit': limit.toString(),
        'details': includeDetails.toString(),
      });

      // Try cache first
      final cachedResponse = await cacheDataSource.getCachedSearchResults(
        cacheKey,
      );
      if (cachedResponse != null) {
        final entities = _convertToSearchResultEntities(
          cachedResponse.allResults,
        );
        return SearchResult.success(
          data: entities,
          fromCache: true,
          totalResults: entities.length,
        );
      }

      // Fetch from remote
      final response = await remoteDataSource.instantSearch(
        query,
        entities: entities,
        limit: limit,
        includeDetails: includeDetails,
      );

      // Cache the response
      await cacheStrategy.cacheSearchResults(cacheKey, response);

      // Save to search history
      await cacheDataSource.saveSearchToHistory(query);

      final resultEntities = _convertToSearchResultEntities(
        response.allResults,
      );
      return SearchResult.success(
        data: resultEntities,
        fromCache: false,
        totalResults: resultEntities.length,
        meta: response.meta != null
            ? _convertToSearchMeta(response.meta!)
            : null,
      );
    } catch (e) {
      return SearchResult.failure(
        error: createSearchExceptionFromError(e),
        query: query,
      );
    }
  }

  @override
  Future<SearchResult<List<SearchSuggestionEntity>>> getSuggestions(
    String query, {
    String type = 'all',
    int limit = 5,
    bool fuzzy = false,
  }) async {
    try {
      // Check cache first
      final cachedSuggestions = await cacheDataSource.getCachedSuggestions(
        query,
      );
      if (cachedSuggestions != null) {
        final entities = _convertToSuggestionEntities(cachedSuggestions);
        return SearchResult.success(
          data: entities,
          fromCache: true,
          totalResults: entities.length,
        );
      }

      // Get from remote
      final suggestions = await remoteDataSource.getSuggestions(
        query,
        type: type,
        limit: limit,
        fuzzy: fuzzy,
      );

      // Cache suggestions
      await cacheDataSource.cacheSuggestions(query, suggestions);

      final entities = _convertToSuggestionEntities(suggestions);
      return SearchResult.success(
        data: entities,
        fromCache: false,
        totalResults: entities.length,
      );
    } catch (e) {
      return SearchResult.failure(
        error: createSearchExceptionFromError(e),
        query: query,
      );
    }
  }

  @override
  Future<SearchResult<List<SearchResultEntity>>> globalSearch(
    String query, {
    List<String> entities = const ['assets'],
    int page = 1,
    int limit = 20,
    String sort = 'relevance',
    SearchFilterEntity? filters,
    bool exactMatch = false,
  }) async {
    try {
      // Convert filter entity to model
      final filterModel = filters != null
          ? _convertToFilterModel(filters)
          : null;

      final cacheKey = cacheStrategy.generateCacheKey('global', query, {
        'entities': entities.join(','),
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
        'filters': filterModel?.toJson().toString() ?? '',
        'exact': exactMatch.toString(),
      });

      // Try cache for first page only
      if (page == 1) {
        final cachedResponse = await cacheDataSource.getCachedSearchResults(
          cacheKey,
        );
        if (cachedResponse != null) {
          final resultEntities = _convertToSearchResultEntities(
            cachedResponse.allResults,
          );
          return SearchResult.success(
            data: resultEntities,
            fromCache: true,
            totalResults: cachedResponse.totalResults,
            meta: cachedResponse.meta != null
                ? _convertToSearchMeta(cachedResponse.meta!)
                : null,
          );
        }
      }

      // Fetch from remote
      final response = await remoteDataSource.globalSearch(
        query,
        entities: entities,
        page: page,
        limit: limit,
        sort: sort,
        filters: filterModel,
        exactMatch: exactMatch,
      );

      // Cache only first page
      if (page == 1) {
        await cacheStrategy.cacheSearchResults(cacheKey, response);
      }

      // Save to search history
      await cacheDataSource.saveSearchToHistory(query);

      final resultEntities = _convertToSearchResultEntities(
        response.allResults,
      );
      return SearchResult.success(
        data: resultEntities,
        fromCache: false,
        totalResults: response.totalResults,
        meta: response.meta != null
            ? _convertToSearchMeta(response.meta!)
            : null,
      );
    } catch (e) {
      return SearchResult.failure(
        error: createSearchExceptionFromError(e),
        query: query,
      );
    }
  }

  @override
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
  }) async {
    try {
      final filterModel = filters != null
          ? _convertToFilterModel(filters)
          : null;

      // Don't cache advanced search due to complexity
      final response = await remoteDataSource.advancedSearch(
        query,
        entities: entities,
        page: page,
        limit: limit,
        sort: sort,
        filters: filterModel,
        exactMatch: exactMatch,
        includeAnalytics: includeAnalytics,
        includeRelated: includeRelated,
        highlightMatches: highlightMatches,
      );

      // Save to search history
      await cacheDataSource.saveSearchToHistory(query);

      final resultEntities = _convertToSearchResultEntities(
        response.allResults,
      );
      return SearchResult.success(
        data: resultEntities,
        fromCache: false,
        totalResults: response.totalResults,
        meta: response.meta != null
            ? _convertToSearchMeta(response.meta!)
            : null,
      );
    } catch (e) {
      return SearchResult.failure(
        error: createSearchExceptionFromError(e),
        query: query,
      );
    }
  }

  @override
  Future<List<String>> getRecentSearches({int limit = 10}) async {
    try {
      // Try local cache first
      final localHistory = await cacheDataSource.getSearchHistory(limit: limit);

      if (localHistory.isNotEmpty) {
        return localHistory;
      }

      // Fallback to remote
      final remoteHistory = await remoteDataSource.getRecentSearches(
        limit: limit,
      );

      // Cache remote history locally
      for (final query in remoteHistory.reversed) {
        await cacheDataSource.saveSearchToHistory(query);
      }

      return remoteHistory;
    } catch (e) {
      // Return local cache on error
      return await cacheDataSource.getSearchHistory(limit: limit);
    }
  }

  @override
  Future<List<String>> getPopularSearches({int limit = 10}) async {
    try {
      // Try cache first
      final cachedPopular = await cacheDataSource.getCachedPopularSearches();
      if (cachedPopular != null) {
        return cachedPopular.take(limit).toList();
      }

      // Fetch from remote
      final popular = await remoteDataSource.getPopularSearches(limit: limit);

      // Cache popular searches
      await cacheDataSource.cachePopularSearches(popular);

      return popular;
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  @override
  Future<void> clearSearchHistory() async {
    try {
      // Clear both local and remote
      await Future.wait([
        cacheDataSource.clearLocalSearchHistory(),
        remoteDataSource.clearSearchHistory(),
      ]);
    } catch (e) {
      // At least clear local
      await cacheDataSource.clearLocalSearchHistory();
    }
  }

  @override
  Future<void> clearSearchCache() async {
    await cacheDataSource.clearAllCache();
  }

  @override
  Future<Map<String, dynamic>> getSearchStats() async {
    try {
      final cacheStats = await cacheDataSource.getCacheStats();
      return {'cache': cacheStats, 'cache_strategy': cacheStrategy.getStats()};
    } catch (e) {
      return {'error': 'Failed to get search stats: $e'};
    }
  }

  /// Private conversion methods

  List<SearchResultEntity> _convertToSearchResultEntities(
    List<dynamic> models,
  ) {
    return models
        .whereType<SearchResultModel>()
        .map(
          (model) => SearchResultEntity(
            id: model.id,
            title: model.title,
            subtitle: model.subtitle,
            entityType: model.entityType,
            data: model.data,
            relevanceScore: model.relevanceScore,
            highlights: model.highlights,
            lastModified: model.lastModified,
          ),
        )
        .toList();
  }

  List<SearchSuggestionEntity> _convertToSuggestionEntities(
    List<SearchSuggestionModel> models,
  ) {
    return models
        .map(
          (model) => SearchSuggestionEntity(
            value: model.value,
            type: model.type,
            label: model.label,
            entity: model.entity,
            score: model.score,
            frequency: model.frequency,
            category: model.category,
            metadata: model.metadata,
          ),
        )
        .toList();
  }

  SearchFilterModel _convertToFilterModel(SearchFilterEntity entity) {
    return SearchFilterModel(
      plantCodes: entity.plantCodes,
      locationCodes: entity.locationCodes,
      unitCodes: entity.unitCodes,
      status: entity.status,
      roles: entity.roles,
      dateRange: entity.dateRange != null
          ? DateRangeFilter(
              from: entity.dateRange!.from,
              to: entity.dateRange!.to,
              preset: entity.dateRange!.preset,
            )
          : null,
      createdBy: entity.createdBy,
      customFilters: entity.customFilters,
    );
  }

  SearchMetaEntity _convertToSearchMeta(SearchMetaModel model) {
    return SearchMetaEntity(
      query: model.query,
      entities: model.entities,
      totalResults: model.totalResults,
      cached: model.cached,
      performance: model.performance != null
          ? SearchPerformanceEntity(
              durationMs: model.performance!.durationMs,
              totalResults: model.performance!.totalResults,
              performanceGrade: model.performance!.performanceGrade,
              timestamp: model.performance!.timestamp,
            )
          : null,
      pagination: model.pagination != null
          ? SearchPaginationEntity(
              currentPage: model.pagination!.currentPage,
              totalPages: model.pagination!.totalPages,
              totalItems: model.pagination!.totalItems,
              itemsPerPage: model.pagination!.itemsPerPage,
              hasNextPage: model.pagination!.hasNextPage,
              hasPrevPage: model.pagination!.hasPrevPage,
            )
          : null,
      relatedQueries: model.relatedQueries,
      searchOptions: model.searchOptions,
    );
  }

  /// Cache management methods

  @override
  Future<bool> isCacheValid(String query, Map<String, String> options) async {
    final cacheKey = cacheStrategy.generateCacheKey('search', query, options);
    return await cacheDataSource.isCacheValid(cacheKey);
  }

  @override
  Future<void> warmUpCache(List<String> popularQueries) async {
    for (final query in popularQueries) {
      try {
        await instantSearch(query, limit: 3);
      } catch (e) {
        // Ignore errors during warmup
      }
    }
  }

  @override
  Future<void> invalidateCache({String? query}) async {
    if (query != null) {
      // Invalidate specific query cache
      final keys = [
        cacheStrategy.generateCacheKey('instant', query, {}),
        cacheStrategy.generateCacheKey('global', query, {}),
      ];

      for (final key in keys) {
        await cacheDataSource.clearAllCache(); // Simplified - clear all
      }
    } else {
      // Clear all cache
      await cacheDataSource.clearAllCache();
    }
  }
}
