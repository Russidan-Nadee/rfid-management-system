// Path: frontend/lib/features/search/domain/entities/search_analytics_entity.dart
import 'package:equatable/equatable.dart';

/// Search analytics entity for tracking search behavior and performance
class SearchAnalyticsEntity extends Equatable {
  final String query;
  final String searchType;
  final List<String> entities;
  final int resultsCount;
  final int durationMs;
  final String? userId;
  final String? ipAddress;
  final DateTime timestamp;
  final bool wasSuccessful;
  final String? errorType;
  final Map<String, dynamic>? filters;
  final bool fromCache;

  const SearchAnalyticsEntity({
    required this.query,
    required this.searchType,
    required this.entities,
    required this.resultsCount,
    required this.durationMs,
    this.userId,
    this.ipAddress,
    required this.timestamp,
    this.wasSuccessful = true,
    this.errorType,
    this.filters,
    this.fromCache = false,
  });

  /// Factory constructors for different search analytics
  factory SearchAnalyticsEntity.successful({
    required String query,
    required String searchType,
    required List<String> entities,
    required int resultsCount,
    required int durationMs,
    String? userId,
    String? ipAddress,
    Map<String, dynamic>? filters,
    bool fromCache = false,
  }) {
    return SearchAnalyticsEntity(
      query: query,
      searchType: searchType,
      entities: entities,
      resultsCount: resultsCount,
      durationMs: durationMs,
      userId: userId,
      ipAddress: ipAddress,
      timestamp: DateTime.now(),
      wasSuccessful: true,
      filters: filters,
      fromCache: fromCache,
    );
  }

  factory SearchAnalyticsEntity.failed({
    required String query,
    required String searchType,
    required List<String> entities,
    required int durationMs,
    required String errorType,
    String? userId,
    String? ipAddress,
    Map<String, dynamic>? filters,
  }) {
    return SearchAnalyticsEntity(
      query: query,
      searchType: searchType,
      entities: entities,
      resultsCount: 0,
      durationMs: durationMs,
      userId: userId,
      ipAddress: ipAddress,
      timestamp: DateTime.now(),
      wasSuccessful: false,
      errorType: errorType,
      filters: filters,
      fromCache: false,
    );
  }

  /// Business logic methods

  /// Check if search was fast
  bool get isFastSearch => durationMs < 200;

  /// Check if search was slow
  bool get isSlowSearch => durationMs > 1000;

  /// Check if search had good results
  bool get hasGoodResults => wasSuccessful && resultsCount > 0;

  /// Check if search was empty
  bool get isEmpty => wasSuccessful && resultsCount == 0;

  /// Check if user search (vs anonymous)
  bool get isUserSearch => userId != null && userId!.isNotEmpty;

  /// Check if search used filters
  bool get hasFilters => filters != null && filters!.isNotEmpty;

  /// Get performance grade
  String get performanceGrade {
    if (!wasSuccessful) return 'F';
    if (durationMs < 100) return 'A+';
    if (durationMs < 200) return 'A';
    if (durationMs < 500) return 'B';
    if (durationMs < 1000) return 'C';
    if (durationMs < 5000) return 'D';
    return 'F';
  }

  /// Get search effectiveness score (0-100)
  double get effectivenessScore {
    if (!wasSuccessful) return 0.0;

    double score = 50.0; // Base score

    // Results bonus (max 30 points)
    if (resultsCount > 0) {
      score += (resultsCount.clamp(0, 10) * 3).toDouble();
    }

    // Performance bonus (max 20 points)
    if (durationMs < 200)
      score += 20.0;
    else if (durationMs < 500)
      score += 15.0;
    else if (durationMs < 1000)
      score += 10.0;
    else if (durationMs < 2000)
      score += 5.0;

    return score.clamp(0.0, 100.0);
  }

