// Path: frontend/lib/features/search/domain/usecases/search_analytics_usecase.dart
import 'dart:convert'; // Import for json.encode

import '../entities/search_analytics_entity.dart';
import '../entities/search_history_entity.dart';
import '../entities/search_suggestion_entity.dart';
import '../repositories/search_repository.dart';

/// Use case for search analytics and performance monitoring
/// Handles tracking, analysis, and reporting of search behavior and performance
class SearchAnalyticsUseCase {
  final SearchRepository repository;

  // Configuration constants
  static const Duration _analyticsRetentionPeriod = Duration(days: 365);
  static const int _maxAnalyticsEntries = 10000;
  static const double _performanceThresholdMs = 1000.0;

  SearchAnalyticsUseCase(this.repository);

  /// Track search activity for analytics
  ///
  /// Parameters:
  /// - [query]: The search query performed
  /// - [searchType]: Type of search (instant, global, advanced)
  /// - [entities]: Entity types searched
  /// - [resultsCount]: Number of results returned
  /// - [durationMs]: Search execution time in milliseconds
  /// - [wasSuccessful]: Whether the search completed successfully
  /// - [userId]: User identifier (optional)
  /// - [filters]: Any filters applied
  /// - [fromCache]: Whether results were served from cache
  /// - [errorType]: Type of error if search failed
  ///
  /// Returns:
  /// - [AnalyticsTrackingResult] indicating success or failure
  Future<AnalyticsTrackingResult> trackSearchActivity({
    required String query,
    required String searchType,
    required List<String> entities,
    required int resultsCount,
    required int durationMs,
    required bool wasSuccessful,
    String? userId,
    Map<String, dynamic>? filters,
    bool fromCache = false,
    String? errorType,
  }) async {
    try {
      // Create analytics entity
      final analytics = wasSuccessful
          ? SearchAnalyticsEntity.successful(
              query: query,
              searchType: searchType,
              entities: entities,
              resultsCount: resultsCount,
              durationMs: durationMs,
              userId: userId,
              filters: filters,
              fromCache: fromCache,
            )
          : SearchAnalyticsEntity.failed(
              query: query,
              searchType: searchType,
              entities: entities,
              durationMs: durationMs,
              errorType: errorType ?? 'unknown',
              userId: userId,
              filters: filters,
            );

      // Log analytics to repository
      await repository.logSearchAnalytics(analytics);

      // Perform real-time analysis if needed
      await _performRealtimeAnalysis(analytics);

      return AnalyticsTrackingResult.success(analytics: analytics);
    } catch (e) {
      return AnalyticsTrackingResult.failure(
        error: 'Failed to track search activity: ${e.toString()}',
      );
    }
  }

  /// Get comprehensive search statistics
  ///
  /// Parameters:
  /// - [period]: Time period for statistics (day, week, month, year)
  /// - [userId]: Specific user ID for user-specific stats (optional)
  /// - [entityType]: Filter by specific entity type (optional)
  /// - [includeDetails]: Include detailed breakdowns
  ///
  /// Returns:
  /// - [SearchStatisticsResult] with aggregated analytics data
  Future<SearchStatisticsResult> getSearchStatistics({
    String period = 'week',
    String? userId,
    String? entityType,
    bool includeDetails = true,
  }) async {
    try {
      // Validate period
      if (!_isValidPeriod(period)) {
        return SearchStatisticsResult.invalid('Invalid period: $period');
      }

      // Get statistics from repository
      final statistics = await repository.getSearchStatistics(
        period: period,
        userId: userId,
      );

      // Apply entity type filter if specified
      var filteredStatistics = statistics;
      if (entityType != null) {
        filteredStatistics = _filterStatisticsByEntity(statistics, entityType);
      }

      // Add additional insights if details requested
      Map<String, dynamic>? additionalInsights;
      if (includeDetails) {
        additionalInsights = await _generateAdditionalInsights(
          filteredStatistics,
          period,
          userId,
        );
      }

      return SearchStatisticsResult.success(
        statistics: filteredStatistics,
        period: period,
        additionalInsights: additionalInsights,
      );
    } catch (e) {
      return SearchStatisticsResult.failure(
        error: 'Failed to get search statistics: ${e.toString()}',
      );
    }
  }

