import '../repositories/admin_repository.dart';

class DeleteImageUsecase {
  final AdminRepository repository;

  DeleteImageUsecase(this.repository);

  Future<void> call(int imageId) async {
    await repository.deleteImage(imageId);
  }
}