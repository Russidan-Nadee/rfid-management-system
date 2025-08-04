// Path: frontend/lib/features/scan/domain/usecases/upload_image_usecase.dart
import 'dart:io';
import '../repositories/scan_repository.dart';

class UploadImageUseCase {
  final ScanRepository repository;

  UploadImageUseCase(this.repository);

  Future<bool> execute(String assetNo, File imageFile) async {
    // Validation
    if (assetNo.isEmpty) {
      throw ArgumentError('Asset number cannot be empty');
    }

    if (!await imageFile.exists()) {
      throw ArgumentError('Image file does not exist');
    }

    // Check file size (max 10MB)
    final fileSize = await imageFile.length();
    if (fileSize > 10 * 1024 * 1024) {
      throw ArgumentError('File size exceeds 10MB limit');
    }

    try {
      return await repository.uploadImage(assetNo, imageFile);
    } catch (error) {
      throw Exception('Failed to upload image: $error');
    }
  }
}
