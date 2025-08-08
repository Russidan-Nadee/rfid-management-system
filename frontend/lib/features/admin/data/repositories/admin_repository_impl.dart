import 'dart:io';
import '../../domain/entities/asset_admin_entity.dart';
import '../../domain/entities/admin_asset_image_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';
import '../models/asset_admin_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDatasource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AssetAdminEntity>> getAllAssets() async {
    final models = await remoteDataSource.getAllAssets();
    return models.cast<AssetAdminEntity>();
  }

  @override
  Future<AssetAdminEntity?> getAssetByNo(String assetNo) async {
    final model = await remoteDataSource.getAssetByNo(assetNo);
    return model;
  }

  @override
  Future<AssetAdminEntity> updateAsset(UpdateAssetRequest request) async {
    final requestModel = UpdateAssetRequestModel(request);
    final model = await remoteDataSource.updateAsset(requestModel);
    return model;
  }

  @override
  Future<void> deleteAsset(String assetNo) async {
    await remoteDataSource.deleteAsset(assetNo);
  }

  @override
  Future<List<AssetAdminEntity>> searchAssets({
    String? searchTerm,
    String? status,
    String? plantCode,
    String? locationCode,
  }) async {
    final models = await remoteDataSource.searchAssets(
      searchTerm: searchTerm,
      status: status,
      plantCode: plantCode,
      locationCode: locationCode,
    );
    return models.cast<AssetAdminEntity>();
  }

  @override
  Future<void> deleteImage(int imageId) async {
    await remoteDataSource.deleteImage(imageId);
  }

  @override
  Future<List<AdminAssetImageEntity>> getAssetImages(String assetNo) async {
    return await remoteDataSource.getAssetImages(assetNo);
  }

  @override
  Future<bool> uploadImage(String assetNo, File imageFile) async {
    return await remoteDataSource.uploadImage(assetNo, imageFile);
  }
}