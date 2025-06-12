// Path: frontend/lib/features/dashboard/domain/usecases/refresh_dashboard_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/dashboard_repository.dart';

class RefreshDashboardUseCase {
  final DashboardRepository repository;

  RefreshDashboardUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.refreshDashboardData();
  }
}
