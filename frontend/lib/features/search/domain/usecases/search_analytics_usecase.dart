// Path: frontend/lib/features/search/domain/usecases/search_analytics_usecase.dart
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
        cacheHitRate: stats.cacheHitRate,
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

      // Update real-time metrics
      // This would update live dashboards, trigger alerts, etc.
    } catch (e) {
      // Ignore real-time analysis errors to avoid disrupting search
    }
  }

  /// Validate if period is valid
  bool _isValidPeriod(String period) {
    const validPeriods = ['hour', 'day', 'week', 'month', 'quarter', 'year'];
    return validPeriods.contains(period);
  }

  /// Filter statistics by entity type
  Map<String, dynamic> _filterStatisticsByEntity(
    Map<String, dynamic> statistics,
    String entityType,
  ) {
    // Filter the statistics to only include the specified entity type
    final filtered = Map<String, dynamic>.from(statistics);

    // Filter entity-specific metrics
    if (filtered.containsKey('entitiesBreakdown')) {
      final entitiesBreakdown =
          filtered['entitiesBreakdown'] as Map<String, dynamic>;
      filtered['entitiesBreakdown'] = {
        entityType: entitiesBreakdown[entityType] ?? {},
      };
    }

    return filtered;
  }

  /// Generate additional insights for statistics
  Future<Map<String, dynamic>> _generateAdditionalInsights(
    Map<String, dynamic> statistics,
    String period,
    String? userId,
  ) async {
    final insights = <String, dynamic>{};

    // Performance insights
    final avgDuration = statistics['avgDuration'] as double? ?? 0.0;
    insights['performanceGrade'] = _calculatePerformanceGrade(avgDuration);
    insights['performanceComparison'] = _comparePerformance(
      avgDuration,
      period,
    );

    // Usage patterns
    final searchsByHour =
        statistics['searchsByHour'] as Map<String, int>? ?? {};
    insights['peakHours'] = _identifyPeakHours(searchsByHour);
    insights['usagePattern'] = _analyzeUsagePattern(searchsByHour);

    // Success rate insights
    final successRate = statistics['successRate'] as double? ?? 0.0;
    insights['successRateGrade'] = _gradeSuccessRate(successRate);
    insights['improvementSuggestions'] = _generateImprovementSuggestions(
      statistics,
    );

    return insights;
  }

  /// Generate user-specific insights
  Future<Map<String, dynamic>> _generateUserInsights(
    Map<String, dynamic> behavior,
    String analysisDepth,
  ) async {
    final insights = <String, dynamic>{};

    switch (analysisDepth) {
      case 'comprehensive':
        insights.addAll(await _generateComprehensiveUserInsights(behavior));
        continue detailed;
      detailed:
      case 'detailed':
        insights.addAll(await _generateDetailedUserInsights(behavior));
        continue basic;
      basic:
      case 'basic':
      default:
        insights.addAll(await _generateBasicUserInsights(behavior));
        break;
    }

    return insights;
  }

  /// Generate basic user insights
  Future<Map<String, dynamic>> _generateBasicUserInsights(
    Map<String, dynamic> behavior,
  ) async {
    return {
      'searchFrequency': behavior['searchFrequency'] ?? 'unknown',
      'preferredEntities': behavior['preferredEntities'] ?? [],
      'averageResultsClicked': behavior['averageResultsClicked'] ?? 0,
      'lastSearchDate': behavior['lastSearchDate'],
    };
  }

  /// Generate detailed user insights
  Future<Map<String, dynamic>> _generateDetailedUserInsights(
    Map<String, dynamic> behavior,
  ) async {
    final basic = await _generateBasicUserInsights(behavior);

    basic.addAll({
      'searchPatterns': behavior['searchPatterns'] ?? {},
      'queryComplexity': behavior['queryComplexity'] ?? 'simple',
      'filterUsage': behavior['filterUsage'] ?? 'minimal',
      'expertiseLevel': _assessUserExpertise(behavior),
      'searchEfficiency': _calculateSearchEfficiency(behavior),
    });

    return basic;
  }

  /// Generate comprehensive user insights
  Future<Map<String, dynamic>> _generateComprehensiveUserInsights(
    Map<String, dynamic> behavior,
  ) async {
    final detailed = await _generateDetailedUserInsights(behavior);

    detailed.addAll({
      'behaviorTrends': behavior['behaviorTrends'] ?? {},
      'anomalies': _detectBehaviorAnomalies(behavior),
      'predictedNeeds': await _predictUserNeeds(behavior),
      'personalizationOpportunities': _identifyPersonalizationOpportunities(
        behavior,
      ),
      'engagementScore': _calculateEngagementScore(behavior),
    });

    return detailed;
  }

  /// Generate user recommendations
  Future<List<String>> _generateUserRecommendations(
    Map<String, dynamic> behavior,
  ) async {
    final recommendations = <String>[];

    final searchFrequency = behavior['searchFrequency'] as String? ?? 'low';
    final filterUsage = behavior['filterUsage'] as String? ?? 'minimal';
    final expertiseLevel = _assessUserExpertise(behavior);

    if (searchFrequency == 'high' && filterUsage == 'minimal') {
      recommendations.add(
        'Try using filters to refine your search results more effectively',
      );
    }

    if (expertiseLevel == 'beginner') {
      recommendations.add(
        'Explore the search help guide to learn advanced search techniques',
      );
    }

    if (behavior['queryComplexity'] == 'simple') {
      recommendations.add(
        'Consider using more specific keywords for better results',
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

    final avgDuration = statistics['avgDuration'] as double? ?? 0.0;
    final maxDuration = statistics['maxDuration'] as double? ?? 0.0;
    final minDuration = statistics['minDuration'] as double? ?? 0.0;

    metrics['averageResponseTime'] = avgDuration;
    metrics['maxResponseTime'] = maxDuration;
    metrics['minResponseTime'] = minDuration;
    metrics['performanceGrade'] = _calculatePerformanceGrade(avgDuration);

    if (includePercentiles) {
      // Calculate percentiles (would need actual data distribution)
      metrics['p50'] = avgDuration * 0.8; // Simulated
      metrics['p90'] = avgDuration * 1.5; // Simulated
      metrics['p95'] = avgDuration * 1.8; // Simulated
      metrics['p99'] = avgDuration * 2.2; // Simulated
    }

    // Cache performance
    final cacheHitRate = statistics['cacheHitRate'] as double? ?? 0.0;
    metrics['cacheEfficiency'] = cacheHitRate;
    metrics['cacheGrade'] = _gradeCachePerformance(cacheHitRate);

    return metrics;
  }

  /// Identify performance issues
  List<String> _identifyPerformanceIssues(Map<String, dynamic> metrics) {
    final issues = <String>[];

    final avgResponseTime = metrics['averageResponseTime'] as double? ?? 0.0;
    if (avgResponseTime > _performanceThresholdMs) {
      issues.add('Average response time exceeds threshold');
    }

    final p95 = metrics['p95'] as double?;
    if (p95 != null && p95 > _performanceThresholdMs * 2) {
      issues.add('95th percentile response time is too high');
    }

    final cacheHitRate = metrics['cacheEfficiency'] as double? ?? 0.0;
    if (cacheHitRate < 0.7) {
      issues.add('Cache hit rate is below optimal level');
    }

    return issues;
  }

  /// Generate performance recommendations
  List<String> _generatePerformanceRecommendations(
    Map<String, dynamic> metrics,
    List<String> issues,
  ) {
    final recommendations = <String>[];

    if (issues.contains('Average response time exceeds threshold')) {
      recommendations.add('Consider optimizing database queries');
      recommendations.add('Review search indexing strategy');
    }

    if (issues.contains('Cache hit rate is below optimal level')) {
      recommendations.add('Increase cache TTL for stable data');
      recommendations.add('Implement more aggressive caching strategy');
    }

    if (issues.contains('95th percentile response time is too high')) {
      recommendations.add('Implement query timeout mechanisms');
      recommendations.add('Add request throttling for complex queries');
    }

    return recommendations;
  }

  /// Identify rising trends
  List<TrendingQuery> _identifyRisingTrends(
    Map<String, dynamic> statistics,
    int limit,
  ) {
    // This would analyze query frequency changes over time
    // For now, return simulated trending queries
    return [
      TrendingQuery('asset maintenance', 145, 25.5),
      TrendingQuery('equipment status', 98, 18.2),
      TrendingQuery('plant efficiency', 76, 12.1),
    ];
  }

  /// Identify declining trends
  List<TrendingQuery> _identifyDecliningTrends(
    Map<String, dynamic> statistics,
    int limit,
  ) {
    return [
      TrendingQuery('old equipment', 23, -15.8),
      TrendingQuery('legacy systems', 18, -22.3),
    ];
  }

  /// Get popular trends
  List<TrendingQuery> _getPopularTrends(
    Map<String, dynamic> statistics,
    int limit,
  ) {
    final topQueries = statistics['topQueries'] as List? ?? [];
    return topQueries
        .take(limit)
        .map((q) => TrendingQuery(q['query'] ?? '', q['count'] ?? 0, 0.0))
        .toList();
  }

  /// Generate trend insights
  Map<String, dynamic> _generateTrendInsights(
    List<TrendingQuery> trends,
    String trendType,
    String period,
  ) {
    final insights = <String, dynamic>{};

    insights['totalTrends'] = trends.length;
    insights['topTrend'] = trends.isNotEmpty ? trends.first.query : 'none';

    if (trendType == 'rising') {
      final avgGrowth = trends.isEmpty
          ? 0.0
          : trends.fold(0.0, (sum, t) => sum + t.changePercent) / trends.length;
      insights['averageGrowthRate'] = avgGrowth;
    }

    insights['trendCategories'] = _categorizeQueries(
      trends.map((t) => t.query).toList(),
    );

    return insights;
  }

  /// Generate system optimizations
  Future<List<OptimizationRecommendation>>
  _generateSystemOptimizations() async {
    return [
      OptimizationRecommendation(
        type: 'performance',
        title: 'Optimize Search Index',
        description: 'Review and optimize search index configuration',
        priority: 8,
        estimatedImpact: 'high',
      ),
      OptimizationRecommendation(
        type: 'caching',
        title: 'Enhance Cache Strategy',
        description: 'Implement more intelligent caching mechanisms',
        priority: 7,
        estimatedImpact: 'medium',
      ),
    ];
  }

  /// Generate user-specific optimizations
  Future<List<OptimizationRecommendation>> _generateUserOptimizations(
    String userId,
  ) async {
    return [
      OptimizationRecommendation(
        type: 'personalization',
        title: 'Personalized Search Results',
        description: 'Customize search ranking based on user behavior',
        priority: 6,
        estimatedImpact: 'medium',
      ),
    ];
  }

  /// Generate entity-specific optimizations
  Future<List<OptimizationRecommendation>> _generateEntityOptimizations(
    String entityType,
  ) async {
    return [
      OptimizationRecommendation(
        type: 'indexing',
        title: 'Optimize $entityType Index',
        description: 'Improve indexing strategy for $entityType entities',
        priority: 7,
        estimatedImpact: 'high',
      ),
    ];
  }

  /// Export to JSON format
  String _exportToJson(
    Map<String, dynamic> statistics,
    bool includePersonalData,
  ) {
    final exportData = Map<String, dynamic>.from(statistics);

    if (!includePersonalData) {
      exportData.remove('userBreakdown');
      exportData.remove('personalizedData');
    }

    // In a real implementation, this would use a proper JSON encoder
    return 'JSON export of analytics data'; // Placeholder
  }

  /// Export to CSV format
  String _exportToCsv(
    Map<String, dynamic> statistics,
    bool includePersonalData,
  ) {
    // CSV export implementation
    return 'CSV export of analytics data'; // Placeholder
  }

  /// Export to XLSX format
  String _exportToXlsx(
    Map<String, dynamic> statistics,
    bool includePersonalData,
  ) {
    // XLSX export implementation
    return 'XLSX export of analytics data'; // Placeholder
  }

  /// Calculate performance grade
  String _calculatePerformanceGrade(double avgDuration) {
    if (avgDuration < 200) return 'A';
    if (avgDuration < 500) return 'B';
    if (avgDuration < 1000) return 'C';
    if (avgDuration < 2000) return 'D';
    return 'F';
  }

  /// Compare performance with historical data
  String _comparePerformance(double avgDuration, String period) {
    // This would compare with historical averages
    return 'better'; // Placeholder
  }

  /// Identify peak hours
  List<int> _identifyPeakHours(Map<String, int> searchsByHour) {
    final sortedHours = searchsByHour.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedHours.take(3).map((e) => int.parse(e.key)).toList();
  }

  /// Analyze usage pattern
  String _analyzeUsagePattern(Map<String, int> searchsByHour) {
    final peakHours = _identifyPeakHours(searchsByHour);

    if (peakHours.any((h) => h >= 9 && h <= 17)) {
      return 'business_hours';
    } else if (peakHours.any((h) => h >= 18 && h <= 23)) {
      return 'evening';
    } else {
      return 'distributed';
    }
  }

  /// Grade success rate
  String _gradeSuccessRate(double successRate) {
    if (successRate >= 0.95) return 'excellent';
    if (successRate >= 0.90) return 'good';
    if (successRate >= 0.80) return 'fair';
    return 'poor';
  }

  /// Generate improvement suggestions
  List<String> _generateImprovementSuggestions(
    Map<String, dynamic> statistics,
  ) {
    final suggestions = <String>[];
    final successRate = statistics['successRate'] as double? ?? 0.0;

    if (successRate < 0.9) {
      suggestions.add('Improve search result relevance');
      suggestions.add('Review and update search indices');
    }

    return suggestions;
  }

  /// Assess user expertise level
  String _assessUserExpertise(Map<String, dynamic> behavior) {
    final filterUsage = behavior['filterUsage'] as String? ?? 'minimal';
    final queryComplexity = behavior['queryComplexity'] as String? ?? 'simple';

    if (filterUsage == 'advanced' && queryComplexity == 'complex') {
      return 'expert';
    } else if (filterUsage == 'moderate' || queryComplexity == 'moderate') {
      return 'intermediate';
    }
    return 'beginner';
  }

  /// Calculate search efficiency
  double _calculateSearchEfficiency(Map<String, dynamic> behavior) {
    final avgResultsClicked = behavior['averageResultsClicked'] as int? ?? 0;
    final avgSearchesPerSession =
        behavior['avgSearchesPerSession'] as int? ?? 1;

    if (avgSearchesPerSession == 0) return 0.0;
    return avgResultsClicked / avgSearchesPerSession;
  }

  /// Detect behavior anomalies
  List<String> _detectBehaviorAnomalies(Map<String, dynamic> behavior) {
    final anomalies = <String>[];

    final searchFrequency = behavior['searchFrequency'] as String? ?? 'normal';
    if (searchFrequency == 'extremely_high') {
      anomalies.add('Unusually high search frequency');
    }

    return anomalies;
  }

  /// Predict user needs
  Future<List<String>> _predictUserNeeds(Map<String, dynamic> behavior) async {
    // Machine learning prediction would go here
    return ['equipment maintenance', 'performance reports'];
  }

  /// Identify personalization opportunities
  List<String> _identifyPersonalizationOpportunities(
    Map<String, dynamic> behavior,
  ) {
    final opportunities = <String>[];

    final preferredEntities = behavior['preferredEntities'] as List? ?? [];
    if (preferredEntities.isNotEmpty) {
      opportunities.add(
        'Prioritize ${preferredEntities.first} in search results',
      );
    }

    return opportunities;
  }

  /// Calculate engagement score
  double _calculateEngagementScore(Map<String, dynamic> behavior) {
    final searchFrequency = behavior['searchFrequency'] as String? ?? 'low';
    final avgResultsClicked = behavior['averageResultsClicked'] as int? ?? 0;

    double score = 0.0;

    switch (searchFrequency) {
      case 'high':
        score += 0.4;
        break;
      case 'medium':
        score += 0.3;
        break;
      case 'low':
        score += 0.1;
        break;
    }

    score += (avgResultsClicked * 0.1).clamp(0.0, 0.6);

    return score;
  }

  /// Grade cache performance
  String _gradeCachePerformance(double cacheHitRate) {
    if (cacheHitRate >= 0.9) return 'excellent';
    if (cacheHitRate >= 0.8) return 'good';
    if (cacheHitRate >= 0.7) return 'fair';
    return 'poor';
  }

  /// Categorize queries
  Map<String, int> _categorizeQueries(List<String> queries) {
    final categories = <String, int>{};

    for (final query in queries) {
      if (query.contains('asset') || query.contains('equipment')) {
        categories['assets'] = (categories['assets'] ?? 0) + 1;
      } else if (query.contains('plant') || query.contains('facility')) {
        categories['plants'] = (categories['plants'] ?? 0) + 1;
      } else {
        categories['other'] = (categories['other'] ?? 0) + 1;
      }
    }

    return categories;
  }
}

/// Result classes

class AnalyticsTrackingResult {
  final bool success;
  final SearchAnalyticsEntity? analytics;
  final String? error;

  const AnalyticsTrackingResult({
    required this.success,
    this.analytics,
    this.error,
  });

  factory AnalyticsTrackingResult.success({
    required SearchAnalyticsEntity analytics,
  }) {
    return AnalyticsTrackingResult(success: true, analytics: analytics);
  }

  factory AnalyticsTrackingResult.failure({required String error}) {
    return AnalyticsTrackingResult(success: false, error: error);
  }
}

class SearchStatisticsResult {
  final bool success;
  final Map<String, dynamic>? statistics;
  final String? period;
  final Map<String, dynamic>? additionalInsights;
  final String? error;

  const SearchStatisticsResult({
    required this.success,
    this.statistics,
    this.period,
    this.additionalInsights,
    this.error,
  });

  factory SearchStatisticsResult.success({
    required Map<String, dynamic> statistics,
    required String period,
    Map<String, dynamic>? additionalInsights,
  }) {
    return SearchStatisticsResult(
      success: true,
      statistics: statistics,
      period: period,
      additionalInsights: additionalInsights,
    );
  }

  factory SearchStatisticsResult.failure({required String error}) {
    return SearchStatisticsResult(success: false, error: error);
  }

  factory SearchStatisticsResult.invalid(String error) {
    return SearchStatisticsResult(success: false, error: error);
  }
}

class UserBehaviorResult {
  final bool success;
  final Map<String, dynamic>? behavior;
  final Map<String, dynamic>? insights;
  final List<String>? recommendations;
  final String? error;

  const UserBehaviorResult({
    required this.success,
    this.behavior,
    this.insights,
    this.recommendations,
    this.error,
  });

  factory UserBehaviorResult.success({
    required Map<String, dynamic> behavior,
    required Map<String, dynamic> insights,
    required List<String> recommendations,
  }) {
    return UserBehaviorResult(
      success: true,
      behavior: behavior,
      insights: insights,
      recommendations: recommendations,
    );
  }

  factory UserBehaviorResult.failure({required String error}) {
    return UserBehaviorResult(success: false, error: error);
  }
}

class PerformanceMetricsResult {
  final bool success;
  final Map<String, dynamic>? metrics;
  final List<String>? issues;
  final List<String>? recommendations;
  final String? period;
  final String? error;

  const PerformanceMetricsResult({
    required this.success,
    this.metrics,
    this.issues,
    this.recommendations,
    this.period,
    this.error,
  });

  factory PerformanceMetricsResult.success({
    required Map<String, dynamic> metrics,
    required List<String> issues,
    required List<String> recommendations,
    required String period,
  }) {
    return PerformanceMetricsResult(
      success: true,
      metrics: metrics,
      issues: issues,
      recommendations: recommendations,
      period: period,
    );
  }

  factory PerformanceMetricsResult.failure({required String error}) {
    return PerformanceMetricsResult(success: false, error: error);
  }
}

class SearchTrendsResult {
  final bool success;
  final List<TrendingQuery>? trends;
  final String? trendType;
  final String? period;
  final Map<String, dynamic>? insights;
  final String? error;

  const SearchTrendsResult({
    required this.success,
    this.trends,
    this.trendType,
    this.period,
    this.insights,
    this.error,
  });

  factory SearchTrendsResult.success({
    required List<TrendingQuery> trends,
    required String trendType,
    required String period,
    required Map<String, dynamic> insights,
  }) {
    return SearchTrendsResult(
      success: true,
      trends: trends,
      trendType: trendType,
      period: period,
      insights: insights,
    );
  }

  factory SearchTrendsResult.failure({required String error}) {
    return SearchTrendsResult(success: false, error: error);
  }
}

class OptimizationResult {
  final bool success;
  final List<OptimizationRecommendation>? recommendations;
  final String? scope;
  final String? error;

  const OptimizationResult({
    required this.success,
    this.recommendations,
    this.scope,
    this.error,
  });

  factory OptimizationResult.success({
    required List<OptimizationRecommendation> recommendations,
    required String scope,
  }) {
    return OptimizationResult(
      success: true,
      recommendations: recommendations,
      scope: scope,
    );
  }

  factory OptimizationResult.failure({required String error}) {
    return OptimizationResult(success: false, error: error);
  }
}

class CleanupResult {
  final bool success;
  final int? removedEntries;
  final int? preservedSummaries;
  final DateTime? cutoffDate;
  final String? error;

  const CleanupResult({
    required this.success,
    this.removedEntries,
    this.preservedSummaries,
    this.cutoffDate,
    this.error,
  });

  factory CleanupResult.success({
    required int removedEntries,
    required int preservedSummaries,
    required DateTime cutoffDate,
  }) {
    return CleanupResult(
      success: true,
      removedEntries: removedEntries,
      preservedSummaries: preservedSummaries,
      cutoffDate: cutoffDate,
    );
  }

  factory CleanupResult.failure({required String error}) {
    return CleanupResult(success: false, error: error);
  }
}

/// Supporting classes

class TrendingQuery {
  final String query;
  final int count;
  final double changePercent;

  const TrendingQuery(this.query, this.count, this.changePercent);
}

class OptimizationRecommendation {
  final String type;
  final String title;
  final String description;
  final int priority;
  final String estimatedImpact;

  const OptimizationRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.estimatedImpact,
  });
}

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

  const DashboardMetrics({
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
    this.error,
  });

  factory DashboardMetrics.error(String error) {
    return DashboardMetrics(
      currentSearchVolume: 0,
      successRate: 0.0,
      avgResponseTime: 0.0,
      cacheHitRate: 0.0,
      activeUsers: 0,
      topQueries: [],
      errorRate: 1.0,
      performanceGrade: 'F',
      systemHealth: 'error',
      lastUpdated: DateTime.now(),
      error: error,
    );
  }

  bool get hasError => error != null;
  bool get isHealthy => systemHealth == 'healthy' && errorRate < 0.1;
  bool get isPerformant => performanceGrade == 'A' || performanceGrade == 'B';
}
