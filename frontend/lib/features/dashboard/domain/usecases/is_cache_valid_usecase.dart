// Path: frontend/lib/features/dashboard/domain/usecases/is_cache_valid_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/dashboard_repository.dart';

class IsCacheValidParams {
  final String cacheKey;

  const IsCacheValidParams({required this.cacheKey});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IsCacheValidParams && other.cacheKey == cacheKey;
  }

  @override
  int get hashCode => cacheKey.hashCode;

  @override
  String toString() => 'IsCacheValidParams(cacheKey: $cacheKey)';
}

class IsCacheValidUseCase {
  final DashboardRepository repository;

  IsCacheValidUseCase(this.repository);

  Future<Either<Failure, bool>> call(IsCacheValidParams params) async {
    return await repository.isCacheValid(params.cacheKey);
  }

  // Convenience method for common cache keys
  Future<Either<Failure, bool>> checkStatsCache(String period) async {
    return await call(IsCacheValidParams(cacheKey: 'dashboard_stats_$period'));
  }

  Future<Either<Failure, bool>> checkOverviewCache(String period) async {
    return await call(
      IsCacheValidParams(cacheKey: 'dashboard_overview_$period'),
    );
  }

  Future<Either<Failure, bool>> checkAlertsCache() async {
    return await call(const IsCacheValidParams(cacheKey: 'dashboard_alerts'));
  }

  Future<Either<Failure, bool>> checkRecentCache(String period) async {
    return await call(IsCacheValidParams(cacheKey: 'dashboard_recent_$period'));
  }
}
