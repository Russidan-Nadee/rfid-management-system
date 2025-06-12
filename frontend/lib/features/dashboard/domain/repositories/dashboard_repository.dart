// Path: frontend/lib/features/dashboard/domain/repositories/dashboard_repository.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/dashboard_stats.dart';
import '../entities/overview_data.dart';

abstract class DashboardRepository {
  /// Get complete dashboard statistics including overview and charts
  /// [forceRefresh] bypasses cache and fetches fresh data
  Future<Either<Failure, DashboardStats>> getDashboardStats({
    bool forceRefresh = false,
  });

  /// Get overview data only (lightweight alternative)
  /// [forceRefresh] bypasses cache and fetches fresh data
  Future<Either<Failure, OverviewData>> getOverviewData({
    bool forceRefresh = false,
  });

  /// Get quick statistics for immediate display
  /// Returns raw data map for flexibility
  Future<Either<Failure, Map<String, dynamic>>> getQuickStats();

  /// Force refresh all dashboard data and clear cache
  Future<Either<Failure, Unit>> refreshDashboardData();

  /// Check if cached data is still valid
  Future<Either<Failure, bool>> isCacheValid();

  /// Clear all cached dashboard data
  Future<Either<Failure, Unit>> clearCache();
}
