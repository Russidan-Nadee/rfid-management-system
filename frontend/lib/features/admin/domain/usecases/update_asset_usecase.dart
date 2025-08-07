import '../entities/asset_admin_entity.dart';
import '../repositories/admin_repository.dart';

class UpdateAssetUsecase {
  final AdminRepository repository;

  UpdateAssetUsecase(this.repository);

  Future<AssetAdminEntity> call(UpdateAssetRequest request) async {
    return await repository.updateAsset(request);
  }
}