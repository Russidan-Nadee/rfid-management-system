import '../repositories/admin_repository.dart';
import '../entities/admin_asset_image_entity.dart';

class GetAdminAssetImagesUsecase {
  final AdminRepository repository;

  GetAdminAssetImagesUsecase(this.repository);

  Future<List<AdminAssetImageEntity>> call(String assetNo) async {
    if (assetNo.isEmpty) {
      throw ArgumentError('Asset number cannot be empty');
    }

    try {
      final images = await repository.getAssetImages(assetNo);

      // Sort images by primary first, then by creation date
      final sortedImages = List<AdminAssetImageEntity>.from(images);
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
}