// Path: frontend/lib/features/search/domain/usecases/instant_search_usecase.dart
import '../entities/search_result_entity.dart';
import '../entities/search_filter_entity.dart';
import '../repositories/search_repository.dart';

/// Use case for instant search functionality
/// Provides fast, real-time search results with minimal latency
class InstantSearchUseCase {
  final SearchRepository repository;

  InstantSearchUseCase(this.repository);

  /// Execute instant search with validation and optimization
  ///
  /// Parameters:
  /// - [query]: Search query string (required, min 1 character)
  /// - [entities]: List of entity types to search (default: ['assets'])
  /// - [limit]: Maximum results per entity (default: 5, max: 10)
  /// - [includeDetails]: Whether to include full entity details
  ///
  /// Returns:
  /// - [InstantSearchResult] with search results and metadata
  Future<InstantSearchResult> execute({
    required String query,
    List<String> entities = const ['assets'],
    int limit = 5,
    bool includeDetails = false,
  }) async {
    final startTime = DateTime.now();

    try {
      // Validate input parameters
      final validation = _validateInput(query, entities, limit);
      if (!validation.isValid) {
        return InstantSearchResult.invalid(validation.errorMessage!);
      }

      // Sanitize and optimize query
      final optimizedQuery = _optimizeQuery(query);

      // Optimize entities list
      final optimizedEntities = _optimizeEntities(entities);

      // Execute search with timeout protection
      final result = await _executeWithTimeout(
        () => repository.instantSearch(
          optimizedQuery,
          entities: optimizedEntities,
          limit: limit.clamp(1, 10),
          includeDetails: includeDetails,
        ),
        timeout: const Duration(seconds: 5),
      );

      // Calculate performance metrics
      final duration = DateTime.now().difference(startTime);

      if (result.success && result.data != null) {
        // Log search analytics asynchronously
        _logSearchAnalytics(
          query: optimizedQuery,
          entities: optimizedEntities,
          resultsCount: result.data!.length,
          duration: duration,
          success: true,
        );

        return InstantSearchResult.success(
          results: result.data!,
          query: optimizedQuery,
          entities: optimizedEntities,
          totalResults: result.totalResults,
          fromCache: result.fromCache,
          duration: duration,
          meta: result.meta,
        );
      } else {
        // Log failed search
        _logSearchAnalytics(
          query: optimizedQuery,
          entities: optimizedEntities,
          resultsCount: 0,
          duration: duration,
          success: false,
          error: result.error,
        );

        return InstantSearchResult.failure(
          error: result.error ?? 'Search failed',
          query: optimizedQuery,
          duration: duration,
        );
      }
    } catch (e) {
      final duration = DateTime.now().difference(startTime);

      // Log exception
      _logSearchAnalytics(
        query: query,
        entities: entities,
        resultsCount: 0,
        duration: duration,
        success: false,
        error: e.toString(),
      );

      return InstantSearchResult.failure(
        error: 'Unexpected error: ${e.toString()}',
        query: query,
        duration: duration,
      );
    }
  }

