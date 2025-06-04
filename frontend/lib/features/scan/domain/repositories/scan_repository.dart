// Path: frontend/lib/features/scan/domain/repositories/scan_repository.dart
import '../entities/scanned_item_entity.dart';

abstract class ScanRepository {
  Future<ScannedItemEntity> getAssetDetails(String assetNo);
  Future<List<String>> generateMockAssetNumbers();
}