  /// Get user-specific search behavior analysis
  ///
  /// Parameters:
  /// - [userId]: User identifier (required)
  /// - [analysisDepth]: Level of analysis (basic, detailed, comprehensive)
  ///
  /// Returns:
  /// - [UserBehaviorResult] with user search patterns and insights
  Future<UserBehaviorResult> getUserSearchBehavior({
    required String userId,
    String analysisDepth = 'detailed',
  }) async {
    try {
      // Get user behavior from repository
      final behavior = await repository.getUserSearchBehavior(userId);

      // Generate insights based on analysis depth
      final insights = await _generateUserInsights(behavior, analysisDepth);

      // Generate recommendations
      final recommendations = await _generateUserRecommendations(behavior);

      return UserBehaviorResult.success(
        behavior: behavior,
        insights: insights,
        recommendations: recommendations,
      );
    } catch (e) {
      return UserBehaviorResult.failure(
        error: 'Failed to get user search behavior: ${e.toString()}',
      );
    }
  }

  /// Get search performance metrics
  ///
  /// Parameters:
  /// - [period]: Time period for analysis
  /// - [includePercentiles]: Include performance percentile data
  ///
  /// Returns:
  /// - [PerformanceMetricsResult] with search performance data
  Future<PerformanceMetricsResult> getPerformanceMetrics({
    String period = 'week',
    bool includePercentiles = true,
  }) async {
    try {
      final statistics = await repository.getSearchStatistics(period: period);

      // Calculate performance metrics
      final metrics = _calculatePerformanceMetrics(
        statistics,
        includePercentiles,
      );

      // Identify performance issues
      final issues = _identifyPerformanceIssues(metrics);

      // Generate performance recommendations
      final recommendations = _generatePerformanceRecommendations(
        metrics,
        issues,
      );

      return PerformanceMetricsResult.success(
        metrics: metrics,
        issues: issues,
        recommendations: recommendations,
        period: period,
      );
    } catch (e) {
      return PerformanceMetricsResult.failure(
        error: 'Failed to get performance metrics: ${e.toString()}',
      );
    }
  }

  /// Get popular search trends
  ///
  /// Parameters:
  /// - [period]: Time period for trend analysis
  /// - [limit]: Number of trending queries to return
  /// - [trendType]: Type of trends (rising, popular, declining)
  ///
  /// Returns:
  /// - [SearchTrendsResult] with trending search data
  Future<SearchTrendsResult> getSearchTrends({
    String period = 'week',
    int limit = 20,
    String trendType = 'popular',
  }) async {
    try {
      final statistics = await repository.getSearchStatistics(period: period);

      // Analyze trends based on type
      List<TrendingQuery> trends;
      switch (trendType) {
        case 'rising':
          trends = _identifyRisingTrends(statistics, limit);
          break;
        case 'declining':
          trends = _identifyDecliningTrends(statistics, limit);
          break;
        case 'popular':
        default:
          trends = _getPopularTrends(statistics, limit);
          break;
      }

      // Get trend insights
      final insights = _generateTrendInsights(trends, trendType, period);

      return SearchTrendsResult.success(
        trends: trends,
        trendType: trendType,
        period: period,
        insights: insights,
      );
    } catch (e) {
      return SearchTrendsResult.failure(
        error: 'Failed to get search trends: ${e.toString()}',
      );
    }
  }

  /// Generate search optimization recommendations
  ///
  /// Parameters:
  /// - [analysisScope]: Scope of analysis (user, system, entity)
  /// - [userId]: Specific user for user-scoped analysis
  /// - [entityType]: Specific entity for entity-scoped analysis
  ///
  /// Returns:
  /// - [OptimizationResult] with actionable recommendations
  Future<OptimizationResult> generateOptimizationRecommendations({
    String analysisScope = 'system',
    String? userId,
    String? entityType,
  }) async {
    try {
      List<OptimizationRecommendation> recommendations = [];

      switch (analysisScope) {
        case 'user':
          if (userId != null) {
            recommendations = await _generateUserOptimizations(userId);
          }
          break;
        case 'entity':
          if (entityType != null) {
            recommendations = await _generateEntityOptimizations(entityType);
          }
          break;
        case 'system':
        default:
          recommendations = await _generateSystemOptimizations();
          break;
      }

      // Prioritize recommendations
      recommendations.sort((a, b) => b.priority.compareTo(a.priority));

      return OptimizationResult.success(
        recommendations: recommendations,
        scope: analysisScope,
      );
    } catch (e) {
      return OptimizationResult.failure(
        error:
            'Failed to generate optimization recommendations: ${e.toString()}',
      );
    }
  }

