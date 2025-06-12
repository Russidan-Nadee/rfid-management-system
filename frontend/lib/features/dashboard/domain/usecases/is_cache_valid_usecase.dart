// Path: frontend/lib/features/dashboard/domain/usecases/is_cache_valid_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/dashboard_repository.dart';

class IsCacheValidUseCase {
  final DashboardRepository repository;

  IsCacheValidUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.isCacheValid();
  }
}
