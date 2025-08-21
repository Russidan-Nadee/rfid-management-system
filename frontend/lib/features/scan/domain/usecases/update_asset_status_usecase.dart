// Path: frontend/lib/features/scan/domain/usecases/update_asset_status_usecase.dart
import '../../data/models/asset_status_update_model.dart';
import '../entities/scanned_item_entity.dart';
import '../repositories/scan_repository.dart';

class UpdateAssetStatusUseCase {
  final ScanRepository repository;

  UpdateAssetStatusUseCase(this.repository);

  /// Mark asset as checked (A -> C) พร้อม log
  Future<ScannedItemEntity> markAsChecked(
    String assetNo,
    String updatedBy,
  ) async {
    try {
      print('markAsChecked called for asset: $assetNo');

      final request = AssetStatusUpdateRequest(
        status: 'C',
        updatedBy: updatedBy,
        remarks:
            'Marked as checked via mobile app at ${DateTime.now().toIso8601String()}',
      );

      print('Request created: ${request.toJson()}');

      final response = await repository.updateAssetStatus(assetNo, request);

      print(
        'Response received: success=${response.success}, message=${response.message}',
      );

      if (!response.success) {
        throw Exception('Failed to mark asset as checked: ${response.message}');
      }

      if (response.updatedAsset == null) {
        throw Exception('Updated asset data not found');
      }

      return response.updatedAsset!;
    } catch (e) {
      print('UseCase Error: $e');
      rethrow;
    }
  }
}