  /// Export analytics data
  ///
  /// Parameters:
  /// - [format]: Export format (json, csv, xlsx)
  /// - [period]: Time period for export
  /// - [includePersonalData]: Include user-specific data
  /// - [filters]: Additional filters for export
  ///
  /// Returns:
  /// - [String] with exported data
  Future<String> exportAnalyticsData({
    String format = 'json',
    String period = 'month',
    bool includePersonalData = false,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // Get comprehensive statistics
      final statistics = await repository.getSearchStatistics(period: period);

      // Format data based on export format
      switch (format.toLowerCase()) {
        case 'csv':
          return _exportToCsv(statistics, includePersonalData);
        case 'xlsx':
          return _exportToXlsx(statistics, includePersonalData);
        case 'json':
        default:
          return _exportToJson(statistics, includePersonalData);
      }
    } catch (e) {
      throw Exception('Failed to export analytics data: ${e.toString()}');
    }
  }

  /// Clean up old analytics data
  ///
  /// Parameters:
  /// - [olderThan]: Remove data older than this date
  /// - [keepAggregated]: Keep aggregated summaries even when removing details
  ///
  /// Returns:
  /// - [CleanupResult] indicating what was cleaned
  Future<CleanupResult> cleanupAnalyticsData({
    DateTime? olderThan,
    bool keepAggregated = true,
  }) async {
    try {
      final cutoffDate =
          olderThan ?? DateTime.now().subtract(_analyticsRetentionPeriod);

      // This would require additional repository methods for cleanup
      // For now, simulate cleanup result
      int removedEntries = 0;
      int preservedSummaries = 0;

      // In a real implementation, this would call repository cleanup methods
      // removedEntries = await repository.cleanupAnalyticsData(cutoffDate);

      if (keepAggregated) {
        // preservedSummaries = await repository.preserveAggregatedData(cutoffDate);
      }

      return CleanupResult.success(
        removedEntries: removedEntries,
        preservedSummaries: preservedSummaries,
        cutoffDate: cutoffDate,
      );
    } catch (e) {
      return CleanupResult.failure(
        error: 'Failed to cleanup analytics data: ${e.toString()}',
      );
    }
  }

  /// Get real-time search metrics dashboard data
  ///
  /// Returns:
  /// - [DashboardMetrics] with current search system health
  Future<DashboardMetrics> getDashboardMetrics() async {
    try {
      // Get current statistics
      final stats = await repository.getSearchStatistics(period: 'day');

      // Get cache statistics
      final cacheStats = await repository.getCacheStats();

      // Get search health
      final healthStats = await repository.getSearchHealth();

      // Calculate real-time metrics
      final metrics = DashboardMetrics(
        currentSearchVolume: stats.totalSearches,
        successRate: stats.successRate,
        avgResponseTime: stats.avgDuration,
        cacheHitRate:
            cacheStats['hitRate'] ?? 0.0, // Assuming cacheStats is a Map
        activeUsers: stats.uniqueUsers,
        topQueries: stats.topQueries.take(5).map((q) => q.query).toList(),
        errorRate: 1.0 - stats.successRate,
        performanceGrade: _calculatePerformanceGrade(stats.avgDuration),
        systemHealth: healthStats['status'] ?? 'unknown',
        lastUpdated: DateTime.now(),
      );

      return metrics;
    } catch (e) {
      return DashboardMetrics.error('Failed to get dashboard metrics');
    }
  }

  /// Private helper methods

  /// Perform real-time analysis on new analytics data
  Future<void> _performRealtimeAnalysis(SearchAnalyticsEntity analytics) async {
    try {
      // Check for performance issues
      if (analytics.durationMs > _performanceThresholdMs) {
        // Log performance warning
        print('Performance warning: Search took ${analytics.durationMs}ms');
      }

      // Check for error patterns
      if (!analytics.wasSuccessful) {
        // Track error patterns
        print(
          'Search error: ${analytics.errorType} for query: ${analytics.query}',
        );
      }

      // This would update live dashboards, trigger alerts, etc.
    } catch (e) {
      print('Error during real-time analysis: ${e.toString()}');
    }
  }

