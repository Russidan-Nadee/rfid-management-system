import '../../../../../core/services/api_service.dart';
import '../../models/search_image_model.dart';
import 'search_image_remote_datasource.dart';

class SearchImageRemoteDataSourceImpl implements SearchImageRemoteDataSource {
  final ApiService apiService;

  SearchImageRemoteDataSourceImpl({
    required this.apiService,
  });

  @override
  Future<List<SearchImageModel>> getAssetImages(String assetNo) async {
    try {
      // Use the same endpoint as scan feature but independent implementation
      final response = await apiService.get('/images/asset/$assetNo');
      
      if (response.success && response.hasData) {
        final data = response.data;
        
        // Handle different response formats
        List<dynamic> imagesJson;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            imagesJson = data['data'] as List<dynamic>;
          } else if (data.containsKey('images')) {
            imagesJson = data['images'] as List<dynamic>;
          } else {
            imagesJson = [data]; // Single image response
          }
        } else if (data is List<dynamic>) {
          imagesJson = data;
        } else {
          throw Exception('Invalid response format');
        }

        return imagesJson
            .map((json) => SearchImageModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // No images found for this asset or error occurred
        return [];
      }
    } catch (error) {
      throw Exception('Network error loading asset images: $error');
    }
  }

  @override
  Future<bool> hasImages(String assetNo) async {
    try {
      // Lightweight check - could be optimized with a specific endpoint
      final images = await getAssetImages(assetNo);
      return images.isNotEmpty;
    } catch (error) {
      return false; // Return false if any error occurs
    }
  }
}