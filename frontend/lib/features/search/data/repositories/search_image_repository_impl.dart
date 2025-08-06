import '../../domain/entities/search_image_entity.dart';
import '../../domain/repositories/search_image_repository.dart';
import '../datasources/remote/search_image_remote_datasource.dart';

class SearchImageRepositoryImpl implements SearchImageRepository {
  final SearchImageRemoteDataSource remoteDataSource;

  SearchImageRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<SearchImageEntity>> getAssetImages(String assetNo) async {
    try {
      final models = await remoteDataSource.getAssetImages(assetNo);
      
      // Convert models to entities and sort them
      final entities = models.map((model) => model.toDomain()).toList();
      
      // Business logic: Sort images by primary first, then by creation date
      entities.sort((a, b) {
        // Primary images first
        if (a.isPrimary && !b.isPrimary) return -1;
        if (!a.isPrimary && b.isPrimary) return 1;

        // Then by creation date (newest first)
        return b.createdAt.compareTo(a.createdAt);
      });

      return entities;
    } catch (error) {
      throw Exception('Failed to get asset images: $error');
    }
  }

  @override
  Future<SearchImageEntity?> getPrimaryImage(String assetNo) async {
    try {
      final images = await getAssetImages(assetNo);
      
      // Find primary image
      try {
        return images.firstWhere((image) => image.isPrimary);
      } catch (e) {
        // If no primary image, return first image or null
        return images.isNotEmpty ? images.first : null;
      }
    } catch (error) {
      return null; // Return null if any error occurs
    }
  }

  @override
  Future<int> getImageCount(String assetNo) async {
    try {
      final images = await getAssetImages(assetNo);
      return images.length;
    } catch (error) {
      return 0; // Return 0 if error occurs
    }
  }

  @override
  Future<bool> hasImages(String assetNo) async {
    try {
      final count = await getImageCount(assetNo);
      return count > 0;
    } catch (error) {
      return false; // Return false if error occurs
    }
  }

  @override
  Future<Map<String, List<SearchImageEntity>>> getBatchAssetImages(
    List<String> assetNumbers,
  ) async {
    final results = <String, List<SearchImageEntity>>{};
    
    // For now, we'll make individual calls for each asset
    // In a real implementation, you might want to create a batch API endpoint
    await Future.wait(
      assetNumbers.map((assetNo) async {
        try {
          final images = await getAssetImages(assetNo);
          results[assetNo] = images;
        } catch (error) {
          results[assetNo] = []; // Empty list if error
        }
      }),
    );

    return results;
  }

  @override
  Future<Map<String, SearchImageEntity?>> getBatchPrimaryImages(
    List<String> assetNumbers,
  ) async {
    final results = <String, SearchImageEntity?>{};
    
    // For now, we'll make individual calls for each asset
    await Future.wait(
      assetNumbers.map((assetNo) async {
        try {
          final primaryImage = await getPrimaryImage(assetNo);
          results[assetNo] = primaryImage;
        } catch (error) {
          results[assetNo] = null; // Null if error
        }
      }),
    );

    return results;
  }
}