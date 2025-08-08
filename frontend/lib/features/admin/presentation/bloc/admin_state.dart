import 'package:equatable/equatable.dart';
import '../../domain/entities/asset_admin_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminLoaded extends AdminState {
  final List<AssetAdminEntity> assets;

  const AdminLoaded(this.assets);

  @override
  List<Object> get props => [assets];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object> get props => [message];
}

class AssetUpdating extends AdminState {
  final List<AssetAdminEntity> assets;

  const AssetUpdating(this.assets);

  @override
  List<Object> get props => [assets];
}

class AssetUpdated extends AdminState {
  final List<AssetAdminEntity> assets;
  final AssetAdminEntity updatedAsset;

  const AssetUpdated(this.assets, this.updatedAsset);

  @override
  List<Object> get props => [assets, updatedAsset];
}

class AssetDeleting extends AdminState {
  final List<AssetAdminEntity> assets;
  final String deletingAssetNo;

  const AssetDeleting(this.assets, this.deletingAssetNo);

  @override
  List<Object> get props => [assets, deletingAssetNo];
}

class AssetDeleted extends AdminState {
  final List<AssetAdminEntity> assets;

  const AssetDeleted(this.assets);

  @override
  List<Object> get props => [assets];
}

class ImageDeleting extends AdminState {
  final List<AssetAdminEntity> assets;
  final int deletingImageId;

  const ImageDeleting(this.assets, this.deletingImageId);

  @override
  List<Object> get props => [assets, deletingImageId];
}

class ImageDeleted extends AdminState {
  final List<AssetAdminEntity> assets;
  final int deletedImageId;

  const ImageDeleted(this.assets, this.deletedImageId);

  @override
  List<Object> get props => [assets, deletedImageId];
}