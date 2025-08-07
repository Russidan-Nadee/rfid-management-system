import '../entities/asset_admin_entity.dart';
import '../repositories/admin_repository.dart';

class GetAllAssetsUsecase {
  final AdminRepository repository;

  GetAllAssetsUsecase(this.repository);

  Future<List<AssetAdminEntity>> call() async {
    return await repository.getAllAssets();
  }
}