// Path: frontend/lib/features/dashboard/domain/usecases/get_overview_data_usecase.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/overview_data.dart';
import '../repositories/dashboard_repository.dart';

class GetOverviewDataUseCase {
  final DashboardRepository repository;

  GetOverviewDataUseCase(this.repository);

  Future<Either<Failure, OverviewData>> call({
    bool forceRefresh = false,
  }) async {
    return await repository.getOverviewData(forceRefresh: forceRefresh);
  }
}
