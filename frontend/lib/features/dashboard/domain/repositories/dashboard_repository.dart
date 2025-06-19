// Path: frontend/lib/features/dashboard/domain/repositories/dashboard_repository.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/dashboard_stats.dart';
import '../entities/asset_distribution.dart';
import '../entities/growth_trend.dart';
import '../entities/audit_progress.dart';

abstract class DashboardRepository {
  /// Get dashboard statistics for a specific period
  ///
  /// [period] can be 'today', '7d', or '30d'
  /// Returns [DashboardStats] containing overview, charts, and period information
  Future<Either<Failure, DashboardStats>> getDashboardStats(String period);

  /// Get asset distribution by department/plant
  ///
  /// [plantCode] optional filter for specific plant
  /// Returns [AssetDistribution] containing pie chart data and summary
  Future<Either<Failure, AssetDistribution>> getAssetDistribution(
    String? plantCode,
  );

  /// Get growth trends for assets over time
  ///
  /// [deptCode] optional department filter
  /// [period] time period: 'Q1', 'Q2', 'Q3', 'Q4', '1Y', 'custom'
  /// [year] year for quarterly/yearly data
  /// [startDate] start date for custom period (YYYY-MM-DD)
  /// [endDate] end date for custom period (YYYY-MM-DD)
  /// Returns [GrowthTrend] containing trend data and analytics
  Future<Either<Failure, GrowthTrend>> getGrowthTrends({
    String? deptCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
  });

  /// Get audit progress and completion status
  ///
  /// [deptCode] optional department filter
  /// [includeDetails] whether to include detailed asset audit data
  /// [auditStatus] filter by audit status: 'audited', 'never_audited', 'overdue'
  /// Returns [AuditProgress] containing progress data and recommendations
  Future<Either<Failure, AuditProgress>> getAuditProgress({
    String? deptCode,
    bool includeDetails = false,
    String? auditStatus,
  });

  /// Clear all dashboard-related cache
  ///
  /// Returns [Unit] on success or [Failure] on error
  Future<Either<Failure, Unit>> clearDashboardCache();
}