  /// Get search category based on behavior
  SearchCategory get category {
    if (!wasSuccessful) return SearchCategory.failed;
    if (fromCache) return SearchCategory.cached;
    if (resultsCount == 0) return SearchCategory.empty;
    if (isFastSearch && resultsCount > 0) return SearchCategory.excellent;
    if (resultsCount > 0) return SearchCategory.successful;
    return SearchCategory.poor;
  }

  /// Get anonymized version for analytics
  SearchAnalyticsEntity get anonymized {
    return copyWith(userId: null, ipAddress: null);
  }

  /// Create copy with updated fields
  SearchAnalyticsEntity copyWith({
    String? query,
    String? searchType,
    List<String>? entities,
    int? resultsCount,
    int? durationMs,
    String? userId,
    String? ipAddress,
    DateTime? timestamp,
    bool? wasSuccessful,
    String? errorType,
    Map<String, dynamic>? filters,
    bool? fromCache,
  }) {
    return SearchAnalyticsEntity(
      query: query ?? this.query,
      searchType: searchType ?? this.searchType,
      entities: entities ?? this.entities,
      resultsCount: resultsCount ?? this.resultsCount,
      durationMs: durationMs ?? this.durationMs,
      userId: userId ?? this.userId,
      ipAddress: ipAddress ?? this.ipAddress,
      timestamp: timestamp ?? this.timestamp,
      wasSuccessful: wasSuccessful ?? this.wasSuccessful,
      errorType: errorType ?? this.errorType,
      filters: filters ?? this.filters,
      fromCache: fromCache ?? this.fromCache,
    );
  }

  @override
  List<Object?> get props => [
    query,
    searchType,
    entities,
    resultsCount,
    durationMs,
    userId,
    ipAddress,
    timestamp,
    wasSuccessful,
    errorType,
    filters,
    fromCache,
  ];

  @override
  String toString() {
    return 'SearchAnalyticsEntity(query: "$query", type: $searchType, results: $resultsCount, ${durationMs}ms, success: $wasSuccessful)';
  }
}

/// Search category for analytics grouping
enum SearchCategory { excellent, successful, empty, cached, failed, poor }

/// Search statistics entity for aggregated analytics
class SearchStatisticsEntity extends Equatable {
  final String period;
  final int totalSearches;
  final int uniqueUsers;
  final int uniqueQueries;
  final double avgDuration;
  final double avgResults;
  final double successRate;
  final double cacheHitRate;
  final List<PopularQueryEntity> topQueries;
  final List<SearchTrendEntity> trends;
  final Map<String, int> searchTypeDistribution;
  final Map<String, int> entityDistribution;

  const SearchStatisticsEntity({
    required this.period,
    required this.totalSearches,
    required this.uniqueUsers,
    required this.uniqueQueries,
    required this.avgDuration,
    required this.avgResults,
    required this.successRate,
    required this.cacheHitRate,
    required this.topQueries,
    required this.trends,
    required this.searchTypeDistribution,
    required this.entityDistribution,
  });

  /// Business logic methods

  /// Check if performance is good
  bool get hasGoodPerformance => avgDuration < 500 && successRate > 0.95;

  /// Check if cache is effective
  bool get hasEffectiveCache => cacheHitRate > 0.7;

  /// Get performance grade
  String get performanceGrade {
    if (avgDuration < 200 && successRate > 0.98) return 'A+';
    if (avgDuration < 300 && successRate > 0.95) return 'A';
    if (avgDuration < 500 && successRate > 0.90) return 'B';
    if (avgDuration < 1000 && successRate > 0.80) return 'C';
    if (successRate > 0.70) return 'D';
    return 'F';
  }

  /// Get most popular search type
  String get mostPopularSearchType {
    if (searchTypeDistribution.isEmpty) return 'None';

    final sorted = searchTypeDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }

  /// Get most searched entity
  String get mostSearchedEntity {
    if (entityDistribution.isEmpty) return 'None';

    final sorted = entityDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }

  @override
  List<Object?> get props => [
    period,
    totalSearches,
    uniqueUsers,
    uniqueQueries,
    avgDuration,
    avgResults,
    successRate,
    cacheHitRate,
    topQueries,
    trends,
    searchTypeDistribution,
    entityDistribution,
  ];

