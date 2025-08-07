import '../entities/asset_admin_entity.dart';

abstract class AdminRepository {
  Future<List<AssetAdminEntity>> getAllAssets();
  Future<AssetAdminEntity?> getAssetByNo(String assetNo);
  Future<AssetAdminEntity> updateAsset(UpdateAssetRequest request);
  Future<void> deleteAsset(String assetNo);
  Future<List<AssetAdminEntity>> searchAssets({
    String? searchTerm,
    String? status,
    String? plantCode,
    String? locationCode,
  });
}