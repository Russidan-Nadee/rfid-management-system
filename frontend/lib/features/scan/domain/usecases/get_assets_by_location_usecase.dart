// Path: frontend/lib/features/scan/domain/usecases/get_assets_by_location_usecase.dart
import '../entities/scanned_item_entity.dart';
import '../repositories/scan_repository.dart';

class GetAssetsByLocationUseCase {
  final ScanRepository repository;

  GetAssetsByLocationUseCase(this.repository);

  /// Get all assets that should be in a specific location
  Future<List<ScannedItemEntity>> execute(String locationCode) async {
    // This will call the backend API to get assets by location
    // API: GET /assets?location_code={locationCode}&status=A
    return await repository.getAssetsByLocation(locationCode);
  }

  /// Get asset count for a specific location
  Future<int> getAssetCount(String locationCode) async {
    final assets = await execute(locationCode);
    return assets.length;
  }

  /// Get multiple location asset counts at once
  Future<Map<String, int>> getMultipleLocationCounts(
    List<String> locationCodes,
  ) async {
    final Map<String, int> counts = {};

    for (final locationCode in locationCodes) {
      try {
        final count = await getAssetCount(locationCode);
        counts[locationCode] = count;
      } catch (e) {
        // If error getting count for a location, set to 0
        counts[locationCode] = 0;
      }
    }

    return counts;
  }
}
