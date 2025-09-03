import 'package:tp_rfid/features/dashboard/domain/entities/location_analytics.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/dashboard_stats.dart';
import '../entities/asset_distribution.dart';
import '../entities/growth_trend.dart';
import '../entities/audit_progress.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardStats>> getDashboardStats(String period);

  Future<Either<Failure, AssetDistribution>> getAssetDistribution(
    String? plantCode,
    String? deptCode,
  );

  Future<Either<Failure, GrowthTrend>> getGrowthTrends({
    String? deptCode,
    String? locationCode, // เพิ่มบรรทัดนี้
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    String groupBy = 'day',
  });

  Future<Either<Failure, AuditProgress>> getAuditProgress({
    String? deptCode,
    bool includeDetails = false,
    String? auditStatus,
  });
  Future<Either<Failure, LocationAnalytics>> getLocationAnalytics({
    String? locationCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    bool includeTrends = true,
  });

  Future<Either<Failure, List<Map<String, String>>>> getLocations({
    String? plantCode,
  });

  Future<Either<Failure, Unit>> clearDashboardCache();
}
