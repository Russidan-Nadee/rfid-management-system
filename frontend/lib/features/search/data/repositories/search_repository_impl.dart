// Path: frontend/lib/features/search/data/repositories/search_repository_impl.dart
import '../../domain/repositories/search_repository.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../domain/entities/search_suggestion_entity.dart';
import '../../domain/entities/search_filter_entity.dart';
import '../../domain/entities/search_history_entity.dart';
import '../../domain/entities/search_analytics_entity.dart';
import '../contracts/search_datasource_contracts.dart';
import '../models/search_filter_model.dart';
import '../models/search_response_model.dart';
import '../models/search_suggestion_model.dart';
import '../models/search_result_model.dart';
import '../exceptions/search_exceptions.dart';
import 'search_cache_strategy.dart';

/// Implementation of SearchRepository
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;
  final SearchCacheDataSource _cacheDataSource;
  final SearchCacheStrategy _cacheStrategy;

  SearchRepositoryImpl({
    required SearchRemoteDataSource remoteDataSource,
    required SearchCacheDataSource cacheDataSource,
    required SearchCacheStrategy cacheStrategy,
  }) : _remoteDataSource = remoteDataSource,
       _cacheDataSource = cacheDataSource,
       _cacheStrategy = cacheStrategy;

  @override
  Future<SearchResult<List<SearchResultEntity>>> instantSearch(
    String query, {
    List<String> entities = const ['assets'],
    int limit = 5,
    bool includeDetails = false,
  }) async {
    try {
      final cacheKey = _cacheStrategy.generateCacheKey('instant', query, {
        'entities': entities.join(','),
        'limit': limit.toString(),
        'details': includeDetails.toString(),
      });

      // Try cache first
      final cachedResponse = await _cacheDataSource.getCachedSearchResults(
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
      final response = await _remoteDataSource.instantSearch(
        query,
        entities: entities,
        limit: limit,
        includeDetails: includeDetails,
      );

      // Cache the response
      await _cacheStrategy.cacheSearchResults(cacheKey, response);

      // Save to search history
      await _cacheDataSource.saveSearchToHistory(query);

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
      final cachedSuggestions = await _cacheDataSource.getCachedSuggestions(
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
      final suggestions = await _remoteDataSource.getSuggestions(
        query,
        type: type,
        limit: limit,
        fuzzy: fuzzy,
      );

      // Cache suggestions
      await _cacheDataSource.cacheSuggestions(query, suggestions);

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
      final filterModel = filters != null
          ? _convertToFilterModel(filters)
          : null;

      final cacheKey = _cacheStrategy.generateCacheKey('global', query, {
        'entities': entities.join(','),
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
        'filters': filterModel?.toJson().toString() ?? '',
        'exact': exactMatch.toString(),
      });

      // Try cache for first page only
      if (page == 1) {
        final cachedResponse = await _cacheDataSource.getCachedSearchResults(
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
      final response = await _remoteDataSource.globalSearch(
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
        await _cacheStrategy.cacheSearchResults(cacheKey, response);
      }

      // Save to search history
      await _cacheDataSource.saveSearchToHistory(query);

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

      final response = await _remoteDataSource.advancedSearch(
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

      await _cacheDataSource.saveSearchToHistory(query);

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
      final localHistory = await _cacheDataSource.getSearchHistory(
        limit: limit,
      );
      if (localHistory.isNotEmpty) {
        return localHistory;
      }

      final remoteHistory = await _remoteDataSource.getRecentSearches(
        limit: limit,
      );
      for (final query in remoteHistory.reversed) {
        await _cacheDataSource.saveSearchToHistory(query);
      }
      return remoteHistory;
    } catch (e) {
      return await _cacheDataSource.getSearchHistory(limit: limit);
    }
  }

  @override
  Future<List<String>> getPopularSearches({int limit = 10}) async {
    try {
      final cachedPopular = await _cacheDataSource.getCachedPopularSearches();
      if (cachedPopular != null) {
        return cachedPopular.take(limit).toList();
      }

      final popular = await _remoteDataSource.getPopularSearches(limit: limit);
      await _cacheDataSource.cachePopularSearches(popular);
      return popular;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearSearchHistory() async {
    try {
      await Future.wait([
        _cacheDataSource.clearLocalSearchHistory(),
        _remoteDataSource.clearSearchHistory(),
      ]);
    } catch (e) {
      await _cacheDataSource.clearLocalSearchHistory();
    }
  }

  @override
  Future<SearchHistoryCollectionEntity> getDetailedSearchHistory({
    int limit = 50,
    DateTime? from,
    DateTime? to,
    String? queryFilter,
  }) async {
    try {
      // For now, return empty collection as detailed history implementation
      // would require additional API endpoints
      return SearchHistoryCollectionEntity.empty();
    } catch (e) {
      return SearchHistoryCollectionEntity.empty();
    }
  }

  @override
  Future<void> saveSearchToHistory(
    String query, {
    String searchType = 'instant',
    List<String> entities = const ['assets'],
    int resultsCount = 0,
    bool wasSuccessful = true,
    Map<String, dynamic>? filters,
  }) async {
    try {
      await _cacheDataSource.saveSearchToHistory(query);
    } catch (e) {
      // Silently fail
    }
  }

  @override
  Future<void> logSearchAnalytics(SearchAnalyticsEntity analytics) async {
    try {
      // For now, just log to console as analytics implementation
      // would require additional setup
      print('Search Analytics: ${analytics.toString()}');
    } catch (e) {
      // Silently fail
    }
  }

  @override
  Future<SearchStatisticsEntity> getSearchStatistics({
    String period = 'week',
    String? userId,
  }) async {
    try {
      // Return empty statistics for now
      return const SearchStatisticsEntity(
        period: 'week',
        totalSearches: 0,
        uniqueUsers: 0,
        uniqueQueries: 0,
        avgDuration: 0.0,
        avgResults: 0.0,
        successRate: 0.0,
        cacheHitRate: 0.0,
        topQueries: [],
        trends: [],
        searchTypeDistribution: {},
        entityDistribution: {},
      );
    } catch (e) {
      return const SearchStatisticsEntity(
        period: 'week',
        totalSearches: 0,
        uniqueUsers: 0,
        uniqueQueries: 0,
        avgDuration: 0.0,
        avgResults: 0.0,
        successRate: 0.0,
        cacheHitRate: 0.0,
        topQueries: [],
        trends: [],
        searchTypeDistribution: {},
        entityDistribution: {},
      );
    }
  }

  @override
  Future<UserSearchBehaviorEntity> getUserSearchBehavior(String userId) async {
    try {
      // Return empty behavior for now
      return UserSearchBehaviorEntity(
        userId: userId,
        totalSearches: 0,
        favoriteQueries: [],
        preferredEntities: [],
        avgSessionDuration: 0.0,
        sessionsCount: 0,
        firstSearch: DateTime.now(),
        lastSearch: DateTime.now(),
        searchPatterns: {},
      );
    } catch (e) {
      return UserSearchBehaviorEntity(
        userId: userId,
        totalSearches: 0,
        favoriteQueries: [],
        preferredEntities: [],
        avgSessionDuration: 0.0,
        sessionsCount: 0,
        firstSearch: DateTime.now(),
        lastSearch: DateTime.now(),
        searchPatterns: {},
      );
    }
  }

  @override
  Future<List<SearchSuggestionEntity>> getPersonalizedSuggestions(
    String userId, {
    int limit = 10,
  }) async {
    try {
      // For now, return popular searches as personalized suggestions
      final popular = await getPopularSearches(limit: limit);
      return popular
          .map(
            (query) =>
                SearchSuggestionEntity.popular(query: query, searchCount: 100),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<String>> getRelatedSearches(String query, {int limit = 5}) async {
    try {
      // Simple implementation - return popular searches that contain the query
      final popular = await getPopularSearches(limit: limit * 2);
      return popular
          .where(
            (search) =>
                search.toLowerCase().contains(query.toLowerCase()) &&
                search.toLowerCase() != query.toLowerCase(),
          )
          .take(limit)
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<SearchSuggestionEntity>> getSearchRecommendations(
    String userId, {
    List<String> preferredEntities = const ['assets'],
    int limit = 10,
  }) async {
    try {
      return await getPersonalizedSuggestions(userId, limit: limit);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, List<String>>> getFilterOptions(String entityType) async {
    try {
      // Return mock filter options
      switch (entityType.toLowerCase()) {
        case 'assets':
          return {
            'status': ['A', 'C', 'I'],
            'plant_codes': ['P001', 'P002', 'P003'],
            'location_codes': ['L001', 'L002', 'L003'],
          };
        case 'plants':
          return {
            'status': ['A', 'I'],
          };
        case 'users':
          return {
            'roles': ['admin', 'manager', 'user'],
          };
        default:
          return {};
      }
    } catch (e) {
      return {};
    }
  }

  @override
  Future<bool> validateFilters(
    SearchFilterEntity filters,
    List<String> entities,
  ) async {
    try {
      // Simple validation - check if filters are applicable to entities
      return filters.isApplicableToEntity(entities.first);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getFilterSuggestions(
    String filterType,
    String partialValue, {
    int limit = 10,
  }) async {
    try {
      final filterOptions = await getFilterOptions(filterType);
      final allValues = filterOptions.values.expand((list) => list).toList();

      return allValues
          .where(
            (value) => value.toLowerCase().contains(partialValue.toLowerCase()),
          )
          .take(limit)
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearSearchCache() async {
    await _cacheDataSource.clearAllCache();
  }

  @override
  Future<bool> isCacheValid(String query, Map<String, String> options) async {
    final cacheKey = _cacheStrategy.generateCacheKey('search', query, options);
    return await _cacheDataSource.isCacheValid(cacheKey);
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
      // Individual key clearance could be implemented here
      // For now, clear all cache as a simplified approach
      await _cacheDataSource.clearAllCache();
    } else {
      await _cacheDataSource.clearAllCache();
    }
  }

  @override
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final cacheStats = await _cacheDataSource.getCacheStats();
      return {'cache': cacheStats, 'cache_strategy': _cacheStrategy.getStats()};
    } catch (e) {
      return {'error': 'Failed to get cache stats: $e'};
    }
  }

  @override
  Future<Map<String, dynamic>> getSearchConfig() async {
    return {
      'default_entities': ['assets'],
      'max_results_per_page': 100,
      'cache_timeout_minutes': 5,
      'supported_entity_types': ['assets', 'plants', 'locations', 'users'],
    };
  }

  @override
  Future<void> updateSearchPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    try {
      // For now, just log the preferences
      print('Updated search preferences for $userId: $preferences');
    } catch (e) {
      // Silently fail
    }
  }

  @override
  Future<Map<String, dynamic>> getSearchHealth() async {
    try {
      final cacheStats = await getCacheStats();
      return {
        'status': 'healthy',
        'cache_health': cacheStats,
        'last_check': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'status': 'unhealthy',
        'error': e.toString(),
        'last_check': DateTime.now().toIso8601String(),
      };
    }
  }

  @override
  Future<String> exportSearchData(
    String userId, {
    DateTime? from,
    DateTime? to,
    String format = 'json',
  }) async {
    try {
      final history = await getDetailedSearchHistory(
        limit: 1000,
        from: from,
        to: to,
      );

      return 'Export data for $userId (${history.totalCount} items)';
    } catch (e) {
      return 'Export failed: $e';
    }
  }

  @override
  Future<void> importSearchData(
    String userId,
    String data,
    String format,
  ) async {
    try {
      // For now, just log the import
      print('Imported search data for $userId: ${data.length} characters');
    } catch (e) {
      throw Exception('Import failed: $e');
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
}