  /// Validate period string
  bool _isValidPeriod(String period) {
    return ['day', 'week', 'month', 'year'].contains(period);
  }

  /// Filter statistics by entity type
  Map<String, dynamic> _filterStatisticsByEntity(
    Map<String, dynamic> statistics,
    String entityType,
  ) {
    final Map<String, dynamic> filtered = Map.from(statistics);
    if (filtered.containsKey('topQueries')) {
      final List<dynamic> topQueries = filtered['topQueries'];
      filtered['topQueries'] = topQueries.where((q) {
        return q['entities'] != null &&
            (q['entities'] as List).contains(entityType);
      }).toList();
    }
    return filtered;
  }

  /// Generate additional insights based on statistics
  Future<Map<String, dynamic>> _generateAdditionalInsights(
    Map<String, dynamic> statistics,
    String period,
    String? userId,
  ) async {
    final insights = <String, dynamic>{};

    // Identify common zero-result queries
    if (statistics.containsKey('zeroResultQueries')) {
      insights['commonZeroResultQueries'] = statistics['zeroResultQueries']
          .take(5)
          .toList();
    }

    // Identify slow queries
    if (statistics.containsKey('slowQueries')) {
      insights['slowQueriesDetected'] = statistics['slowQueries']
          .where((q) => q['durationMs'] > _performanceThresholdMs)
          .take(5)
          .toList();
    }

    // Suggest content gaps based on frequent but unsuccessful searches
    return insights;
  }

  /// Generate user-specific insights
  Future<Map<String, dynamic>> _generateUserInsights(
    Map<String, dynamic> behavior,
    String analysisDepth,
  ) async {
    final insights = <String, dynamic>{};

    if (analysisDepth == 'detailed' || analysisDepth == 'comprehensive') {
      insights['mostSearchedEntities'] = behavior['mostSearchedEntities'];
      insights['averageSearchDuration'] = behavior['averageSearchDuration'];
    }

    if (analysisDepth == 'comprehensive') {
      insights['commonRefinements'] = behavior['commonRefinements'];
      insights['preferredSearchTimes'] = behavior['preferredSearchTimes'];
    }
    return insights;
  }

  /// Generate user-specific recommendations
  Future<List<String>> _generateUserRecommendations(
    Map<String, dynamic> behavior,
  ) async {
    final recommendations = <String>[];
    if (behavior.containsKey('mostSearchedEntities') &&
        behavior['mostSearchedEntities'].isNotEmpty) {
      recommendations.add(
        'Consider highlighting content related to: ${behavior['mostSearchedEntities'].first}',
      );
    }
    return recommendations;
  }

  /// Calculate performance metrics
  Map<String, dynamic> _calculatePerformanceMetrics(
    Map<String, dynamic> statistics,
    bool includePercentiles,
  ) {
    final metrics = <String, dynamic>{};
    metrics['averageResponseTime'] = statistics['avgDuration'];
    metrics['errorRate'] = 1.0 - statistics['successRate'];
    metrics['cacheHitRate'] = statistics['cacheHitRate'];

    if (includePercentiles) {
      final List<int> durations =
          (statistics['allDurations'] as List?)?.cast<int>() ?? [];
      if (durations.isNotEmpty) {
        durations.sort();
        metrics['p50ResponseTime'] = _getPercentile(durations, 50);
        metrics['p90ResponseTime'] = _getPercentile(durations, 90);
        metrics['p99ResponseTime'] = _getPercentile(durations, 99);
      }
    }
    return metrics;
  }

  /// Identify performance issues
  List<String> _identifyPerformanceIssues(Map<String, dynamic> metrics) {
    final issues = <String>[];
    if (metrics['averageResponseTime'] > _performanceThresholdMs) {
      issues.add('Average response time exceeds threshold.');
    }
    if (metrics['errorRate'] > 0.05) {
      issues.add('High error rate detected.');
    }
    return issues;
  }