  /// Execute search with multiple entity types in parallel
  Future<InstantSearchResult> executeMultiEntity({
    required String query,
    required List<String> entities,
    int limitPerEntity = 3,
    bool includeDetails = false,
  }) async {
    final startTime = DateTime.now();

    try {
      // Validate input
      final validation = _validateInput(query, entities, limitPerEntity);
      if (!validation.isValid) {
        return InstantSearchResult.invalid(validation.errorMessage!);
      }

      final optimizedQuery = _optimizeQuery(query);

      // Execute searches for each entity type in parallel
      final futures = entities.map(
        (entity) => repository.instantSearch(
          optimizedQuery,
          entities: [entity],
          limit: limitPerEntity,
          includeDetails: includeDetails,
        ),
      );

      final results = await Future.wait(futures);

      // Combine and rank results
      final combinedResults = <SearchResultEntity>[];
      int totalResults = 0;
      bool anyFromCache = false;

      for (final result in results) {
        if (result.success && result.data != null) {
          combinedResults.addAll(result.data!);
          totalResults += result.totalResults;
          if (result.fromCache) anyFromCache = true;
        }
      }

      // Sort by relevance score
      combinedResults.sort((a, b) {
        final aScore = a.relevanceScore ?? 0.0;
        final bScore = b.relevanceScore ?? 0.0;
        final scoreCompare = bScore.compareTo(aScore);

        // If scores are equal, sort by entity priority
        if (scoreCompare == 0) {
          return a.displayPriority.compareTo(b.displayPriority);
        }

        return scoreCompare;
      });

      final duration = DateTime.now().difference(startTime);

      return InstantSearchResult.success(
        results: combinedResults,
        query: optimizedQuery,
        entities: entities,
        totalResults: totalResults,
        fromCache: anyFromCache,
        duration: duration,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      return InstantSearchResult.failure(
        error: e.toString(),
        query: query,
        duration: duration,
      );
    }
  }

  /// Get search suggestions for autocomplete
  Future<List<String>> getQuickSuggestions(
    String query, {
    int limit = 5,
  }) async {
    if (query.isEmpty) return [];

    try {
      final result = await repository.getSuggestions(
        query,
        type: 'all',
        limit: limit,
      );

      if (result.success && result.data != null) {
        return result.data!.map((suggestion) => suggestion.value).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Check if query is suitable for instant search
  bool isValidForInstantSearch(String query) {
    return _validateInput(query, ['assets'], 5).isValid;
  }

  /// Get optimized parameters for instant search
  InstantSearchParameters getOptimizedParameters({
    required String query,
    List<String>? entities,
    int? limit,
  }) {
    return InstantSearchParameters(
      query: _optimizeQuery(query),
      entities: _optimizeEntities(entities ?? ['assets']),
      limit: (limit ?? 5).clamp(1, 10),
    );
  }

  /// Private helper methods

  /// Validate input parameters
  ValidationResult _validateInput(
    String query,
    List<String> entities,
    int limit,
  ) {
    // Validate query
    if (query.isEmpty) {
      return ValidationResult.invalid('Search query cannot be empty');
    }

    if (query.trim().isEmpty) {
      return ValidationResult.invalid('Search query cannot be only whitespace');
    }

    if (query.length > 200) {
      return ValidationResult.invalid(
        'Search query too long (max 200 characters)',
      );
    }

    // Check for potentially malicious input
    if (_containsSuspiciousContent(query)) {
      return ValidationResult.invalid(
        'Search query contains invalid characters',
      );
    }

    // Validate entities
    if (entities.isEmpty) {
      return ValidationResult.invalid(
        'At least one entity type must be specified',
      );
    }

    final validEntities = ['assets', 'plants', 'locations', 'users'];
    final invalidEntities = entities
        .where((e) => !validEntities.contains(e))
        .toList();

    if (invalidEntities.isNotEmpty) {
      return ValidationResult.invalid(
        'Invalid entity types: ${invalidEntities.join(', ')}',
      );
    }

    if (entities.length > 4) {
      return ValidationResult.invalid('Too many entity types (max 4)');
    }

    // Validate limit
    if (limit < 1 || limit > 10) {
      return ValidationResult.invalid(
        'Limit must be between 1 and 10 for instant search',
      );
    }

    return ValidationResult.valid();
  }

  /// Optimize search query for better performance
  String _optimizeQuery(String query) {
    return query
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .toLowerCase();
  }

  /// Optimize entities list based on search patterns
  List<String> _optimizeEntities(List<String> entities) {
    // Sort entities by search priority (assets first for better performance)
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

  /// Check for suspicious content in query
  bool _containsSuspiciousContent(String query) {
    final suspiciousPatterns = [
      RegExp(r'[<>{}()[\]\\\/]'), // Special characters
      RegExp(
        r'(script|javascript|vbscript)',
        caseSensitive: false,
      ), // Script tags
      RegExp(
        r'(union|select|drop|delete|insert)',
        caseSensitive: false,
      ), // SQL injection
    ];

    return suspiciousPatterns.any((pattern) => pattern.hasMatch(query));
  }

  /// Execute operation with timeout protection
  Future<T> _executeWithTimeout<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      return await operation().timeout(timeout);
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception(
          'Search timeout - please try again with a shorter query',
        );
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
    required bool success,
    String? error,
  }) {
    // Fire and forget - don't await
    Future.microtask(() async {
      try {
        await repository.saveSearchToHistory(
          query,
          searchType: 'instant',
          entities: entities,
          resultsCount: resultsCount,
          wasSuccessful: success,
        );
      } catch (e) {
        // Ignore logging errors
      }
    });
  }
}

/// Result wrapper for instant search operations
class InstantSearchResult {
  final bool success;
  final List<SearchResultEntity>? results;
  final String query;
  final List<String>? entities;
  final int? totalResults;
  final bool? fromCache;
  final Duration? duration;
  final SearchMetaEntity? meta;
  final String? error;

  const InstantSearchResult({
    required this.success,
    this.results,
    required this.query,
    this.entities,
    this.totalResults,
    this.fromCache,
    this.duration,
    this.meta,
    this.error,
  });

  factory InstantSearchResult.success({
    required List<SearchResultEntity> results,
    required String query,
    required List<String> entities,
    required int totalResults,
    bool fromCache = false,
    Duration? duration,
    SearchMetaEntity? meta,
  }) {
    return InstantSearchResult(
      success: true,
      results: results,
      query: query,
      entities: entities,
      totalResults: totalResults,
      fromCache: fromCache,
      duration: duration,
      meta: meta,
    );
  }

  factory InstantSearchResult.failure({
    required String error,
    required String query,
    Duration? duration,
  }) {
    return InstantSearchResult(
      success: false,
      query: query,
      error: error,
      duration: duration,
    );
  }

  factory InstantSearchResult.invalid(String error) {
    return InstantSearchResult(success: false, query: '', error: error);
  }

  bool get hasResults => success && results != null && results!.isNotEmpty;
  bool get isEmpty => success && (results == null || results!.isEmpty);
  bool get hasError => !success || error != null;
  bool get isFast => duration != null && duration!.inMilliseconds < 200;
  bool get isSlow => duration != null && duration!.inMilliseconds > 1000;
}

/// Validation result helper
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({required this.isValid, this.errorMessage});

  factory ValidationResult.valid() => const ValidationResult(isValid: true);

  factory ValidationResult.invalid(String message) =>
      ValidationResult(isValid: false, errorMessage: message);
}

/// Optimized search parameters
class InstantSearchParameters {
  final String query;
  final List<String> entities;
  final int limit;

  const InstantSearchParameters({
    required this.query,
    required this.entities,
    required this.limit,
  });
}
