import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/assets_by_plant.dart';
import '../repositories/dashboard_repository.dart';

class GetAssetsByPlantUsecase {
  final DashboardRepository repository;

  GetAssetsByPlantUsecase(this.repository);

  Future<Either<Failure, AssetsByPlant>> call() async {
    return await repository.getAssetsByPlant();
  }
}
