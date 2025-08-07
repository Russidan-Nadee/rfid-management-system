import '../repositories/admin_repository.dart';

class DeleteAssetUsecase {
  final AdminRepository repository;

  DeleteAssetUsecase(this.repository);

  Future<void> call(String assetNo) async {
    await repository.deleteAsset(assetNo);
  }
}