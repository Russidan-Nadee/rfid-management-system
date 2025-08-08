import 'dart:io';
import '../entities/asset_admin_entity.dart';
import '../entities/admin_asset_image_entity.dart';

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
  Future<void> deleteImage(int imageId);
  Future<List<AdminAssetImageEntity>> getAssetImages(String assetNo);
  Future<bool> uploadImage(String assetNo, File imageFile);
}