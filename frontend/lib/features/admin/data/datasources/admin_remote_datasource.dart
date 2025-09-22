import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/asset_admin_model.dart';
import '../models/admin_asset_image_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../admin/domain/entities/admin_asset_image_entity.dart';

abstract class AdminRemoteDatasource {
  Future<List<AssetAdminModel>> getAllAssets();
  Future<AssetAdminModel?> getAssetByNo(String assetNo);
  Future<AssetAdminModel> updateAsset(UpdateAssetRequestModel request);
  Future<void> deleteAsset(String assetNo);
  Future<List<AssetAdminModel>> searchAssets({
    String? searchTerm,
    String? status,
    String? plantCode,
    String? locationCode,
  });
  Future<void> deleteImage(int imageId);
  Future<List<AdminAssetImageEntity>> getAssetImages(String assetNo);
  Future<bool> uploadImage(String assetNo, File imageFile);
  
  // User management methods
  Future<List<Map<String, dynamic>>> getAllUsers();
  Future<void> updateUserRole(String userId, String role);
  Future<void> updateUserStatus(String userId, bool isActive);
  Future<List<String>> getAvailableRoles();
  
  // Master data methods
  Future<Map<String, dynamic>> getMasterData();
}

class AdminRemoteDatasourceImpl implements AdminRemoteDatasource {
  final ApiService _apiService = ApiService();

  @override
  Future<List<AssetAdminModel>> getAllAssets() async {
    final apiResponse = await _apiService.get('/admin/assets');
    
    if (apiResponse.success) {
      final List<dynamic> assetsJson = apiResponse.data ?? [];
      return assetsJson
          .map((json) => AssetAdminModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch assets: ${apiResponse.message}');
    }
  }

  @override
  Future<AssetAdminModel?> getAssetByNo(String assetNo) async {
    try {
      final apiResponse = await _apiService.get('/admin/assets/$assetNo');
      
      if (apiResponse.success) {
        return AssetAdminModel.fromJson(apiResponse.data);
      } else {
        throw Exception('Failed to fetch asset: ${apiResponse.message}');
      }
    } catch (e) {
      // Handle 404 case - asset not found
      if (e.toString().contains('not found') || e.toString().contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<AssetAdminModel> updateAsset(UpdateAssetRequestModel request) async {
    final apiResponse = await _apiService.put(
      '/admin/assets/${request.request.assetNo}',
      body: request.toJson(),
    );

    if (apiResponse.success) {
      return AssetAdminModel.fromJson(apiResponse.data);
    } else {
      throw Exception('Failed to update asset: ${apiResponse.message}');
    }
  }

  @override
  Future<void> deleteAsset(String assetNo) async {
    final apiResponse = await _apiService.delete('/admin/assets/$assetNo');

    if (!apiResponse.success) {
      throw Exception('Failed to delete asset: ${apiResponse.message}');
    }
  }

  @override
  Future<List<AssetAdminModel>> searchAssets({
    String? searchTerm,
    String? status,
    String? plantCode,
    String? locationCode,
  }) async {
    final Map<String, String> queryParams = {};
    
    if (searchTerm != null && searchTerm.isNotEmpty) {
      queryParams['search'] = searchTerm;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (plantCode != null && plantCode.isNotEmpty) {
      queryParams['plant_code'] = plantCode;
    }
    if (locationCode != null && locationCode.isNotEmpty) {
      queryParams['location_code'] = locationCode;
    }

    final apiResponse = await _apiService.get(
      '/admin/assets/search',
      queryParams: queryParams,
    );

    if (apiResponse.success) {
      final List<dynamic> assetsJson = apiResponse.data ?? [];
      return assetsJson
          .map((json) => AssetAdminModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to search assets: ${apiResponse.message}');
    }
  }

  @override
  Future<void> deleteImage(int imageId) async {
    final apiResponse = await _apiService.delete('/images/$imageId');

    if (!apiResponse.success) {
      throw Exception('Failed to delete image: ${apiResponse.message}');
    }
  }

  @override
  Future<List<AdminAssetImageEntity>> getAssetImages(String assetNo) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.assetImages(assetNo),
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final imagesJson = data['images'] as List<dynamic>? ?? [];

        final images = imagesJson
            .map(
              (json) => AdminAssetImageModel.fromJson(json as Map<String, dynamic>),
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

  @override
  Future<bool> uploadImage(String assetNo, File imageFile) async {
    try {
      print('🔍 Admin: DATASOURCE uploadImage called');
      print('🔍 Admin: Starting upload for asset: $assetNo');
      print('🔍 Admin: Platform: ${kIsWeb ? 'Web' : 'Mobile'}');
      print('🔍 Admin: File path: ${imageFile.path}');

      // Use ApiService's uploadImageBytes method instead of manual HTTP requests
      final bytes = await imageFile.readAsBytes();

      // Extract filename from path - for blob URLs, use timestamp-based name
      String filename = imageFile.path.split('/').last;
      if (imageFile.path.startsWith('blob:')) {
        // For blob URLs, use a default filename with timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        filename = 'web_upload_$timestamp.jpg';
        print('🔍 Admin: Using generated filename for blob URL');
      }

      print('🔍 Admin: File size: ${bytes.length} bytes');
      print('🔍 Admin: Filename: $filename');

      final response = await _apiService.uploadImageBytes(
        ApiConstants.uploadAssetImages(assetNo),
        bytes,
        filename,
        'image',
      );

      print('🔍 Admin: Upload response: ${response.success}');
      print('🔍 Admin: Upload message: ${response.message}');

      return response.success;
    } catch (e) {
      print('💥 Admin: Error in uploadImage: $e');
      print('💥 Admin: Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // ===== USER MANAGEMENT METHODS =====

  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final apiResponse = await _apiService.get('/admin/users');
    
    if (apiResponse.success) {
      final List<dynamic> usersJson = apiResponse.data ?? [];
      return usersJson
          .map((json) => Map<String, dynamic>.from(json))
          .toList();
    } else {
      throw Exception('Failed to fetch users: ${apiResponse.message}');
    }
  }

  @override
  Future<void> updateUserRole(String userId, String role) async {
    final apiResponse = await _apiService.put(
      '/admin/users/$userId/role',
      body: {'role': role},
    );

    if (!apiResponse.success) {
      throw Exception('Failed to update user role: ${apiResponse.message}');
    }
  }

  @override
  Future<void> updateUserStatus(String userId, bool isActive) async {
    final apiResponse = await _apiService.put(
      '/admin/users/$userId/status',
      body: {'is_active': isActive},
    );

    if (!apiResponse.success) {
      throw Exception('Failed to update user status: ${apiResponse.message}');
    }
  }

  @override
  Future<List<String>> getAvailableRoles() async {
    final apiResponse = await _apiService.get('/admin/roles');
    
    if (apiResponse.success) {
      final List<dynamic> rolesJson = apiResponse.data ?? [];
      return rolesJson.map((role) => role.toString()).toList();
    } else {
      throw Exception('Failed to fetch available roles: ${apiResponse.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getMasterData() async {
    final apiResponse = await _apiService.get('/admin/master-data');
    
    if (apiResponse.success) {
      return Map<String, dynamic>.from(apiResponse.data ?? {});
    } else {
      throw Exception('Failed to fetch master data: ${apiResponse.message}');
    }
  }
}