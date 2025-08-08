import 'package:equatable/equatable.dart';
import '../../domain/entities/asset_admin_entity.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllAssets extends AdminEvent {
  const LoadAllAssets();
}

class SearchAssets extends AdminEvent {
  final String? searchTerm;
  final String? status;
  final String? plantCode;
  final String? locationCode;

  const SearchAssets({
    this.searchTerm,
    this.status,
    this.plantCode,
    this.locationCode,
  });

  @override
  List<Object?> get props => [searchTerm, status, plantCode, locationCode];
}

class UpdateAsset extends AdminEvent {
  final UpdateAssetRequest request;

  const UpdateAsset(this.request);

  @override
  List<Object> get props => [request];
}

class DeleteAsset extends AdminEvent {
  final String assetNo;

  const DeleteAsset(this.assetNo);

  @override
  List<Object> get props => [assetNo];
}

class ClearError extends AdminEvent {
  const ClearError();
}

class DeleteImage extends AdminEvent {
  final int imageId;

  const DeleteImage(this.imageId);

  @override
  List<Object> get props => [imageId];
}