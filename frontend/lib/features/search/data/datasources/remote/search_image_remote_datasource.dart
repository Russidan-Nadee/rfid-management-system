import '../../models/search_image_model.dart';

/// Remote data source interface for search image operations
abstract class SearchImageRemoteDataSource {
  /// Get all images for a specific asset from API
  Future<List<SearchImageModel>> getAssetImages(String assetNo);

  /// Check if asset has images (lightweight check)
  Future<bool> hasImages(String assetNo);
}