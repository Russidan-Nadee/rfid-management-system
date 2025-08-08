import 'dart:io';
import '../repositories/admin_repository.dart';

class UploadAdminImageUsecase {
  final AdminRepository repository;

  UploadAdminImageUsecase(this.repository);

  Future<bool> call(String assetNo, File imageFile) async {
    print('🔍 UseCase: Starting upload for asset: $assetNo');
    
    try {
      print('🔍 UseCase: Validating asset number...');
      if (assetNo.isEmpty) {
        print('❌ UseCase: Empty asset number');
        throw ArgumentError('Asset number cannot be empty');
      }

      print('🔍 UseCase: Checking if file exists...');
      try {
        final exists = await imageFile.exists();
        print('🔍 UseCase: File exists check result: $exists');
        
        if (!exists) {
          print('❌ UseCase: Image file does not exist: ${imageFile.path}');
          throw ArgumentError('Image file does not exist');
        }
      } catch (e) {
        print('💥 UseCase: Error checking file existence: $e');
        throw Exception('Failed to check file existence: $e');
      }

      print('🔍 UseCase: Getting file size...');
      try {
        final fileSize = await imageFile.length();
        print('🔍 UseCase: File size: $fileSize bytes');
        
        if (fileSize > 10 * 1024 * 1024) {
          print('❌ UseCase: File size exceeds limit: $fileSize bytes');
          throw ArgumentError('File size exceeds 10MB limit');
        }
      } catch (e) {
        print('💥 UseCase: Error getting file size: $e');
        throw Exception('Failed to get file size: $e');
      }

      print('🔍 UseCase: All validations passed, calling repository.uploadImage...');
      final result = await repository.uploadImage(assetNo, imageFile);
      print('🔍 UseCase: Repository returned: $result');
      
      return result;
    } catch (error) {
      print('💥 UseCase: Error occurred: $error');
      print('💥 UseCase: Error type: ${error.runtimeType}');
      throw Exception('Failed to upload image: $error');
    }
  }
}