// Path: frontend/lib/features/search/data/datasources/remote/search_remote_datasource_impl.dart
import '../../../../../core/services/api_service.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../contracts/search_datasource_contracts.dart';
import '../../models/search_response_model.dart';
import '../../models/search_suggestion_model.dart';
import '../../models/search_filter_model.dart';
import '../../exceptions/search_exceptions.dart';

/// Implementation of SearchRemoteDataSource
/// Handles all API calls to the backend search endpoints
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiService apiService;

  SearchRemoteDataSourceImpl(this.apiService);

  @override
  Future<SearchResponseModel> instantSearch(
    String query, {
    List<String> entities = const ['assets'],
    int limit = 5,
    bool includeDetails = false,
  }) async {
    try {
      // Validate query
      _validateSearchQuery(query);

      final queryParams = {
        'q': query,
        'entities': entities.join(','),
        'limit': limit.toString(),
        'include_details': includeDetails.toString(),
      };

      final response = await apiService.get<Map<String, dynamic>>(
        '/search/instant',
        queryParams: queryParams,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return SearchResponseModel.fromJson(response.data!);
      } else {
        throw SearchException(response.message);
      }
    } catch (e) {
      throw createSearchExceptionFromError(e);
    }
  }

  @override
  Future<List<SearchSuggestionModel>> getSuggestions(
    String query, {
    String type = 'all',
    int limit = 5,
    bool fuzzy = false,
  }) async {
    try {
      // Validate query (suggestions can be shorter)
      if (query.isEmpty) {
        throw SearchQueryTooShortException(minLength: 1);
      }

      final queryParams = {
        'q': query,
        'type': type,
        'limit': limit.toString(),
        'fuzzy': fuzzy.toString(),
      };

      final response = await apiService.get<List<dynamic>>(
        '/search/suggestions',
        queryParams: queryParams,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map(
              (json) =>
                  SearchSuggestionModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        return []; // Return empty list for suggestions if failed
      }
    } catch (e) {
      // Don't throw for suggestions - return empty list
      return [];
    }
  }

  @override
  Future<SearchResponseModel> globalSearch(
    String query, {
    List<String> entities = const ['assets'],
    int page = 1,
    int limit = 20,
    String sort = 'relevance',
    SearchFilterModel? filters,
    bool exactMatch = false,
  }) async {
    try {
      _validateSearchQuery(query, minLength: 2);

      final queryParams = {
        'q': query,
        'entities': entities.join(','),
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
        'exact_match': exactMatch.toString(),
      };

      // Add filters if provided
      if (filters != null && filters.hasFilters) {
        queryParams['filters'] = _encodeFilters(filters);
      }

      final response = await apiService.get<Map<String, dynamic>>(
        '/search/global',
        queryParams: queryParams,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return SearchResponseModel.fromJson(response.data!);
      } else {
        throw SearchException(response.message);
      }
    } catch (e) {
      throw createSearchExceptionFromError(e);
    }
  }

  @override
  Future<SearchResponseModel> advancedSearch(
    String query, {
    List<String> entities = const ['assets'],
    int page = 1,
    int limit = 20,
    String sort = 'relevance',
    SearchFilterModel? filters,
    bool exactMatch = false,
    bool includeAnalytics = true,
    bool includeRelated = true,
    bool highlightMatches = true,
  }) async {
    try {
      _validateSearchQuery(query, minLength: 2);

      final queryParams = {
        'q': query,
        'entities': entities.join(','),
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
        'exact_match': exactMatch.toString(),
        'include_analytics': includeAnalytics.toString(),
        'include_related': includeRelated.toString(),
        'highlight_matches': highlightMatches.toString(),
      };

      // Add filters if provided
      if (filters != null && filters.hasFilters) {
        queryParams['filters'] = _encodeFilters(filters);
      }

      final response = await apiService.get<Map<String, dynamic>>(
        '/search/advanced',
        queryParams: queryParams,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return SearchResponseModel.fromJson(response.data!);
      } else {
        throw SearchException(response.message);
      }
    } catch (e) {
      throw createSearchExceptionFromError(e);
    }
  }

  @override
  Future<List<String>> getRecentSearches({
    int limit = 10,
    int days = 30,
  }) async {
    try {
      final queryParams = {'limit': limit.toString(), 'days': days.toString()};

      final response = await apiService.get<List<dynamic>>(
        '/search/recent',
        queryParams: queryParams,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((item) => item['query']?.toString() ?? item.toString())
            .where((query) => query.isNotEmpty)
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      // Return empty list if failed
      return [];
    }
  }

  @override
  Future<List<String>> getPopularSearches({
    int limit = 10,
    int days = 7,
  }) async {
    try {
      final queryParams = {'limit': limit.toString(), 'days': days.toString()};

      final response = await apiService.get<List<dynamic>>(
        '/search/popular',
        queryParams: queryParams,
        requiresAuth: false, // Popular searches can be public
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((item) => item['query']?.toString() ?? item.toString())
            .where((query) => query.isNotEmpty)
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearSearchHistory() async {
    try {
      final response = await apiService.delete<void>(
        '/search/recent',
        requiresAuth: false,
      );

      if (!response.success) {
        throw SearchException(
          'Failed to clear search history: ${response.message}',
        );
      }
    } catch (e) {
      throw createSearchExceptionFromError(e);
    }
  }

  /// Private helper methods

  /// Validate search query
  void _validateSearchQuery(String query, {int minLength = 1}) {
    if (query.isEmpty) {
      throw SearchQueryTooShortException(minLength: minLength);
    }

    if (query.length < minLength) {
      throw SearchQueryTooShortException(minLength: minLength);
    }

    if (query.length > 200) {
      throw SearchQueryTooLongException();
    }

    // Check for invalid characters
    if (query.contains(RegExp(r'[<>{}()[\]\\\/]'))) {
      throw SearchQueryInvalidCharactersException();
    }
  }

  /// Encode filters to JSON string for API
  String _encodeFilters(SearchFilterModel filters) {
    try {
      final filtersJson = filters.toJson();
      return Uri.encodeComponent(
        filtersJson.entries
            .where((entry) => entry.value != null)
            .map((entry) => '${entry.key}:${entry.value}')
            .join(','),
      );
    } catch (e) {
      throw SearchFilterException('Failed to encode filters: $e');
    }
  }

  /// Handle rate limiting
  void _handleRateLimit(Map<String, String>? headers) {
    if (headers != null) {
      final remaining = headers['X-RateLimit-Remaining'];
      final resetTime = headers['X-RateLimit-Reset'];

      if (remaining == '0') {
        throw SearchRateLimitException();
      }
    }
  }

  /// Create timeout-aware request
  Future<T> _requestWithTimeout<T>(
    Future<T> Function() request, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      return await request().timeout(timeout);
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw SearchTimeoutException();
      }
      rethrow;
    }
  }

  /// Batch search requests for multiple entities
  Future<Map<String, SearchResponseModel>> batchSearch(
    String query,
    List<String> entities, {
    int limit = 5,
  }) async {
    final results = <String, SearchResponseModel>{};

    // Execute searches in parallel for each entity
    final futures = entities.map((entity) async {
      try {
        final result = await instantSearch(
          query,
          entities: [entity],
          limit: limit,
        );
        return MapEntry(entity, result);
      } catch (e) {
        // Return empty result for failed entity
        return MapEntry(
          entity,
          SearchResponseModel(
            success: false,
            message: 'Failed to search $entity',
            results: {},
            timestamp: DateTime.now(),
          ),
        );
      }
    });

    final responses = await Future.wait(futures);

    for (final response in responses) {
      results[response.key] = response.value;
    }

    return results;
  }

  /// Search with retry logic
  Future<SearchResponseModel> searchWithRetry(
    String query, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await instantSearch(query);
      } catch (e) {
        attempts++;

        if (attempts >= maxRetries) {
          rethrow;
        }

        // Wait before retry
        await Future.delayed(retryDelay * attempts);
      }
    }

    throw SearchException('Max retries exceeded');
  }

  /// Get search statistics (admin only)
  Future<Map<String, dynamic>> getSearchStats({
    String period = 'week',
    String entity = 'all',
  }) async {
    try {
      final queryParams = {'period': period, 'entity': entity};

      final response = await apiService.get<Map<String, dynamic>>(
        '/search/stats',
        queryParams: queryParams,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  /// Rebuild search index (admin only)
  Future<void> rebuildSearchIndex() async {
    try {
      final response = await apiService.post<void>(
        '/search/reindex',
        requiresAuth: false,
      );

      if (!response.success) {
        throw SearchException(
          'Failed to rebuild search index: ${response.message}',
        );
      }
    } catch (e) {
      throw createSearchExceptionFromError(e);
    }
  }
}