  @override
  String toString() {
    return 'SearchStatisticsEntity(period: $period, searches: $totalSearches, success: ${(successRate * 100).toStringAsFixed(1)}%)';
  }
}

/// Popular query entity for analytics
class PopularQueryEntity extends Equatable {
  final String query;
  final int searchCount;
  final double avgResults;
  final double avgDuration;
  final double successRate;
  final List<String> popularEntities;

  const PopularQueryEntity({
    required this.query,
    required this.searchCount,
    required this.avgResults,
    required this.avgDuration,
    required this.successRate,
    required this.popularEntities,
  });

  /// Business logic methods

  /// Check if query performs well
  bool get performsWell => avgDuration < 500 && successRate > 0.9;

  /// Get performance description
  String get performanceDescription {
    if (avgDuration < 200 && successRate > 0.95) return 'Excellent';
    if (avgDuration < 500 && successRate > 0.90) return 'Good';
    if (avgDuration < 1000 && successRate > 0.80) return 'Average';
    return 'Poor';
  }

  @override
  List<Object?> get props => [
    query,
    searchCount,
    avgResults,
    avgDuration,
    successRate,
    popularEntities,
  ];

  @override
  String toString() {
    return 'PopularQueryEntity(query: "$query", searches: $searchCount, performance: $performanceDescription)';
  }
}

/// Search trend entity for analytics
class SearchTrendEntity extends Equatable {
  final DateTime date;
  final int searchCount;
  final double avgDuration;
  final double successRate;
  final int uniqueUsers;

  const SearchTrendEntity({
    required this.date,
    required this.searchCount,
    required this.avgDuration,
    required this.successRate,
    required this.uniqueUsers,
  });

  @override
  List<Object?> get props => [
    date,
    searchCount,
    avgDuration,
    successRate,
    uniqueUsers,
  ];

  @override
  String toString() {
    return 'SearchTrendEntity(date: ${date.toIso8601String().split('T').first}, searches: $searchCount)';
  }
}

/// User search behavior entity
class UserSearchBehaviorEntity extends Equatable {
  final String userId;
  final int totalSearches;
  final List<String> favoriteQueries;
  final List<String> preferredEntities;
  final double avgSessionDuration;
  final int sessionsCount;
  final DateTime firstSearch;
  final DateTime lastSearch;
  final Map<String, int> searchPatterns;

  const UserSearchBehaviorEntity({
    required this.userId,
    required this.totalSearches,
    required this.favoriteQueries,
    required this.preferredEntities,
    required this.avgSessionDuration,
    required this.sessionsCount,
    required this.firstSearch,
    required this.lastSearch,
    required this.searchPatterns,
  });

  /// Business logic methods

  /// Check if user is active
  bool get isActiveUser => totalSearches > 50;

  /// Check if user is power user
  bool get isPowerUser => totalSearches > 200 && sessionsCount > 20;

  /// Get user engagement level
  String get engagementLevel {
    if (totalSearches > 500) return 'Very High';
    if (totalSearches > 200) return 'High';
    if (totalSearches > 50) return 'Medium';
    if (totalSearches > 10) return 'Low';
    return 'Very Low';
  }

  /// Get user tenure in days
  int get tenureDays => lastSearch.difference(firstSearch).inDays;

  /// Get average searches per day
  double get avgSearchesPerDay {
    if (tenureDays == 0) return totalSearches.toDouble();
    return totalSearches / tenureDays;
  }

  @override
  List<Object?> get props => [
    userId,
    totalSearches,
    favoriteQueries,
    preferredEntities,
    avgSessionDuration,
    sessionsCount,
    firstSearch,
    lastSearch,
    searchPatterns,
  ];

  @override
  String toString() {
    return 'UserSearchBehaviorEntity(userId: $userId, searches: $totalSearches, engagement: $engagementLevel)';
  }
}
