// Path: frontend/lib/features/scan/data/repositories/scan_repository_impl.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // ✅ เพิ่มสำหรับ MediaType
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

  // All existing methods remain unchanged...
  @override
  Future<List<String>> generateMockAssetNumbers() async {
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
      final response = await apiService.patch<Map<String, dynamic>>(
        ApiConstants.scanAssetCheck(assetNo),
        body: request.toJson(),
        fromJson: (json) => json,
      );

      final updateResponse = AssetStatusUpdateResponse.fromJson({
        'success': response.success,
        'message': response.message,
        'data': response.data,
        'timestamp': response.timestamp.toIso8601String(),
      });

      return updateResponse;
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
  Future<List<CategoryEntity>> getCategories() async {
    try {
      final response = await apiService.get<List<dynamic>>(
        ApiConstants.categories,
        fromJson: (json) => json as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch categories');
      }
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  @override
  Future<List<BrandEntity>> getBrands() async {
    try {
      final response = await apiService.get<List<dynamic>>(
        ApiConstants.brands,
        fromJson: (json) => json as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((json) => BrandModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch brands');
      }
    } catch (e) {
      throw Exception('Failed to get brands: $e');
    }
  }

  @override
  Future<List<ScannedItemEntity>> getAssetsByLocation(
    String locationCode,
  ) async {
    try {
      final response = await apiService.get<List<dynamic>>(
        '/assets',
        queryParams: {'location_code': locationCode},
        fromJson: (json) => json as List<dynamic>,
      );

      if (response.success && response.data != null) {
        final assets = response.data!
            .map(
              (json) => ScannedItemModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        return assets;
      } else {
        throw Exception('Failed to fetch assets for location');
      }
    } catch (e) {
      throw Exception('Failed to get assets by location: $e');
    }
  }

  @override
  Future<List<AssetImageEntity>> getAssetImages(String assetNo) async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        ApiConstants.assetImages(assetNo), // ✅ ใช้ ApiConstants ที่แก้แล้ว
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final imagesJson = data['images'] as List<dynamic>? ?? [];

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
      throw Exception('Failed to get asset images: $e');
    }
  }

  // ⭐ FIXED: Upload Image Implementation พร้อม Content-Type ที่ถูกต้อง
  @override
  Future<bool> uploadImage(String assetNo, File imageFile) async {
    try {
      // 🔍 Debug: ข้อมูลเริ่มต้น
      print('🔍 Repository: Starting upload for asset: $assetNo');
      print('🔍 Repository: File path: ${imageFile.path}');
      print('🔍 Repository: File exists: ${await imageFile.exists()}');
      print('🔍 Repository: File size: ${await imageFile.length()} bytes');

      // สร้าง URL
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.uploadAssetImages(assetNo)}',
      );
      print('🔍 Repository: Upload URL: $uri');

      // สร้าง multipart request
      final request = http.MultipartRequest('POST', uri);

      // เพิ่ม auth header
      final token = await apiService.getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
        print('🔑 TOKEN LENGTH: ${token.length}'); // ✅ Debug token
        print('🔍 Repository: Auth token added');
      } else {
        print('❌ Repository: No auth token found');
      }

      // ✅ Auto-detect Content-Type จาก file extension
      MediaType? contentType;
      final extension = imageFile.path.toLowerCase().split('.').last;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = MediaType('image', 'jpeg');
          break;
        case 'png':
          contentType = MediaType('image', 'png');
          break;
        case 'webp':
          contentType = MediaType('image', 'webp');
          break;
        default:
          contentType = MediaType('image', 'jpeg'); // default fallback
      }

      print('🔍 Repository: Detected file extension: $extension');
      print('🔍 Repository: Using Content-Type: $contentType');

      // เพิ่มไฟล์พร้อม Content-Type ที่ถูกต้อง
      final multipartFile = await http.MultipartFile.fromPath(
        'image', // field name ตามที่ backend expect
        imageFile.path,
        contentType: contentType, // ✅ ใช้ Content-Type ที่ตรวจจับได้
      );
      request.files.add(multipartFile);

      print(
        '🔍 Repository: Multipart file added - field: image, filename: ${multipartFile.filename}',
      );
      print('🔍 Repository: Content-Type: ${multipartFile.contentType}');

      // ส่ง request
      print('🔍 Repository: Sending request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🔍 Repository: Response status: ${response.statusCode}');
      print('🔍 Repository: Response body: ${response.body}');
      print('🔍 Repository: Response headers: ${response.headers}');

      if (response.statusCode == 201) {
        print('✅ Repository: Upload successful');
        return true;
      } else {
        print(
          '❌ Repository: Upload failed with status: ${response.statusCode}',
        );
        throw Exception(
          'Upload failed with status: ${response.statusCode}, body: ${response.body}',
        );
      }
    } catch (e) {
      print('💥 Repository: Upload error: $e');
      print('💥 Repository: Error type: ${e.runtimeType}');
      throw Exception('Failed to upload image: $e');
    }
  }
}
