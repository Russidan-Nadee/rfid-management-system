// Path: frontend/lib/features/scan/domain/usecases/get_asset_details_usecase.dart
import '../entities/scanned_item_entity.dart';
import '../repositories/scan_repository.dart';

class GetAssetDetailsUseCase {
  final ScanRepository repository;

  GetAssetDetailsUseCase(this.repository);

  Future<ScannedItemEntity> execute(String assetNo) async {
    try {
      return await repository.getAssetDetails(assetNo);
    } catch (e) {
      // If asset not found, return unknown item
      return ScannedItemEntity.unknown(assetNo);
    }
  }
}
