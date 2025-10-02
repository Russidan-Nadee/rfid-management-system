// Path: frontend/lib/features/dashboard/data/repositories/dashboard_repository_impl.dart
import 'package:tp_rfid/features/dashboard/data/models/location_analytics_model.dart';
import 'package:tp_rfid/features/dashboard/domain/entities/location_analytics.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/asset_distribution.dart';
import '../../domain/entities/growth_trend.dart';
import '../../domain/entities/audit_progress.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../datasources/dashboard_cache_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final DashboardCacheDataSource cacheDataSource;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.cacheDataSource,
  });

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats(
    String period,
  ) async {
    try {
      final remoteStats = await remoteDataSource.getDashboardStats(period);
      return Right(_mapDashboardStatsModelToEntity(remoteStats));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, AssetDistribution>> getAssetDistribution(
    String? plantCode,
    String? deptCode,
  ) async {
    try {
      final remoteDistribution = await remoteDataSource.getAssetDistribution(
        plantCode,
        deptCode,
      );
      return Right(_mapAssetDistributionModelToEntity(remoteDistribution));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, GrowthTrend>> getGrowthTrends({
    String? deptCode,
    String? locationCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    String groupBy = 'day',
  }) async {
    try {
      final remoteTrends = await remoteDataSource.getGrowthTrends(
        deptCode: deptCode,
        locationCode: locationCode,
        period: period,
        year: year,
        startDate: startDate,
        endDate: endDate,
        groupBy: groupBy,
      );
      return Right(_mapGrowthTrendModelToEntity(remoteTrends));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, AuditProgress>> getAuditProgress({
    String? deptCode,
    bool includeDetails = false,
    String? auditStatus,
  }) async {
    try {
      final remoteProgress = await remoteDataSource.getAuditProgress(
        deptCode: deptCode,
        includeDetails: includeDetails,
        auditStatus: auditStatus,
      );
      return Right(_mapAuditProgressModelToEntity(remoteProgress));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearDashboardCache() async {
    try {
      await cacheDataSource.clearDashboardCache();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to clear cache: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, String>>>> getLocations({
    String? plantCode,
  }) async {
    try {
      final locations = await remoteDataSource.getLocations(
        plantCode: plantCode,
      );

      final formattedLocations = locations
          .map(
            (location) => {
              'code': location['code']?.toString() ?? '',
              'name': location['name']?.toString() ?? '',
            },
          )
          .toList();

      return Right(formattedLocations);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, LocationAnalytics>> getLocationAnalytics({
    String? locationCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    bool includeTrends = true,
  }) async {
    try {
      final remoteAnalytics = await remoteDataSource.getLocationAnalytics(
        locationCode: locationCode,
        period: period,
        year: year,
        startDate: startDate,
        endDate: endDate,
        includeTrends: includeTrends,
      );
      return Right(_mapLocationAnalyticsModelToEntity(remoteAnalytics));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  // Private mapping methods to convert models to entities
  DashboardStats _mapDashboardStatsModelToEntity(model) {
    return DashboardStats(
      overview: DashboardOverview(
        totalAssets: AssetCount(
          value: model.overview.totalAssets.value,
          changePercent: model.overview.totalAssets.changePercent,
          trend: model.overview.totalAssets.trend,
        ),
        activeAssets: AssetCount(
          value: model.overview.activeAssets.value,
          changePercent: model.overview.activeAssets.changePercent,
          trend: model.overview.activeAssets.trend,
        ),
        inactiveAssets: AssetCount(
          value: model.overview.inactiveAssets.value,
          changePercent: model.overview.inactiveAssets.changePercent,
          trend: model.overview.inactiveAssets.trend,
        ),
        createdAssets: AssetCount(
          value: model.overview.createdAssets.value,
          changePercent: model.overview.createdAssets.changePercent,
          trend: model.overview.createdAssets.trend,
        ),
        scans: ScanCount(
          value: model.overview.scans.value,
          changePercent: model.overview.scans.changePercent,
          trend: model.overview.scans.trend,
          previousValue: model.overview.scans.previousValue,
        ),
        exportSuccess: ExportCount(
          value: model.overview.exportSuccess.value,
          changePercent: model.overview.exportSuccess.changePercent,
          trend: model.overview.exportSuccess.trend,
          previousValue: model.overview.exportSuccess.previousValue,
        ),
        exportFailed: ExportCount(
          value: model.overview.exportFailed.value,
          changePercent: model.overview.exportFailed.changePercent,
          trend: model.overview.exportFailed.trend,
          previousValue: model.overview.exportFailed.previousValue,
        ),
        totalPlants: model.overview.totalPlants,
        totalLocations: model.overview.totalLocations,
        totalUsers: model.overview.totalUsers,
      ),
      charts: DashboardCharts(
        assetStatusPie: AssetStatusPie(
          active: model.charts.assetStatusPie.active,
          inactive: model.charts.assetStatusPie.inactive,
          created: model.charts.assetStatusPie.created,
          total: model.charts.assetStatusPie.total,
        ),
        scanTrend7d: model.charts.scanTrend7d
            .map<ScanTrend>(
              (scanModel) => ScanTrend(
                date: scanModel.date,
                count: scanModel.count,
                dayName: scanModel.dayName,
              ),
            )
            .toList(),
      ),
      periodInfo: DashboardPeriodInfo(
        period: model.periodInfo.period,
        startDate: model.periodInfo.startDate,
        endDate: model.periodInfo.endDate,
        comparisonPeriod: ComparisonPeriod(
          startDate: model.periodInfo.comparisonPeriod.startDate,
          endDate: model.periodInfo.comparisonPeriod.endDate,
        ),
      ),
    );
  }

  AssetDistribution _mapAssetDistributionModelToEntity(model) {
    return AssetDistribution(
      pieChartData: model.pieChartData
          .map<PieChartData>(
            (pieModel) => PieChartData(
              name: pieModel.name,
              value: pieModel.value,
              percentage: pieModel.percentage,
              deptCode: pieModel.deptCode,
              plantCode: pieModel.plantCode,
              plantDescription: pieModel.plantDescription,
            ),
          )
          .toList(),
      summary: DistributionSummary(
        totalAssets: model.summary.totalAssets,
        assignedAssets: model.summary.assignedAssets,
        unassignedAssets: model.summary.unassignedAssets,
        totalDepartments: model.summary.totalDepartments,
        plantFilter: model.summary.plantFilter,
      ),
      filterInfo: FilterInfo(
        appliedFilters: AppliedFilters(
          plantCode: model.filterInfo.appliedFilters.plantCode,
        ),
      ),
    );
  }

  GrowthTrend _mapGrowthTrendModelToEntity(model) {
    return GrowthTrend(
      trends: model.trends
          .map<TrendData>(
            (trendModel) => TrendData(
              period: trendModel.period,
              assetCount: trendModel.assetCount,
              growthPercentage: trendModel.growthPercentage,
              cumulativeCount: trendModel.cumulativeCount,
              deptCode: trendModel.deptCode,
              deptDescription: trendModel.deptDescription,
            ),
          )
          .toList(),
      periodInfo: TrendPeriodInfo(
        period: model.periodInfo.period,
        year: model.periodInfo.year,
        startDate: model.periodInfo.startDate,
        endDate: model.periodInfo.endDate,
        totalGrowth: model.periodInfo.totalGrowth,
      ),
      summary: TrendSummary(
        totalPeriods: model.summary.totalPeriods,
        totalGrowth: model.summary.totalGrowth,
        averageGrowth: model.summary.averageGrowth,
      ),
    );
  }

  AuditProgress _mapAuditProgressModelToEntity(model) {
    return AuditProgress(
      auditProgress: model.auditProgress
          .map<DepartmentProgress>(
            (deptModel) => DepartmentProgress(
              deptCode: deptModel.deptCode,
              deptDescription: deptModel.deptDescription,
              totalAssets: deptModel.totalAssets,
              auditedAssets: deptModel.auditedAssets,
              pendingAudit: deptModel.pendingAudit,
              completionPercentage: deptModel.completionPercentage,
            ),
          )
          .toList(),
      overallProgress: model.overallProgress != null
          ? OverallProgress(
              totalAssets: model.overallProgress!.totalAssets,
              auditedAssets: model.overallProgress!.auditedAssets,
              pendingAudit: model.overallProgress!.pendingAudit,
              completionPercentage: model.overallProgress!.completionPercentage,
            )
          : null,
      recommendations: model.recommendations
          .map<Recommendation>(
            (recModel) => Recommendation(
              type: recModel.type,
              message: recModel.message,
              action: recModel.action,
              deptCode: recModel.deptCode,
            ),
          )
          .toList(),
      auditInfo: AuditInfo(
        auditPeriod: model.auditInfo.auditPeriod,
        generatedAt: model.auditInfo.generatedAt,
        filtersApplied: AuditFilters(
          deptCode: model.auditInfo.filtersApplied.deptCode,
          auditStatus: model.auditInfo.filtersApplied.auditStatus,
          includeDetails: model.auditInfo.filtersApplied.includeDetails,
        ),
      ),
    );
  }

  LocationAnalytics _mapLocationAnalyticsModelToEntity(
    LocationAnalyticsModel model,
  ) {
    return LocationAnalytics(
      locationTrends: model.locationTrends
          .map<LocationTrendData>(
            (trendModel) => LocationTrendData(
              monthYear: trendModel.monthYear,
              assetCount: trendModel.assetCount,
              activeCount: trendModel.activeCount,
              growthPercentage: trendModel.growthPercentage,
              locationCode: trendModel.locationCode,
              locationDescription: trendModel.locationDescription,
              plantCode: trendModel.plantCode,
              plantDescription: trendModel.plantDescription,
            ),
          )
          .toList(),
      periodInfo: LocationTrendPeriodInfo(
        period: model.periodInfo.period,
        year: model.periodInfo.year,
        startDate: model.periodInfo.startDate,
        endDate: model.periodInfo.endDate,
        locationCode: model.periodInfo.locationCode,
      ),
      summary: LocationTrendSummary(
        totalPeriods: model.summary.totalPeriods,
        totalGrowth: model.summary.totalGrowth,
        averageGrowth: model.summary.averageGrowth,
      ),
    );
  }
}
