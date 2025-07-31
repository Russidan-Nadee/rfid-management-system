// Path: frontend/lib/features/scan/domain/usecases/get_asset_images_usecase.dart
import '../entities/asset_image_entity.dart';
import '../repositories/scan_repository.dart';

class GetAssetImagesUseCase {
  final ScanRepository repository;

  GetAssetImagesUseCase(this.repository);

  /// Get all images for a specific asset
  Future<List<AssetImageEntity>> execute(String assetNo) async {
    // Validation
    if (assetNo.isEmpty) {
      throw ArgumentError('Asset number cannot be empty');
    }

    try {
      final images = await repository.getAssetImages(assetNo);

      // Business logic: Sort images by primary first, then by creation date
      final sortedImages = List<AssetImageEntity>.from(images);
      sortedImages.sort((a, b) {
        // Primary images first
        if (a.isPrimary && !b.isPrimary) return -1;
        if (!a.isPrimary && b.isPrimary) return 1;

        // Then by creation date (newest first)
        return b.createdAt.compareTo(a.createdAt);
      });

      return sortedImages;
    } catch (error) {
      throw Exception('Failed to get asset images: $error');
    }
  }

  /// Get primary image for asset (if exists)
  Future<AssetImageEntity?> getPrimaryImage(String assetNo) async {
    final images = await execute(assetNo);

    try {
      return images.firstWhere((image) => image.isPrimary);
    } catch (e) {
      return null; // No primary image found
    }
  }

  /// Get image count for asset
  Future<int> getImageCount(String assetNo) async {
    final images = await execute(assetNo);
    return images.length;
  }
}
