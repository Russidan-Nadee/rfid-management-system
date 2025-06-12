// Path: frontend/lib/features/dashboard/data/repositories/dashboard_repository_impl.dart
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/core/utils/either.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:frontend/features/dashboard/domain/entities/overview_data.dart';
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
    bool forceRefresh = false,
  }) async {
    try {
      // Try cache first (if not force refresh)
      if (!forceRefresh) {
        final cachedStats = await cacheDataSource.getCachedStats();
        if (cachedStats != null) {
          return Right(cachedStats.toEntity());
        }
      }

      // Fetch from API
      final statsModel = await remoteDataSource.getDashboardStats();

      // Cache the result
      await cacheDataSource.cacheStats(statsModel);

      return Right(statsModel.toEntity());
    } on ServerException {
      return Left(ServerFailure('Failed to get dashboard statistics'));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    } on CacheException {
      // If cache fails, try to get from remote anyway
      try {
        final statsModel = await remoteDataSource.getDashboardStats();
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
    bool forceRefresh = false,
  }) async {
    try {
      // Try cache first (if not force refresh)
      if (!forceRefresh) {
        final cachedOverview = await cacheDataSource.getCachedOverview();
        if (cachedOverview != null) {
          return Right(cachedOverview.toEntity());
        }
      }

      // Fetch from API
      final overviewModel = await remoteDataSource.getOverviewData();

      // Cache the result
      await cacheDataSource.cacheOverview(overviewModel);

      return Right(overviewModel.toEntity());
    } on ServerException {
      return Left(ServerFailure('Failed to get overview data'));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    } on CacheException {
      // If cache fails, try to get from remote anyway
      try {
        final overviewModel = await remoteDataSource.getOverviewData();
        return Right(overviewModel.toEntity());
      } catch (e) {
        return Left(ServerFailure('Failed to get overview data'));
      }
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getQuickStats() async {
    try {
      final quickStats = await remoteDataSource.getQuickStats();
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
  Future<Either<Failure, Unit>> refreshDashboardData() async {
    try {
      // Clear cache
      await cacheDataSource.clearCache();

      // Force refresh both stats and overview
      await Future.wait([
        getDashboardStats(forceRefresh: true),
        getOverviewData(forceRefresh: true),
      ]);

      return Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to refresh dashboard data'));
    }
  }

  @override
  Future<Either<Failure, bool>> isCacheValid() async {
    try {
      final isValid = await cacheDataSource.isCacheValid();
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
}
