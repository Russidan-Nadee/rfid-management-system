// Path: frontend/lib/features/dashboard/data/repositories/dashboard_repository_impl.dart
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/core/utils/either.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:frontend/features/dashboard/domain/entities/overview_data.dart';
import 'package:frontend/features/dashboard/domain/entities/alert.dart';
import 'package:frontend/features/dashboard/domain/entities/recent_activity.dart';
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
      // Try cache first (if not force refresh)
      if (!forceRefresh) {
        final cachedStats = await cacheDataSource.getCachedStats(period);
        if (cachedStats != null) {
          return Right(cachedStats.toEntity());
        }
      }

      // Fetch from API
      final statsModel = await remoteDataSource.getDashboardStats(
        period: period,
      );

      // Cache the result
      await cacheDataSource.cacheStats(statsModel, period);

      return Right(statsModel.toEntity());
    } on ServerException {
      return Left(ServerFailure('Failed to get dashboard statistics'));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    } on CacheException {
      // If cache fails, try to get from remote anyway
      try {
        final statsModel = await remoteDataSource.getDashboardStats(
          period: period,
        );
        return Right(statsModel.toEntity());
      } catch (e) {
        return Left(ServerFailure('Failed to get dashboard statistics'));
      }
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
      // Try cache first (if not force refresh)
      if (!forceRefresh) {
        final cachedOverview = await cacheDataSource.getCachedOverview(period);
        if (cachedOverview != null) {
          return Right(cachedOverview.toEntity());
        }
      }

      // Fetch from API
      final overviewModel = await remoteDataSource.getOverviewData(
        period: period,
      );

      // Cache the result
      await cacheDataSource.cacheOverview(overviewModel, period);

      return Right(overviewModel.toEntity());
    } on ServerException {
      return Left(ServerFailure('Failed to get overview data'));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    } on CacheException {
      // If cache fails, try to get from remote anyway
      try {
        final overviewModel = await remoteDataSource.getOverviewData(
          period: period,
        );
        return Right(overviewModel.toEntity());
      } catch (e) {
        return Left(ServerFailure('Failed to get overview data'));
      }
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
      // Try cache first (if not force refresh)
      if (!forceRefresh) {
        final cachedAlerts = await cacheDataSource.getCachedAlerts();
        if (cachedAlerts != null) {
          return Right(cachedAlerts.map((alert) => alert.toEntity()).toList());
        }
      }

      // Fetch from API
      final alertModels = await remoteDataSource.getAlerts();

      // Cache the result
      await cacheDataSource.cacheAlerts(alertModels);

      // Convert to entities
      final alerts = alertModels.map((model) => model.toEntity()).toList();
      return Right(alerts);
    } on ServerException {
      return Left(ServerFailure('Failed to get alerts'));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    } on CacheException {
      // If cache fails, try to get from remote anyway
      try {
        final alertModels = await remoteDataSource.getAlerts();
        final alerts = alertModels.map((model) => model.toEntity()).toList();
        return Right(alerts);
      } catch (e) {
        return Left(ServerFailure('Failed to get alerts'));
      }
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
      // Try cache first (if not force refresh)
      if (!forceRefresh) {
        final cachedActivities = await cacheDataSource
            .getCachedRecentActivities(period);
        if (cachedActivities != null) {
          return Right(cachedActivities.toEntity());
        }
      }

      // Fetch from API
      final activitiesModel = await remoteDataSource.getRecentActivities(
        period: period,
      );

      // Cache the result
      await cacheDataSource.cacheRecentActivities(activitiesModel, period);

      return Right(activitiesModel.toEntity());
    } on ServerException {
      return Left(ServerFailure('Failed to get recent activities'));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    } on CacheException {
      // If cache fails, try to get from remote anyway
      try {
        final activitiesModel = await remoteDataSource.getRecentActivities(
          period: period,
        );
        return Right(activitiesModel.toEntity());
      } catch (e) {
        return Left(ServerFailure('Failed to get recent activities'));
      }
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Unit>> refreshDashboardData({
    String period = 'today',
  }) async {
    try {
      // Clear period-specific cache
      await cacheDataSource.clearPeriodCache(period);

      // Force refresh all data for the period
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