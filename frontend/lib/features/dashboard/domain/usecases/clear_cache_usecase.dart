// Path: frontend/lib/features/dashboard/domain/usecases/clear_cache_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/dashboard_repository.dart';

class ClearCacheUseCase {
  final DashboardRepository repository;

  ClearCacheUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.clearCache();
  }
}
