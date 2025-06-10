// Path: frontend/lib/features/search/domain/entities/search_meta_entity.dart
import 'package:equatable/equatable.dart';

/// Search metadata entity containing performance and pagination info
class SearchMetaEntity extends Equatable {
  final String query;
  final List<String> entities;
  final int totalResults;
  final bool cached;
  final SearchPerformanceEntity? performance;
  final SearchPaginationEntity? pagination;
  final List<String>? relatedQueries;
  final Map<String, dynamic>? searchOptions;

  const SearchMetaEntity({
    required this.query,
    required this.entities,
    required this.totalResults,
    this.cached = false,
    this.performance,
    this.pagination,
    this.relatedQueries,
    this.searchOptions,
  });

  /// Factory constructors for different search types
  factory SearchMetaEntity.instant({
    required String query,
    required List<String> entities,
    required int totalResults,
    bool cached = false,
    SearchPerformanceEntity? performance,
  }) {
    return SearchMetaEntity(
      query: query,
      entities: entities,
      totalResults: totalResults,
      cached: cached,
      performance: performance,
    );
  }

  factory SearchMetaEntity.paginated({
    required String query,
    required List<String> entities,
    required int totalResults,
    required SearchPaginationEntity pagination,
    bool cached = false,
    SearchPerformanceEntity? performance,
    List<String>? relatedQueries,
  }) {
    return SearchMetaEntity(
      query: query,
      entities: entities,
      totalResults: totalResults,
      cached: cached,
      performance: performance,
      pagination: pagination,
      relatedQueries: relatedQueries,
    );
  }

  /// Business logic methods

  /// Check if search has results
  bool get hasResults => totalResults > 0;

  /// Check if search was fast
  bool get isFastSearch => performance?.isFast ?? false;

  /// Check if search was slow
  bool get isSlowSearch => performance?.isSlow ?? false;

  /// Get performance grade description
  String get performanceDescription => performance?.description ?? 'Unknown';

  /// Check if search has pagination
  bool get hasPagination => pagination != null;

  /// Check if there are more pages
  bool get hasMorePages => pagination?.hasNextPage ?? false;

  /// Check if there are related queries
  bool get hasRelatedQueries =>
      relatedQueries != null && relatedQueries!.isNotEmpty;

  /// Get search summary
  String get searchSummary {
    final entityText = entities.length == 1
        ? entities.first
        : '${entities.length} entity types';

    final resultText = totalResults == 1 ? '1 result' : '$totalResults results';

    final cacheText = cached ? ' (cached)' : '';

    return 'Found $resultText in $entityText$cacheText';
  }

  /// Get performance summary
  String get performanceSummary {
    if (performance == null) return '';

    final duration = performance!.durationMs;
    final grade = performance!.performanceGrade;

    return 'Search completed in ${duration}ms ($grade)';
  }

  /// Get pagination summary
  String get paginationSummary {
    if (pagination == null) return '';

    return pagination!.itemRange;
  }

  /// Create copy with updated fields
  SearchMetaEntity copyWith({
    String? query,
    List<String>? entities,
    int? totalResults,
    bool? cached,
    SearchPerformanceEntity? performance,
    SearchPaginationEntity? pagination,
    List<String>? relatedQueries,
    Map<String, dynamic>? searchOptions,
  }) {
    return SearchMetaEntity(
      query: query ?? this.query,
      entities: entities ?? this.entities,
      totalResults: totalResults ?? this.totalResults,
      cached: cached ?? this.cached,
      performance: performance ?? this.performance,
      pagination: pagination ?? this.pagination,
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
    relatedQueries,
    searchOptions,
  ];

  @override
  String toString() {
    return 'SearchMetaEntity(query: "$query", totalResults: $totalResults, cached: $cached)';
  }
}

/// Search performance entity
class SearchPerformanceEntity extends Equatable {
  final int durationMs;
  final int totalResults;
  final String performanceGrade;
  final DateTime timestamp;

  const SearchPerformanceEntity({
    required this.durationMs,
    required this.totalResults,
    required this.performanceGrade,
    required this.timestamp,
  });

  /// Factory constructors
  factory SearchPerformanceEntity.fromDuration(
    int durationMs,
    int totalResults,
  ) {
    return SearchPerformanceEntity(
      durationMs: durationMs,
      totalResults: totalResults,
      performanceGrade: _calculateGrade(durationMs),
      timestamp: DateTime.now(),
    );
  }

  /// Business logic methods

  /// Check if search was fast (< 200ms)
  bool get isFast => durationMs < 200;

  /// Check if search was slow (> 1000ms)
  bool get isSlow => durationMs > 1000;

  /// Check if search was very slow (> 5000ms)
  bool get isVerySlow => durationMs > 5000;

  /// Get performance description
  String get description {
    if (durationMs < 100) return 'Excellent';
    if (durationMs < 200) return 'Fast';
    if (durationMs < 500) return 'Good';
    if (durationMs < 1000) return 'Average';
    if (durationMs < 5000) return 'Slow';
    return 'Very Slow';
  }

  /// Get performance color
  String get color {
    if (durationMs < 200) return '#059669'; // Green
    if (durationMs < 500) return '#2563EB'; // Blue
    if (durationMs < 1000) return '#D97706'; // Orange
    return '#DC2626'; // Red
  }

  /// Get performance icon
  String get icon {
    if (durationMs < 200) return '⚡';
    if (durationMs < 500) return '🚀';
    if (durationMs < 1000) return '⏱️';
    return '🐌';
  }