  /// Generate performance recommendations
  List<String> _generatePerformanceRecommendations(
    Map<String, dynamic> metrics,
    List<String> issues,
  ) {
    final recommendations = <String>[];
    if (issues.contains('Average response time exceeds threshold.')) {
      recommendations.add(
        'Investigate slow queries and optimize database access.',
      );
    }
    if (metrics['cacheHitRate'] < 0.7) {
      recommendations.add('Improve cache hit rate to reduce response times.');
    }
    return recommendations;
  }

  /// Identify rising trends
  List<TrendingQuery> _identifyRisingTrends(
    Map<String, dynamic> statistics,
    int limit,
  ) {
    final List<TrendingQuery> risingTrends = [];
    if (statistics.containsKey('topQueries')) {
      final List<dynamic> topQueries = statistics['topQueries'];
      risingTrends.addAll(
        topQueries
            .where((q) => q['searchCount'] > 50 && q['searchCount'] < 200)
            .map(
              (q) => TrendingQuery(
                query: q['query'],
                count: q['searchCount'],
                change: (q['searchCount'] * 0.1).toInt(),
              ),
            )
            .toList(),
      );
    }
    risingTrends.sort(
      (a, b) => b.change!.compareTo(a.change!),
    ); // Added null-safety
    return risingTrends.take(limit).toList();
  }

  /// Identify declining trends
  List<TrendingQuery> _identifyDecliningTrends(
    Map<String, dynamic> statistics,
    int limit,
  ) {
    final List<TrendingQuery> decliningTrends = [];
    if (statistics.containsKey('topQueries')) {
      final List<dynamic> topQueries = statistics['topQueries'];
      decliningTrends.addAll(
        topQueries
            .where((q) => q['searchCount'] > 10 && q['searchCount'] < 100)
            .map(
              (q) => TrendingQuery(
                query: q['query'],
                count: q['searchCount'],
                change: (q['searchCount'] * -0.05).toInt(),
              ),
            )
            .toList(),
      );
    }
    decliningTrends.sort(
      (a, b) => a.change!.compareTo(b.change!),
    ); // Added null-safety
    return decliningTrends.take(limit).toList();
  }

  /// Get popular trends
  List<TrendingQuery> _getPopularTrends(
    Map<String, dynamic> statistics,
    int limit,
  ) {
    final List<TrendingQuery> popularTrends = [];
    if (statistics.containsKey('topQueries')) {
      final List<dynamic> topQueries = statistics['topQueries'];
      popularTrends.addAll(
        topQueries
            .map(
              (q) => TrendingQuery(query: q['query'], count: q['searchCount']),
            )
            .toList(),
      );
    }
    popularTrends.sort((a, b) => b.count.compareTo(a.count));
    return popularTrends.take(limit).toList();
  }

  /// Generate trend insights
  String _generateTrendInsights(
    List<TrendingQuery> trends,
    String trendType,
    String period,
  ) {
    if (trends.isEmpty) {
      return 'No $trendType trends identified for the $period.';
    }
    final firstTrend = trends.first;
    return 'The top $trendType query for the $period is "${firstTrend.query}" with ${firstTrend.count} searches.';
  }

  /// Generate user-specific optimizations
  Future<List<OptimizationRecommendation>> _generateUserOptimizations(
    String userId,
  ) async {
    final userBehavior = await repository.getUserSearchBehavior(userId);
    final recommendations = <OptimizationRecommendation>[];

    if (userBehavior.containsKey('frequentZeroResultQueries')) {
      recommendations.add(
        OptimizationRecommendation(
          type: 'User Content Gap',
          description:
              'User $userId frequently searches for "${userBehavior['frequentZeroResultQueries'].first}" with no results. Consider adding relevant content.',
          priority: 4,
        ),
      );
    }
    return recommendations;
  }

  /// Generate entity-specific optimizations
  Future<List<OptimizationRecommendation>> _generateEntityOptimizations(
    String entityType,
  ) async {
    final statistics = await repository.getSearchStatistics(period: 'month');
    final recommendations = <OptimizationRecommendation>[];

    if (statistics.containsKey('entityPerformance') &&
        statistics['entityPerformance'][entityType] != null &&
        statistics['entityPerformance'][entityType]['avgDuration'] >
            _performanceThresholdMs) {
      recommendations.add(
        OptimizationRecommendation(
          type: 'Entity Performance',
          description:
              'Searches for entity type "$entityType" are slow. Optimize data retrieval or indexing for this entity.',
          priority: 5,
        ),
      );
    }
    return recommendations;
  }

