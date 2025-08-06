import '../entities/search_image_entity.dart';

/// Repository interface for search image operations
abstract class SearchImageRepository {
  /// Get all images for a specific asset
  Future<List<SearchImageEntity>> getAssetImages(String assetNo);

  /// Get primary image for an asset (if exists)
  Future<SearchImageEntity?> getPrimaryImage(String assetNo);

  /// Get image count for an asset
  Future<int> getImageCount(String assetNo);

  /// Check if asset has images
  Future<bool> hasImages(String assetNo);

  /// Get images for multiple assets (batch operation)
  Future<Map<String, List<SearchImageEntity>>> getBatchAssetImages(
    List<String> assetNumbers,
  );

  /// Get primary images for multiple assets (batch operation)
  Future<Map<String, SearchImageEntity?>> getBatchPrimaryImages(
    List<String> assetNumbers,
  );
}