// Path: frontend/lib/features/dashboard/domain/repositories/dashboard_repository.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/dashboard_stats.dart';
import '../entities/overview_data.dart';
import '../../data/models/alert_model.dart';
import '../../data/models/recent_activity_model.dart';

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
  Future<Either<Failure, List<AlertModel>>> getAlerts({
    bool forceRefresh = false,
  });

  /// Get recent activities (scans and exports)
  /// [period] - Time period filter: 'today', '7d', '30d'
  /// [forceRefresh] bypasses cache and fetches fresh data
  Future<Either<Failure, RecentActivityModel>> getRecentActivities({
    String period = '7d',
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
