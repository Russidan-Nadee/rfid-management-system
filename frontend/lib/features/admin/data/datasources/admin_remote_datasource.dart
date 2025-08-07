import '../models/asset_admin_model.dart';
import '../../../../core/services/api_service.dart';

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
}