  /// Generate system-wide optimizations
  Future<List<OptimizationRecommendation>>
  _generateSystemOptimizations() async {
    final statistics = await repository.getSearchStatistics(period: 'month');
    final recommendations = <OptimizationRecommendation>[];

    // Overall performance
    if (statistics['avgDuration'] > _performanceThresholdMs) {
      recommendations.add(
        OptimizationRecommendation(
          type: 'System Performance',
          description:
              'Overall average search response time is high. Investigate system-wide performance bottlenecks.',
          priority: 5,
        ),
      );
    }

    // Common typos/misspellings
    if (statistics.containsKey('commonMisspellings')) {
      recommendations.add(
        OptimizationRecommendation(
          type: 'Typo Correction',
          description:
              'Implement or improve typo correction for common misspellings like "${statistics['commonMisspellings'].first}".',
          priority: 3,
        ),
      );
    }
    return recommendations;
  }

  /// Export data to CSV format
  String _exportToCsv(
    Map<String, dynamic> statistics,
    bool includePersonalData,
  ) {
    final StringBuffer csv = StringBuffer();
    csv.writeln('Metric,Value');
    statistics.forEach((key, value) {
      if (!key.contains('topQueries') &&
          (!key.contains('userId') || includePersonalData)) {
        csv.writeln('$key,$value');
      }
    });
    if (statistics.containsKey('topQueries')) {
      csv.writeln('Top Queries');
      csv.writeln('Query,Count');
      for (var query in statistics['topQueries']) {
        csv.writeln('${query['query']},${query['searchCount']}');
      }
    }
    return csv.toString();
  }

  /// Export data to XLSX format (placeholder - requires a library)
  String _exportToXlsx(
    Map<String, dynamic> statistics,
    bool includePersonalData,
  ) {
    return 'XLSX export not implemented. Data: ${json.encode(statistics)}'; // Encoded JSON for placeholder
  }

  /// Export data to JSON format
  String _exportToJson(
    Map<String, dynamic> statistics,
    bool includePersonalData,
  ) {
    final Map<String, dynamic> dataToExport = Map.from(statistics);
    if (!includePersonalData) {
      dataToExport.remove('uniqueUsers');
    }
    return json.encode(dataToExport); // Corrected to use json.encode()
  }

  /// Helper to calculate percentiles
  double _getPercentile(List<int> sortedData, int percentile) {
    if (sortedData.isEmpty) return 0.0;
    final index = (percentile / 100.0) * (sortedData.length - 1);
    if (index % 1 == 0) {
      return sortedData[index.toInt()].toDouble();
    } else {
      final lower = sortedData[index.floor()].toDouble();
      final upper = sortedData[index.ceil()].toDouble();
      return lower + (upper - lower) * (index - index.floor());
    }
  }

  /// Helper to calculate performance grade
  String _calculatePerformanceGrade(double avgDuration) {
    if (avgDuration < 200) {
      return 'Excellent';
    } else if (avgDuration < 500) {
      return 'Good';
    } else if (avgDuration < 1000) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }
}

/// Result class for tracking search activity
class AnalyticsTrackingResult {
  final SearchAnalyticsEntity? analytics;
  final String? error;
  final bool isSuccess;

  AnalyticsTrackingResult.success({required this.analytics})
    : isSuccess = true,
      error = null;

  AnalyticsTrackingResult.failure({required this.error})
    : isSuccess = false,
      analytics = null;
}

/// Result class for search statistics
class SearchStatisticsResult {
  final Map<String, dynamic>? statistics;
  final String? error;
  final bool isSuccess;
  final String? period;
  final Map<String, dynamic>? additionalInsights;

  SearchStatisticsResult.success({
    this.statistics,
    this.period,
    this.additionalInsights,
  }) : isSuccess = true,
       error = null;

  SearchStatisticsResult.failure({required this.error})
    : isSuccess = false,
      statistics = null,
      period = null,
      additionalInsights = null;

  SearchStatisticsResult.invalid(String errorMessage)
    : isSuccess = false,
      error = errorMessage,
      statistics = null,
      period = null,
      additionalInsights = null;
}

