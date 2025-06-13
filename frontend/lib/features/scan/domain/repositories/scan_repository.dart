// Path: lib/features/scan/domain/repositories/scan_repository.dart
import '../entities/scanned_item_entity.dart';
import '../entities/master_data_entity.dart';
import '../../data/models/asset_status_update_model.dart';

abstract class ScanRepository {
  // Existing methods (unchanged)
  Future<ScannedItemEntity> getAssetDetails(String assetNo);
  Future<List<String>> generateMockAssetNumbers();
  Future<AssetStatusUpdateResponse> updateAssetStatus(
    String assetNo,
    AssetStatusUpdateRequest request,
  );
  Future<void> logAssetScan(String assetNo, String scannedBy);

  // New methods for asset creation
  Future<ScannedItemEntity> createAsset(CreateAssetRequest request);
  Future<List<PlantEntity>> getPlants();
  Future<List<LocationEntity>> getLocationsByPlant(String plantCode);
  Future<List<UnitEntity>> getUnits();
}