  /// Get results per second
  double get resultsPerSecond {
    if (durationMs == 0) return 0;
    return (totalResults * 1000) / durationMs;
  }

  /// Get formatted duration
  String get formattedDuration {
    if (durationMs < 1000) {
      return '${durationMs}ms';
    } else {
      final seconds = durationMs / 1000;
      return '${seconds.toStringAsFixed(1)}s';
    }
  }

  static String _calculateGrade(int durationMs) {
    if (durationMs < 100) return 'A+';
    if (durationMs < 200) return 'A';
    if (durationMs < 500) return 'B';
    if (durationMs < 1000) return 'C';
    if (durationMs < 5000) return 'D';
    return 'F';
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
    return 'SearchPerformanceEntity(${formattedDuration}, $performanceGrade, ${resultsPerSecond.toStringAsFixed(1)} results/s)';
  }
}

/// Search pagination entity
class SearchPaginationEntity extends Equatable {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPrevPage;

  const SearchPaginationEntity({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  /// Factory constructors
  factory SearchPaginationEntity.fromCounts({
    required int currentPage,
    required int totalItems,
    required int itemsPerPage,
  }) {
    final totalPages = (totalItems / itemsPerPage).ceil();

    return SearchPaginationEntity(
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      itemsPerPage: itemsPerPage,
      hasNextPage: currentPage < totalPages,
      hasPrevPage: currentPage > 1,
    );
  }

  /// Business logic methods

  /// Get range of items on current page
  String get itemRange {
    if (totalItems == 0) return '0 items';

    final start = (currentPage - 1) * itemsPerPage + 1;
    final end = (start + itemsPerPage - 1).clamp(start, totalItems);

    if (start == end) {
      return 'Item $start of $totalItems';
    }

    return 'Items $start-$end of $totalItems';
  }

  /// Get short range text
  String get shortRange {
    if (totalItems == 0) return '0';

    final start = (currentPage - 1) * itemsPerPage + 1;
    final end = (start + itemsPerPage - 1).clamp(start, totalItems);

    return '$start-$end of $totalItems';
  }

  /// Get page info
  String get pageInfo {
    if (totalPages == 0) return 'No pages';
    if (totalPages == 1) return 'Page 1 of 1';

    return 'Page $currentPage of $totalPages';
  }

  /// Get next page number
  int? get nextPage => hasNextPage ? currentPage + 1 : null;

  /// Get previous page number
  int? get previousPage => hasPrevPage ? currentPage - 1 : null;

  /// Check if this is the first page
  bool get isFirstPage => currentPage == 1;

  /// Check if this is the last page
  bool get isLastPage => currentPage == totalPages;

  /// Get page numbers for pagination UI
  List<int> getPageNumbers({int maxPages = 5}) {
    if (totalPages <= maxPages) {
      return List.generate(totalPages, (index) => index + 1);
    }

    final half = maxPages ~/ 2;
    int start = (currentPage - half).clamp(1, totalPages - maxPages + 1);
    int end = start + maxPages - 1;

    return List.generate(end - start + 1, (index) => start + index);
  }

  /// Calculate items on current page
  int get itemsOnCurrentPage {
    if (totalItems == 0) return 0;

    final start = (currentPage - 1) * itemsPerPage + 1;
    final end = (start + itemsPerPage - 1).clamp(start, totalItems);

    return end - start + 1;
  }

  /// Check if pagination is needed
  bool get isPaginationNeeded => totalPages > 1;

  /// Get progress percentage
  double get progressPercentage {
    if (totalPages <= 1) return 100.0;
    return (currentPage / totalPages) * 100;
  }

  /// Create copy with updated page
  SearchPaginationEntity copyWithPage(int newPage) {
    return SearchPaginationEntity(
      currentPage: newPage.clamp(1, totalPages),
      totalPages: totalPages,
      totalItems: totalItems,
      itemsPerPage: itemsPerPage,
      hasNextPage: newPage < totalPages,
      hasPrevPage: newPage > 1,
    );
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
    return 'SearchPaginationEntity($pageInfo, $itemRange)';
  }
}

/// Search analytics summary entity
class SearchAnalyticsSummaryEntity extends Equatable {
  final String query;
  final int searchCount;
  final double avgResults;
  final double avgDuration;
  final int popularityRank;
  final DateTime? lastSearched;

  const SearchAnalyticsSummaryEntity({
    required this.query,
    required this.searchCount,
    required this.avgResults,
    required this.avgDuration,
    required this.popularityRank,
    this.lastSearched,
  });

  /// Business logic methods

  /// Check if query is popular
  bool get isPopular => popularityRank <= 10;

  /// Check if query is trending
  bool get isTrending => searchCount > 50 && popularityRank <= 20;

  /// Get popularity description
  String get popularityDescription {
    if (popularityRank <= 5) return 'Very Popular';
    if (popularityRank <= 10) return 'Popular';
    if (popularityRank <= 20) return 'Common';
    if (popularityRank <= 50) return 'Occasional';
    return 'Rare';
  }

  /// Get performance description
  String get performanceDescription {
    if (avgDuration < 200) return 'Fast';
    if (avgDuration < 500) return 'Average';
    return 'Slow';
  }

  @override
  List<Object?> get props => [
    query,
    searchCount,
    avgResults,
    avgDuration,
    popularityRank,
    lastSearched,
  ];

  @override
  String toString() {
    return 'SearchAnalyticsSummaryEntity(query: "$query", rank: $popularityRank, searches: $searchCount)';
  }
}
