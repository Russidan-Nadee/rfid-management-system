import '../entities/search_image_entity.dart';
import '../repositories/search_image_repository.dart';

class GetSearchImagesUseCase {
  final SearchImageRepository repository;

  GetSearchImagesUseCase(this.repository);

  /// Get all images for a specific asset
  Future<List<SearchImageEntity>> execute(String assetNo) async {
    // Validation
    if (assetNo.isEmpty) {
      throw ArgumentError('Asset number cannot be empty');
    }

    try {
      return await repository.getAssetImages(assetNo);
    } catch (error) {
      throw Exception('Failed to get search images: $error');
    }
  }

  /// Get primary image for asset (if exists)
  Future<SearchImageEntity?> getPrimaryImage(String assetNo) async {
    if (assetNo.isEmpty) {
      throw ArgumentError('Asset number cannot be empty');
    }

    try {
      return await repository.getPrimaryImage(assetNo);
    } catch (error) {
      return null; // Return null on error instead of throwing
    }
  }

  /// Get image count for asset
  Future<int> getImageCount(String assetNo) async {
    if (assetNo.isEmpty) {
      return 0;
    }

    try {
      return await repository.getImageCount(assetNo);
    } catch (error) {
      return 0;
    }
  }

  /// Check if asset has images
  Future<bool> hasImages(String assetNo) async {
    if (assetNo.isEmpty) {
      return false;
    }

    try {
      return await repository.hasImages(assetNo);
    } catch (error) {
      return false;
    }
  }

  /// Get primary images for multiple assets (batch operation)
  /// Useful for loading images for search result lists
  Future<Map<String, SearchImageEntity?>> getBatchPrimaryImages(
    List<String> assetNumbers,
  ) async {
    if (assetNumbers.isEmpty) {
      return {};
    }

    try {
      return await repository.getBatchPrimaryImages(assetNumbers);
    } catch (error) {
      // Return empty map with null values for all assets on error
      return Map.fromEntries(
        assetNumbers.map((assetNo) => MapEntry(assetNo, null)),
      );
    }
  }
}