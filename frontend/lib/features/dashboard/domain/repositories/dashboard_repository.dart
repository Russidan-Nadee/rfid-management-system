// Path: frontend/lib/features/dashboard/domain/repositories/dashboard_repository.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/dashboard_stats.dart';
import '../entities/overview_data.dart';
import '../entities/alert.dart';
import '../entities/recent_activity.dart';
import '../entities/department_analytics.dart';
import '../entities/growth_trends.dart';
import '../entities/location_analytics.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardStats>> getDashboardStats({
    String period = 'today',
    bool forceRefresh = false,
  });

  Future<Either<Failure, OverviewData>> getOverviewData({
    String period = '7d',
    bool forceRefresh = false,
  });

  Future<Either<Failure, Map<String, dynamic>>> getQuickStats({
    String period = 'today',
  });

  Future<Either<Failure, List<Alert>>> getAlerts({bool forceRefresh = false});

  Future<Either<Failure, RecentActivity>> getRecentActivities({
    String period = '7d',
    bool forceRefresh = false,
  });

  Future<Either<Failure, DepartmentAnalytics>> getAssetsByDepartment({
    String? plantCode,
    bool forceRefresh = false,
  });

  Future<Either<Failure, GrowthTrends>> getGrowthTrends({
    String? deptCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    bool forceRefresh = false,
  });

  Future<Either<Failure, LocationAnalytics>> getLocationAnalytics({
    String? locationCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    bool includeTrends = true,
    bool forceRefresh = false,
  });

  Future<Either<Failure, Map<String, dynamic>>> getAuditProgress({
    String? deptCode,
    bool includeDetails = false,
    String? auditStatus,
    bool forceRefresh = false,
  });

  Future<Either<Failure, Unit>> refreshDashboardData({String period = 'today'});

  Future<Either<Failure, bool>> isCacheValid(String cacheKey);

  Future<Either<Failure, Unit>> clearCache();

  Future<Either<Failure, Unit>> clearPeriodCache(String period);
}
