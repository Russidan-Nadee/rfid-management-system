// Path: frontend/lib/features/scan/data/repositories/scan_repository_impl.dart
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/scanned_item_entity.dart';
import '../../domain/entities/master_data_entity.dart';
import '../../domain/entities/asset_image_entity.dart';
import '../../domain/repositories/scan_repository.dart';
import '../models/scanned_item_model.dart';
import '../models/asset_status_update_model.dart';
import '../models/asset_image_model.dart';
import '../models/create_asset_models.dart';
import '../datasources/mock_rfid_datasource.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ApiService apiService;
  final RfidDataSource rfidDataSource;

  ScanRepositoryImpl({required this.apiService, required this.rfidDataSource});

  @override
  Future<List<String>> generateMockAssetNumbers() async {
    // ใช้ real RFID แทน mock
    return await rfidDataSource.generateAssetNumbers();
  }

  @override
  Future<ScannedItemEntity> getAssetDetails(String epcCode) async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        ApiConstants.scanAssetDetailByEpc(epcCode),
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
  Future<AssetStatusUpdateResponse> updateAssetStatus(
    String assetNo,
    AssetStatusUpdateRequest request,
  ) async {
    try {
      print('Repository: Updating asset status for Asset No: $assetNo');
      print('Repository: Request data: ${request.toJson()}');

      final response = await apiService.patch<Map<String, dynamic>>(
        ApiConstants.scanAssetCheck(assetNo), // ใช้ method ที่มีอยู่แล้ว
        body: request.toJson(),
        fromJson: (json) => json,
      );

      print(
        'Repository: Update response - Success: ${response.success}, Message: ${response.message}',
      );

      final updateResponse = AssetStatusUpdateResponse.fromJson({
        'success': response.success,
        'message': response.message,
        'data': response.data,
        'timestamp': response.timestamp.toIso8601String(),
      });

      print(
        'Repository: Parsed update response - Success: ${updateResponse.success}',
      );
      return updateResponse;
    } catch (e) {
      print('Repository: Exception updating asset status: $e');
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
      print('Failed to log asset scan: $e');
    }
  }

  @override
  Future<ScannedItemEntity> createAsset(CreateAssetRequest request) async {
    try {
      final requestModel = CreateAssetRequestModel(request);
      final response = await apiService.post<Map<String, dynamic>>(
        ApiConstants.scanAssetCreate,
        body: requestModel.toJson(),
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        return ScannedItemModel.fromJson(response.data!);
      } else {
        throw Exception('Failed to create asset: ${response.message}');
      }
    } catch (e) {
      throw Exception('Failed to create asset: $e');
    }
  }

  @override
  Future<List<PlantEntity>> getPlants() async {
    try {
      final response = await apiService.get<List<dynamic>>(
        ApiConstants.plants,
        fromJson: (json) => json as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((json) => PlantModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch plants');
      }
    } catch (e) {
      throw Exception('Failed to get plants: $e');
    }
  }

  @override
  Future<List<LocationEntity>> getLocationsByPlant(String plantCode) async {
    try {
      final response = await apiService.get<List<dynamic>>(
        ApiConstants.locations,
        queryParams: {'plant_code': plantCode},
        fromJson: (json) => json as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((json) => LocationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch locations');
      }
    } catch (e) {
      throw Exception('Failed to get locations: $e');
    }
  }

  @override
  Future<List<UnitEntity>> getUnits() async {
    try {
      final response = await apiService.get<List<dynamic>>(
        ApiConstants.units,
        fromJson: (json) => json as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((json) => UnitModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch units');
      }
    } catch (e) {
      throw Exception('Failed to get units: $e');
    }
  }

  @override
  Future<List<DepartmentEntity>> getDepartments() async {
    try {
      final response = await apiService.get<List<dynamic>>(
        '/departments',
        fromJson: (json) => json as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map(
              (json) => DepartmentModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('Failed to fetch departments');
      }
    } catch (e) {
      throw Exception('Failed to get departments: $e');
    }
  }

  @override
  Future<List<ScannedItemEntity>> getAssetsByLocation(
    String locationCode,
  ) async {
    try {
      print('Repository: Getting assets for location: $locationCode');

      final response = await apiService.get<List<dynamic>>(
        '/assets',
        queryParams: {'location_code': locationCode},
        fromJson: (json) => json as List<dynamic>,
      );

      print('Repository: API Response - Success: ${response.success}');
      print(
        'Repository: API Response - Data length: ${response.data?.length ?? 0}',
      );

      if (response.success && response.data != null) {
        final assets = response.data!
            .map(
              (json) => ScannedItemModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        print('Repository: Converted ${assets.length} assets');
        return assets;
      } else {
        throw Exception('Failed to fetch assets for location');
      }
    } catch (e) {
      print('Repository: Error getting assets by location: $e');
      throw Exception('Failed to get assets by location: $e');
    }
  }

  // ⭐ NEW: Get Asset Images implementation
  @override
  Future<List<AssetImageEntity>> getAssetImages(String assetNo) async {
    try {
      print('Repository: Getting images for asset: $assetNo');

      final response = await apiService.get<Map<String, dynamic>>(
        '/images/assets/$assetNo/images',
        fromJson: (json) => json,
      );

      print('Repository: Images API Response - Success: ${response.success}');

      if (response.success && response.data != null) {
        final data = response.data!;
        final imagesJson = data['images'] as List<dynamic>? ?? [];

        print(
          'Repository: Found ${imagesJson.length} images for asset $assetNo',
        );

        final images = imagesJson
            .map(
              (json) => AssetImageModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        return images;
      } else {
        throw Exception('Failed to fetch asset images: ${response.message}');
      }
    } catch (e) {
      print('Repository: Error getting asset images: $e');
      throw Exception('Failed to get asset images: $e');
    }
  }
}