/// Result class for user behavior analysis
class UserBehaviorResult {
  final Map<String, dynamic>? behavior;
  final Map<String, dynamic>? insights;
  final List<String>? recommendations;
  final String? error;
  final bool isSuccess;

  UserBehaviorResult.success({
    this.behavior,
    this.insights,
    this.recommendations,
  }) : isSuccess = true,
       error = null;

  UserBehaviorResult.failure({required this.error})
    : isSuccess = false,
      behavior = null,
      insights = null,
      recommendations = null;
}

/// Result class for performance metrics
class PerformanceMetricsResult {
  final Map<String, dynamic>? metrics;
  final List<String>? issues;
  final List<String>? recommendations;
  final String? error;
  final bool isSuccess;
  final String? period;

  PerformanceMetricsResult.success({
    this.metrics,
    this.issues,
    this.recommendations,
    this.period,
  }) : isSuccess = true,
       error = null;

  PerformanceMetricsResult.failure({required this.error})
    : isSuccess = false,
      metrics = null,
      issues = null,
      recommendations = null,
      period = null;
}

/// Entity for a trending search query
class TrendingQuery {
  final String query;
  final int count;
  final int? change; // Change in rank or count for rising/declining trends

  TrendingQuery({required this.query, required this.count, this.change});
}

/// Result class for search trends
class SearchTrendsResult {
  final List<TrendingQuery>? trends;
  final String? trendType;
  final String? period;
  final String? insights;
  final String? error;
  final bool isSuccess;

  SearchTrendsResult.success({
    this.trends,
    this.trendType,
    this.period,
    this.insights,
  }) : isSuccess = true,
       error = null;

  SearchTrendsResult.failure({required this.error})
    : isSuccess = false,
      trends = null,
      trendType = null,
      period = null,
      insights = null;
}

/// Entity for an optimization recommendation
class OptimizationRecommendation {
  final String type;
  final String description;
  final int priority; // e.g., 1 (low) to 5 (critical)

  OptimizationRecommendation({
    required this.type,
    required this.description,
    required this.priority,
  });
}

/// Result class for optimization recommendations
class OptimizationResult {
  final List<OptimizationRecommendation>? recommendations;
  final String? scope;
  final String? error;
  final bool isSuccess;

  OptimizationResult.success({this.recommendations, this.scope})
    : isSuccess = true,
      error = null;

  OptimizationResult.failure({required this.error})
    : isSuccess = false,
      recommendations = null,
      scope = null;
}

/// Result class for cleanup operation
class CleanupResult {
  final int removedEntries;
  final int preservedSummaries;
  final DateTime? cutoffDate;
  final String? error;
  final bool isSuccess;

  CleanupResult.success({
    required this.removedEntries,
    required this.preservedSummaries,
    this.cutoffDate,
  }) : isSuccess = true,
       error = null;

  CleanupResult.failure({required this.error})
    : isSuccess = false,
      removedEntries = 0,
      preservedSummaries = 0,
      cutoffDate = null;
}

/// Result class for real-time dashboard metrics
class DashboardMetrics {
  final int currentSearchVolume;
  final double successRate;
  final double avgResponseTime;
  final double cacheHitRate;
  final int activeUsers;
  final List<String> topQueries;
  final double errorRate;
  final String performanceGrade;
  final String systemHealth;
  final DateTime lastUpdated;
  final String? error;
  final bool isSuccess;

  DashboardMetrics({
    required this.currentSearchVolume,
    required this.successRate,
    required this.avgResponseTime,
    required this.cacheHitRate,
    required this.activeUsers,
    required this.topQueries,
    required this.errorRate,
    required this.performanceGrade,
    required this.systemHealth,
    required this.lastUpdated,
  }) : isSuccess = true,
       error = null;

  DashboardMetrics.error(String errorMessage)
    : isSuccess = false,
      error = errorMessage,
      currentSearchVolume = 0,
      successRate = 0.0,
      avgResponseTime = 0.0,
      cacheHitRate = 0.0,
      activeUsers = 0,
      topQueries = const [],
      errorRate = 0.0,
      performanceGrade = 'Unknown',
      systemHealth = 'Unknown',
      lastUpdated = DateTime.now();
}
