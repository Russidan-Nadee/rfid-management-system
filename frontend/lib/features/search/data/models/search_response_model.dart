// Path: frontend/lib/features/search/data/models/search_response_model.dart
import 'package:equatable/equatable.dart';
import 'search_result_model.dart';

/// Search response model that wraps API responses
class SearchResponseModel extends Equatable {
  final bool success;
  final String message;
  final Map<String, List<SearchResultModel>> results;
  final SearchMetaModel? meta;
  final DateTime timestamp;
  final List<String>? errors;

  const SearchResponseModel({
    required this.success,
    required this.message,
    required this.results,
    this.meta,
    required this.timestamp,
    this.errors,
  });

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, List<SearchResultModel>> parsedResults = {};

    // Parse results by entity type
    if (json['data'] != null) {
      final data = json['data'] as Map<String, dynamic>;

      for (final entry in data.entries) {
        final entityType = entry.key;
        final entityData = entry.value;

        if (entityData is List) {
          parsedResults[entityType] = entityData
              .map(
                (item) => createSearchResultModel(item as Map<String, dynamic>),
              )
              .toList();
        }
      }
    }

    return SearchResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      results: parsedResults,
      meta: json['meta'] != null
          ? SearchMetaModel.fromJson(json['meta'])
          : null,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    // Convert results back to JSON format
    for (final entry in results.entries) {
      data[entry.key] = entry.value
          .map(
            (result) => result.toJson((data) => data as Map<String, dynamic>),
          )
          .toList();
    }

    return {
      'success': success,
      'message': message,
      'data': data,
      if (meta != null) 'meta': meta!.toJson(),
      'timestamp': timestamp.toIso8601String(),
      if (errors != null) 'errors': errors,
    };
  }

  SearchResponseModel copyWith({
    bool? success,
    String? message,
    Map<String, List<SearchResultModel>>? results,
    SearchMetaModel? meta,
    DateTime? timestamp,
    List<String>? errors,
  }) {
    return SearchResponseModel(
      success: success ?? this.success,
      message: message ?? this.message,
      results: results ?? this.results,
      meta: meta ?? this.meta,
      timestamp: timestamp ?? this.timestamp,
      errors: errors ?? this.errors,
    );
  }

  /// Get total number of results across all entities
  int get totalResults {
    return results.values.fold(0, (sum, list) => sum + list.length);
  }

  /// Get results for specific entity type
  List<SearchResultModel> getResultsForEntity(String entityType) {
    return results[entityType] ?? [];
  }

  /// Get all results as a flat list
  List<SearchResultModel> get allResults {
    return results.values.expand((list) => list).toList();
  }

  /// Check if response has any results
  bool get hasResults => totalResults > 0;

  /// Check if response has errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  /// Get first error message
  String? get firstError => hasErrors ? errors!.first : null;

  /// Sort all results by relevance score
  List<SearchResultModel> get sortedByRelevance {
    final allResultsList = allResults;
    allResultsList.sort((a, b) {
      final aScore = a.relevanceScore ?? 0.0;
      final bScore = b.relevanceScore ?? 0.0;
      return bScore.compareTo(aScore);
    });
    return allResultsList;
  }

  /// Get entity types that have results
  List<String> get entitiesWithResults {
    return results.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  List<Object?> get props => [
    success,
    message,
    results,
    meta,
    timestamp,
    errors,
  ];

  @override
  String toString() {
    return 'SearchResponseModel(success: $success, totalResults: $totalResults, entities: ${results.keys.join(', ')})';
  }
}

/// Search metadata model for pagination and performance info
class SearchMetaModel extends Equatable {
  final String query;
  final List<String> entities;
  final int totalResults;
  final bool cached;
  final SearchPerformanceModel? performance;
  final SearchPaginationModel? pagination;
  final SearchAnalyticsModel? analytics;
  final List<String>? relatedQueries;
  final Map<String, dynamic>? searchOptions;

  const SearchMetaModel({
    required this.query,
    required this.entities,
    required this.totalResults,
    this.cached = false,
    this.performance,
    this.pagination,
    this.analytics,
    this.relatedQueries,
    this.searchOptions,
  });

