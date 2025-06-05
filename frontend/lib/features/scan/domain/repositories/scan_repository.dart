// Path: frontend/lib/features/scan/domain/repositories/scan_repository.dart
import '../entities/scanned_item_entity.dart';
import '../../data/models/asset_status_update_model.dart';

abstract class ScanRepository {
  Future<ScannedItemEntity> getAssetDetails(String assetNo);
  Future<List<String>> generateMockAssetNumbers();
  Future<AssetStatusUpdateResponse> updateAssetStatus(
    String assetNo,
    AssetStatusUpdateRequest request,
  );
  Future<void> logAssetScan(String assetNo, String scannedBy);
}
