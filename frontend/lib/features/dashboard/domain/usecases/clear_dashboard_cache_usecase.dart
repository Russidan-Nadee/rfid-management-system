// Path: frontend/lib/features/dashboard/domain/usecases/clear_dashboard_cache_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/dashboard_repository.dart';

class ClearDashboardCacheUseCase {
  final DashboardRepository repository;

  ClearDashboardCacheUseCase(this.repository);

  /// Execute the use case to clear all dashboard cache
  ///
  /// This will force fresh data retrieval on next dashboard requests
  /// Returns [Unit] on success or [Failure] on error
  Future<Either<Failure, Unit>> call() async {
    return await repository.clearDashboardCache();
  }
}
