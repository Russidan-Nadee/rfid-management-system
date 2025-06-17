// Path: frontend/lib/features/dashboard/data/repositories/dashboard_repository_impl.dart
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/core/utils/either.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:frontend/features/dashboard/domain/entities/overview_data.dart';
import 'package:frontend/features/dashboard/domain/entities/alert.dart';
import 'package:frontend/features/dashboard/domain/entities/recent_activity.dart';
import 'package:frontend/features/dashboard/domain/entities/department_analytics.dart';
import 'package:frontend/features/dashboard/domain/entities/growth_trends.dart';
import 'package:frontend/features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../../../core/errors/exceptions.dart';
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
  Future<Either<Failure, DashboardStats>> getDashboardStats({
    String period = 'today',
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cachedStats = await cacheDataSource.getCachedStats(period);
        if (cachedStats != null) {
          return Right(cachedStats.toEntity());
        }
      }

      final statsModel = await remoteDataSource.getDashboardStats(
        period: period,
      );
      await cacheDataSource.cacheStats(statsModel, period);
      return Right(statsModel.toEntity());
    } on ServerException {
      return Left(ServerFailure('Failed to get dashboard statistics'));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, OverviewData>> getOverviewData({
    String period = '7d',
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cachedOverview = await cacheDataSource.getCachedOverview(period);
        if (cachedOverview != null) {
          return Right(cachedOverview.toEntity());
        }
      }

      final overviewModel = await remoteDataSource.getOverviewData(
        period: period,
      );
      await cacheDataSource.cacheOverview(overviewModel, period);
      return Right(overviewModel.toEntity());
    } on ServerException {
      return Left(ServerFailure('Failed to get overview data'));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getQuickStats({
    String period = 'today',
  }) async {
    try {
      final quickStats = await remoteDataSource.getQuickStats(period: period);
      return Right(quickStats);
    } on ServerException {
      return Left(ServerFailure('Failed to get quick statistics'));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<Alert>>> getAlerts({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cachedAlerts = await cacheDataSource.getCachedAlerts();
        if (cachedAlerts != null) {
          return Right(cachedAlerts.map((alert) => alert.toEntity()).toList());
        }
      }

      final alertModels = await remoteDataSource.getAlerts();
      await cacheDataSource.cacheAlerts(alertModels);
      final alerts = alertModels.map((model) => model.toEntity()).toList();
      return Right(alerts);
    } on ServerException {
      return Left(ServerFailure('Failed to get alerts'));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, RecentActivity>> getRecentActivities({
    String period = '7d',
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cachedActivities = await cacheDataSource
            .getCachedRecentActivities(period);
        if (cachedActivities != null) {
          return Right(cachedActivities.toEntity());
        }
      }

      final activitiesModel = await remoteDataSource.getRecentActivities(
        period: period,
      );
      await cacheDataSource.cacheRecentActivities(activitiesModel, period);
      return Right(activitiesModel.toEntity());
    } on ServerException {
      return Left(ServerFailure('Failed to get recent activities'));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, DepartmentAnalytics>> getAssetsByDepartment({
    String? plantCode,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = (cacheDataSource as DashboardCacheDataSourceImpl)
          .generateDepartmentAnalyticsCacheKey(plantCode: plantCode);

      if (!forceRefresh) {
        final cachedAnalytics = await cacheDataSource
            .getCachedDepartmentAnalytics(cacheKey);
        if (cachedAnalytics != null) {
          return Right(cachedAnalytics.toEntity());
        }
      }

      final analyticsModel = await remoteDataSource.getAssetsByDepartment(
        plantCode: plantCode,
      );
      await cacheDataSource.cacheDepartmentAnalytics(analyticsModel, cacheKey);
      return Right(analyticsModel.toEntity());
    } on ServerException {
      return Left(ServerFailure('Failed to get department analytics'));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, GrowthTrends>> getGrowthTrends({
    String? deptCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = (cacheDataSource as DashboardCacheDataSourceImpl)
          .generateGrowthTrendsCacheKey(
            deptCode: deptCode,
            period: period,
            year: year,
            startDate: startDate,
            endDate: endDate,
          );

      if (!forceRefresh) {
        final cachedTrends = await cacheDataSource.getCachedGrowthTrends(
          cacheKey,
        );
        if (cachedTrends != null) {
          return Right(cachedTrends.toEntity());
        }
      }

      final trendsModel = await remoteDataSource.getGrowthTrends(
        deptCode: deptCode,
        period: period,
        year: year,
        startDate: startDate,
        endDate: endDate,
      );

      await cacheDataSource.cacheGrowthTrends(trendsModel, cacheKey);
      return Right(trendsModel.toEntity());
    } on ServerException {
      return Left(ServerFailure('Failed to get growth trends'));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLocationAnalytics({
    String? locationCode,
    String period = 'Q2',
    int? year,
    String? startDate,
    String? endDate,
    bool includeTrends = true,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = (cacheDataSource as DashboardCacheDataSourceImpl)
          .generateLocationAnalyticsCacheKey(
            locationCode: locationCode,
            period: period,
            year: year,
            startDate: startDate,
            endDate: endDate,
            includeTrends: includeTrends,
          );

      if (!forceRefresh) {
        final cachedAnalytics = await cacheDataSource
            .getCachedLocationAnalytics(cacheKey);
        if (cachedAnalytics != null) {
          return Right(cachedAnalytics);
        }
      }

      final analyticsData = await remoteDataSource.getLocationAnalytics(
        locationCode: locationCode,
        period: period,
        year: year,
        startDate: startDate,
        endDate: endDate,
        includeTrends: includeTrends,
      );

      await cacheDataSource.cacheLocationAnalytics(analyticsData, cacheKey);
      return Right(analyticsData);
    } on ServerException {
      return Left(ServerFailure('Failed to get location analytics'));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAuditProgress({
    String? deptCode,
    bool includeDetails = false,
    String? auditStatus,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = (cacheDataSource as DashboardCacheDataSourceImpl)
          .generateAuditProgressCacheKey(
            deptCode: deptCode,
            includeDetails: includeDetails,
            auditStatus: auditStatus,
          );

      if (!forceRefresh) {
        final cachedProgress = await cacheDataSource.getCachedAuditProgress(
          cacheKey,
        );
        if (cachedProgress != null) {
          return Right(cachedProgress);
        }
      }

      final progressData = await remoteDataSource.getAuditProgress(
        deptCode: deptCode,
        includeDetails: includeDetails,
        auditStatus: auditStatus,
      );

      await cacheDataSource.cacheAuditProgress(progressData, cacheKey);
      return Right(progressData);
    } on ServerException {
      return Left(ServerFailure('Failed to get audit progress'));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Unit>> refreshDashboardData({
    String period = 'today',
  }) async {
    try {
      await cacheDataSource.clearPeriodCache(period);
      await Future.wait([
        getDashboardStats(period: period, forceRefresh: true),
        getOverviewData(period: period, forceRefresh: true),
        getRecentActivities(period: period, forceRefresh: true),
        getAlerts(forceRefresh: true),
      ]);
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to refresh dashboard data'));
    }
  }

  @override
  Future<Either<Failure, bool>> isCacheValid(String cacheKey) async {
    try {
      final isValid = await cacheDataSource.isCacheValid(cacheKey);
      return Right(isValid);
    } catch (e) {
      return Left(CacheFailure('Failed to check cache validity'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCache() async {
    try {
      await cacheDataSource.clearCache();
      return Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to clear cache'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearPeriodCache(String period) async {
    try {
      await cacheDataSource.clearPeriodCache(period);
      return Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to clear period cache'));
    }
  }
}
