// Path: frontend/lib/features/dashboard/domain/repositories/dashboard_repository.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/dashboard_stats.dart';
import '../entities/overview_data.dart';
import '../entities/alert.dart';
import '../entities/recent_activity.dart';
import '../entities/department_analytics.dart';
import '../entities/growth_trends.dart';

abstract class DashboardRepository {
  /// Get complete dashboard statistics including overview and charts
  /// [period] - Time period filter: 'today', '7d', '30d'
  /// [forceRefresh] bypasses cache and fetches fresh data
  Future<Either<Failure, DashboardStats>> getDashboardStats({
    String period = 'today',
    bool forceRefresh = false,
  });

  /// Get overview data only (lightweight alternative)
  /// [period] - Time period filter: 'today', '7d', '30d'
  /// [forceRefresh] bypasses cache and fetches fresh data
  Future<Either<Failure, OverviewData>> getOverviewData({
    String period = '7d',
    bool forceRefresh = false,
  });

  /// Get quick statistics for immediate display
  /// [period] - Time period filter: 'today', '7d', '30d'
  /// Returns raw data map for flexibility
  Future<Either<Failure, Map<String, dynamic>>> getQuickStats({
    String period = 'today',
  });

  /// Get system alerts and notifications
  /// [forceRefresh] bypasses cache and fetches fresh data
  Future<Either<Failure, List<Alert>>> getAlerts({bool forceRefresh = false});

  /// Get recent activities (scans and exports)
  /// [period] - Time period filter: 'today', '7d', '30d'
  /// [forceRefresh] bypasses cache and fetches fresh data
  Future<Either<Failure, RecentActivity>> getRecentActivities({
    String period = '7d',
    bool forceRefresh = false,
  });

  /// Get department analytics with asset distribution by plant
  /// [plantCode] - Filter by specific plant (optional)
  /// [forceRefresh] bypasses cache and fetches fresh data
  Future<Either<Failure, DepartmentAnalytics>> getAssetsByDepartment({
    String? plantCode,
    bool forceRefresh = false,
  });

  /// Get growth trends by department/location with configurable periods
  /// [deptCode] - Filter by department (optional)
  /// [period] - Time period: Q1|Q2|Q3|Q4|1Y|custom
  /// [year] - Year for quarterly/yearly data
  /// [startDate] - Start date for custom period (YYYY-MM-DD)
  /// [endDate] - End date for custom period (YYYY-MM-DD)
  /// [forceRefresh] bypasses cache and fetches fresh data
  Future<Either<Failure, GrowthTrends>> getGrowthTrends({
    String? deptCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    bool forceRefresh = false,
  });

  /// Get location analytics and utilization data
  /// [locationCode] - Filter by specific location (optional)
  /// [period] - Time period for trends: Q1|Q2|Q3|Q4|1Y|custom
  /// [year] - Year for trend data
  /// [startDate] - Start date for custom period (YYYY-MM-DD)
  /// [endDate] - End date for custom period (YYYY-MM-DD)
  /// [includeTrends] - Include growth trends in response
  /// [forceRefresh] bypasses cache and fetches fresh data
  Future<Either<Failure, Map<String, dynamic>>> getLocationAnalytics({
    String? locationCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    bool includeTrends = true,
    bool forceRefresh = false,
  });

  /// Get audit progress and completion status
  /// [deptCode] - Filter by department (optional)
  /// [includeDetails] - Include detailed asset audit data
  /// [auditStatus] - Filter by audit status: audited|never_audited|overdue
  /// [forceRefresh] bypasses cache and fetches fresh data
  Future<Either<Failure, Map<String, dynamic>>> getAuditProgress({
    String? deptCode,
    bool includeDetails = false,
    String? auditStatus,
    bool forceRefresh = false,
  });

  /// Force refresh dashboard data for specific period and clear cache
  /// [period] - Time period to refresh: 'today', '7d', '30d'
  Future<Either<Failure, Unit>> refreshDashboardData({String period = 'today'});

  /// Check if cached data is still valid for specific cache key
  Future<Either<Failure, bool>> isCacheValid(String cacheKey);

  /// Clear all cached dashboard data
  Future<Either<Failure, Unit>> clearCache();

  /// Clear cached data for specific period
  /// [period] - Period to clear: 'today', '7d', '30d'
  Future<Either<Failure, Unit>> clearPeriodCache(String period);
}
