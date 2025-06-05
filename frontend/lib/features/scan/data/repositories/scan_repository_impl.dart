// Path: frontend/lib/features/scan/data/repositories/scan_repository_impl.dart
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/scanned_item_entity.dart';
import '../../domain/repositories/scan_repository.dart';
import '../models/scanned_item_model.dart';
import '../models/asset_status_update_model.dart';
import '../datasources/mock_rfid_datasource.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ApiService apiService;
  final MockRfidDataSource mockRfidDataSource;

  ScanRepositoryImpl({
    required this.apiService,
    required this.mockRfidDataSource,
  });

  @override
  Future<ScannedItemEntity> getAssetDetails(String assetNo) async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        '${ApiConstants.assets}/$assetNo',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        return ScannedItemModel.fromJson(response.data!);
      } else {
        throw Exception('Asset not found');
      }
    } catch (e) {
      throw Exception('Failed to get asset details: $e');
    }
  }

  @override
  Future<List<String>> generateMockAssetNumbers() async {
    return mockRfidDataSource.generateAssetNumbers();
  }

  @override
  Future<AssetStatusUpdateResponse> updateAssetStatus(
    String assetNo,
    AssetStatusUpdateRequest request,
  ) async {
    try {
      final response = await apiService.patch<Map<String, dynamic>>(
        '${ApiConstants.assets}/$assetNo/status',
        body: request.toJson(),
        fromJson: (json) => json,
      );

      return AssetStatusUpdateResponse.fromJson({
        'success': response.success,
        'message': response.message,
        'data': response.data,
        'timestamp': response.timestamp.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update asset status: $e');
    }
  }

  @override
  Future<void> logAssetScan(String assetNo, String scannedBy) async {
    try {
      await apiService.post<void>(
        ApiConstants.scanLog,
        body: {'asset_no': assetNo},
        requiresAuth: true,
      );
    } catch (e) {
      // Silent fail - ไม่ throw error เพื่อไม่ให้กระทบ scan process
      print('Failed to log asset scan: $e');
    }
  }
}