  factory SearchMetaModel.fromJson(Map<String, dynamic> json) {
    return SearchMetaModel(
      query: json['query'] ?? '',
      entities: json['entities'] != null
          ? List<String>.from(json['entities'])
          : [],
      totalResults: json['totalResults'] ?? json['total_results'] ?? 0,
      cached: json['cached'] ?? false,
      performance: json['performance'] != null
          ? SearchPerformanceModel.fromJson(json['performance'])
          : null,
      pagination: json['pagination'] != null
          ? SearchPaginationModel.fromJson(json['pagination'])
          : null,
      analytics: json['analytics'] != null
          ? SearchAnalyticsModel.fromJson(json['analytics'])
          : null,
      relatedQueries: json['relatedQueries'] != null
          ? List<String>.from(json['relatedQueries'])
          : json['related_queries'] != null
          ? List<String>.from(json['related_queries'])
          : null,
      searchOptions: json['searchOptions'] ?? json['search_options'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'entities': entities,
      'totalResults': totalResults,
      'cached': cached,
      if (performance != null) 'performance': performance!.toJson(),
      if (pagination != null) 'pagination': pagination!.toJson(),
      if (analytics != null) 'analytics': analytics!.toJson(),
      if (relatedQueries != null) 'relatedQueries': relatedQueries,
      if (searchOptions != null) 'searchOptions': searchOptions,
    };
  }

  SearchMetaModel copyWith({
    String? query,
    List<String>? entities,
    int? totalResults,
    bool? cached,
    SearchPerformanceModel? performance,
    SearchPaginationModel? pagination,
    SearchAnalyticsModel? analytics,
    List<String>? relatedQueries,
    Map<String, dynamic>? searchOptions,
  }) {
    return SearchMetaModel(
      query: query ?? this.query,
      entities: entities ?? this.entities,
      totalResults: totalResults ?? this.totalResults,
      cached: cached ?? this.cached,
      performance: performance ?? this.performance,
      pagination: pagination ?? this.pagination,
      analytics: analytics ?? this.analytics,
      relatedQueries: relatedQueries ?? this.relatedQueries,
      searchOptions: searchOptions ?? this.searchOptions,
    );
  }

  @override
  List<Object?> get props => [
    query,
    entities,
    totalResults,
    cached,
    performance,
    pagination,
    analytics,
    relatedQueries,
    searchOptions,
  ];

  @override
  String toString() {
    return 'SearchMetaModel(query: "$query", totalResults: $totalResults, cached: $cached)';
  }
}

/// Search performance metrics
class SearchPerformanceModel extends Equatable {
  final int durationMs;
  final int totalResults;
  final String performanceGrade;
  final DateTime timestamp;

  const SearchPerformanceModel({
    required this.durationMs,
    required this.totalResults,
    required this.performanceGrade,
    required this.timestamp,
  });

  factory SearchPerformanceModel.fromJson(Map<String, dynamic> json) {
    return SearchPerformanceModel(
      durationMs: json['duration_ms'] ?? json['durationMs'] ?? 0,
      totalResults: json['total_results'] ?? json['totalResults'] ?? 0,
      performanceGrade:
          json['performance_grade'] ?? json['performanceGrade'] ?? 'N/A',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration_ms': durationMs,
      'total_results': totalResults,
      'performance_grade': performanceGrade,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Check if search was fast (< 200ms)
  bool get isFast => durationMs < 200;

  /// Check if search was slow (> 1000ms)
  bool get isSlow => durationMs > 1000;

  /// Get performance description
  String get description {
    if (durationMs < 100) return 'Excellent';
    if (durationMs < 200) return 'Fast';
    if (durationMs < 500) return 'Good';
    if (durationMs < 1000) return 'Average';
    return 'Slow';
  }

  @override
  List<Object?> get props => [
    durationMs,
    totalResults,
    performanceGrade,
    timestamp,
  ];

  @override
  String toString() {
    return 'SearchPerformanceModel(${durationMs}ms, $performanceGrade)';
  }
}

/// Search pagination information
class SearchPaginationModel extends Equatable {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPrevPage;

  const SearchPaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory SearchPaginationModel.fromJson(Map<String, dynamic> json) {
    return SearchPaginationModel(
      currentPage: json['currentPage'] ?? json['current_page'] ?? 1,
      totalPages: json['totalPages'] ?? json['total_pages'] ?? 1,
      totalItems: json['totalItems'] ?? json['total_items'] ?? 0,
      itemsPerPage: json['itemsPerPage'] ?? json['items_per_page'] ?? 20,
      hasNextPage: json['hasNextPage'] ?? json['has_next_page'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? json['has_prev_page'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
    };
  }

  /// Get range of items on current page
  String get itemRange {
    final start = (currentPage - 1) * itemsPerPage + 1;
    final end = (start + itemsPerPage - 1).clamp(start, totalItems);
    return '$start-$end of $totalItems';
  }

  @override
  List<Object?> get props => [
    currentPage,
    totalPages,
    totalItems,
    itemsPerPage,
    hasNextPage,
    hasPrevPage,
  ];

  @override
  String toString() {
    return 'SearchPaginationModel(page $currentPage of $totalPages, $itemRange)';
  }
}

/// Search analytics information
class SearchAnalyticsModel extends Equatable {
  final int searchCount;
  final double avgResults;
  final double avgDuration;
  final int popularityRank;

  const SearchAnalyticsModel({
    required this.searchCount,
    required this.avgResults,
    required this.avgDuration,
    required this.popularityRank,
  });

  factory SearchAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return SearchAnalyticsModel(
      searchCount: json['searchCount'] ?? json['search_count'] ?? 0,
      avgResults: (json['avgResults'] ?? json['avg_results'] ?? 0).toDouble(),
      avgDuration: (json['avgDuration'] ?? json['avg_duration'] ?? 0)
          .toDouble(),
      popularityRank: json['popularityRank'] ?? json['popularity_rank'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'searchCount': searchCount,
      'avgResults': avgResults,
      'avgDuration': avgDuration,
      'popularityRank': popularityRank,
    };
  }

  @override
  List<Object?> get props => [
    searchCount,
    avgResults,
    avgDuration,
    popularityRank,
  ];

  @override
  String toString() {
    return 'SearchAnalyticsModel(searches: $searchCount, avgResults: $avgResults, rank: $popularityRank)';
  }
}
