// Path: frontend/lib/features/dashboard/domain/usecases/get_quick_stats_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/dashboard_repository.dart';

class GetQuickStatsUseCase {
  final DashboardRepository repository;

  GetQuickStatsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await repository.getQuickStats();
  }
}
