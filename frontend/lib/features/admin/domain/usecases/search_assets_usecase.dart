import '../entities/asset_admin_entity.dart';
import '../repositories/admin_repository.dart';

class SearchAssetsUsecase {
  final AdminRepository repository;

  SearchAssetsUsecase(this.repository);

  Future<List<AssetAdminEntity>> call({
    String? searchTerm,
    String? status,
    String? plantCode,
    String? locationCode,
  }) async {
    return await repository.searchAssets(
      searchTerm: searchTerm,
      status: status,
      plantCode: plantCode,
      locationCode: locationCode,
    );
  }
}