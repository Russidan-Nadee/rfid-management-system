// Path: frontend/lib/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStatsUseCase {
  final DashboardRepository repository;

  GetDashboardStatsUseCase(this.repository);

  Future<Either<Failure, DashboardStats>> call({
    bool forceRefresh = false,
  }) async {
    return await repository.getDashboardStats(forceRefresh: forceRefresh);
  }
}
